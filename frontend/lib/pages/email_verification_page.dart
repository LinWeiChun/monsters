import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      Future.microtask(
        () => ref
            .read(authControllerProvider.notifier)
            .verifyEmail(token: widget.token),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final verified = state.verificationResult != null;
    final missingToken = widget.token.isEmpty;
    return Scaffold(
      backgroundColor: AppColors.registerFormBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    verified
                        ? Icons.verified_outlined
                        : Icons.mark_email_read_outlined,
                    size: 72,
                    color: AppColors.registerPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    verified ? 'Email 驗證完成' : '正在驗證 Email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.registerInk,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (verified)
                    const Text(
                      '下一步將完成服務地區、生日與公開暱稱等資格資料。',
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      missingToken
                          ? '驗證連結無效或不完整'
                          : state.errorMessage ?? '目前無法完成驗證，請稍後再試',
                      key: const Key('emailVerificationError'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.registerError),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  if (verified)
                    FilledButton(
                      key: const Key('emailVerificationContinueButton'),
                      onPressed: () => context.goNamed(AppRoute.login),
                      child: const Text('返回登入'),
                    )
                  else if (!state.isLoading)
                    FilledButton(
                      key: const Key('emailVerificationRestartButton'),
                      onPressed: () => context.goNamed(AppRoute.register),
                      child: const Text('重新開始'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
