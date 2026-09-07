import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/annoyance_chat_page.dart';
import '../pages/diary_chat_page.dart';
import '../pages/email_verification_page.dart';
import '../pages/email_verification_pending_page.dart';
import '../pages/email_change_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/password_lock_page.dart';
import '../pages/member_data_page.dart';
import '../pages/member_deactivated_page.dart';
import '../pages/member_restoration_page.dart';
import '../pages/register_page.dart';
import '../pages/splash_page.dart';
import '../pages/eligibility_page.dart';
import '../pages/guardian_consent_page.dart';
import '../pages/google_account_link_page.dart';
import '../pages/session_management_page.dart';
import '../pages/password_reset_request_page.dart';
import '../pages/password_reset_page.dart';
import '../models/eligibility_policy.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

GoRouter createAppRouter({String initialLocation = AppPath.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppPath.splash,
        name: AppRoute.splash,
        pageBuilder: (context, state) => _appPage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppPath.home,
        name: AppRoute.home,
        pageBuilder: (context, state) => _appPage(state, const HomePage()),
      ),
      GoRoute(
        path: AppPath.login,
        name: AppRoute.login,
        pageBuilder: (context, state) => _appPage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppPath.register,
        name: AppRoute.register,
        pageBuilder: (context, state) => _appPage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppPath.emailVerificationPending,
        name: AppRoute.emailVerificationPending,
        pageBuilder:
            (context, state) => _appPage(
              state,
              EmailVerificationPendingPage(
                initialEmail:
                    state.extra is String ? state.extra! as String : null,
              ),
            ),
      ),
      GoRoute(
        path: AppPath.emailVerification,
        name: AppRoute.emailVerification,
        pageBuilder:
            (context, state) => _appPage(
              state,
              EmailVerificationPage(
                token: state.uri.queryParameters['token'] ?? '',
              ),
            ),
      ),
      GoRoute(
        path: AppPath.eligibility,
        name: AppRoute.eligibility,
        pageBuilder: (context, state) {
          final data = state.extra;
          return _appPage(
            state,
            EligibilityPage(
              continuationCredential:
                  data is EligibilityRouteData
                      ? data.continuationCredential
                      : '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppPath.guardianConsent,
        name: AppRoute.guardianConsent,
        pageBuilder:
            (context, state) => _appPage(
              state,
              GuardianConsentPage(
                token: state.uri.queryParameters['token'] ?? '',
              ),
            ),
      ),
      GoRoute(
        path: AppPath.googleAccountLink,
        name: AppRoute.googleAccountLink,
        pageBuilder:
            (context, state) => _appPage(state, const GoogleAccountLinkPage()),
      ),
      GoRoute(
        path: AppPath.passwordResetRequest,
        name: AppRoute.passwordResetRequest,
        pageBuilder:
            (context, state) =>
                _appPage(state, const PasswordResetRequestPage()),
      ),
      GoRoute(
        path: AppPath.passwordReset,
        name: AppRoute.passwordReset,
        pageBuilder:
            (context, state) => _appPage(
              state,
              PasswordResetPage(
                token: state.uri.queryParameters['token'] ?? '',
              ),
            ),
      ),
      GoRoute(
        path: AppPath.profile,
        name: AppRoute.profile,
        pageBuilder:
            (context, state) => _appPage(state, const MemberDataPage()),
      ),
      GoRoute(
        path: AppPath.emailChange,
        name: AppRoute.emailChange,
        pageBuilder:
            (context, state) => _appPage(
              state,
              EmailChangePage(token: state.uri.queryParameters['token'] ?? ''),
            ),
      ),
      GoRoute(
        path: AppPath.memberRestoration,
        name: AppRoute.memberRestoration,
        pageBuilder: (context, state) {
          final data = state.extra;
          return _appPage(
            state,
            MemberRestorationPage(
              continuationCredential:
                  data is MemberRestorationRouteData
                      ? data.continuationCredential
                      : '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppPath.memberDeactivated,
        name: AppRoute.memberDeactivated,
        pageBuilder:
            (context, state) => _appPage(state, const MemberDeactivatedPage()),
      ),
      GoRoute(
        path: AppPath.sessions,
        name: AppRoute.sessions,
        pageBuilder:
            (context, state) => _appPage(state, const SessionManagementPage()),
      ),
      GoRoute(
        path: AppPath.passwordLock,
        name: AppRoute.passwordLock,
        pageBuilder:
            (context, state) => _appPage(state, const PasswordLockPage()),
      ),
      GoRoute(
        path: AppPath.annoyanceChat,
        name: AppRoute.annoyanceChat,
        pageBuilder:
            (context, state) => _appPage(state, const AnnoyanceChatPage()),
      ),
      GoRoute(
        path: AppPath.diaryChat,
        name: AppRoute.diaryChat,
        pageBuilder: (context, state) => _appPage(state, const DiaryChatPage()),
      ),
    ],
  );
}

CustomTransitionPage<void> _appPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        ),
        child: child,
      );
    },
    child: child,
  );
}
