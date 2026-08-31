import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/password_reset_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/password_reset_shell.dart';
import '../widgets/auth/password_reset_intro.dart';

class PasswordResetRequestPage extends ConsumerStatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  ConsumerState<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState
    extends ConsumerState<PasswordResetRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(passwordResetControllerProvider.notifier).beginRequest();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    return PasswordResetShell(
      child:
          state.stage == PasswordResetStage.accepted
              ? PasswordResetStatus(
                icon: Icons.mark_email_read_outlined,
                title: '請查看你的 Email',
                message: '若此 Email 可使用，我們會寄出一封密碼重設信。為保護會員隱私，畫面不會顯示 Email 是否存在。',
                primaryLabel: '返回登入',
                onPrimary: () => context.goNamed(AppRoute.login),
                secondaryLabel: '重新申請',
                onSecondary:
                    () =>
                        ref
                            .read(passwordResetControllerProvider.notifier)
                            .beginRequest(),
              )
              : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PasswordResetIntro(
                      title: '忘記密碼',
                      description: '輸入登入用 Email，我們會寄出 15 分鐘內有效的單次重設連結。',
                      compact:
                          MediaQuery.sizeOf(context).height -
                              MediaQuery.viewInsetsOf(context).bottom <
                          600,
                    ),
                    TextFormField(
                      key: const Key('passwordResetEmailField'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return '請輸入 Email';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return '請輸入有效的 Email';
                        }
                        return null;
                      },
                      onFieldSubmitted:
                          state.isLoading ? null : (_) => _submit(),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage!,
                        key: const Key('passwordResetRequestError'),
                        style: const TextStyle(color: AppColors.registerError),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      key: const Key('passwordResetRequestButton'),
                      onPressed: state.isLoading ? null : _submit,
                      child:
                          state.isLoading
                              ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('寄送重設連結'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoute.login),
                      child: const Text('返回登入'),
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(passwordResetControllerProvider.notifier)
        .request(email: _emailController.text);
  }
}
