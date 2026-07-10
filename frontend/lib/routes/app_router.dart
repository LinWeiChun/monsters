import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/password_lock_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';
import '../pages/splash_page.dart';
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
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppPath.home,
        name: AppRoute.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppPath.login,
        name: AppRoute.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppPath.register,
        name: AppRoute.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppPath.profile,
        name: AppRoute.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppPath.passwordLock,
        name: AppRoute.passwordLock,
        builder: (context, state) => const PasswordLockPage(),
      ),
    ],
  );
}
