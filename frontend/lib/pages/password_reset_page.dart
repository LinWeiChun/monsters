import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/password_reset_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/password_reset_shell.dart';
import '../widgets/auth/password_reset_intro.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _beginCompletion();
  }

  @override
  void didUpdateWidget(covariant PasswordResetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _formKey.currentState?.reset();
      _passwordController.clear();
      _confirmationController.clear();
      _obscurePassword = true;
      _obscureConfirmation = true;
      _beginCompletion();
    }
  }

  void _beginCompletion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(passwordResetControllerProvider.notifier).beginCompletion();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetControllerProvider);
    return PasswordResetShell(child: _content(state));
  }

  Widget _content(PasswordResetState state) {
    if (widget.token.isEmpty ||
        state.stage == PasswordResetStage.invalid ||
        state.stage == PasswordResetStage.expired ||
        state.stage == PasswordResetStage.used) {
      return PasswordResetStatus(
        icon: Icons.link_off_outlined,
        title:
            state.stage == PasswordResetStage.expired ? '重設連結已過期' : '無法使用此連結',
        message: state.errorMessage ?? '重設連結無效或不完整，請重新申請。',
        primaryLabel: '重新申請',
        onPrimary: () => context.goNamed(AppRoute.passwordResetRequest),
        secondaryLabel: '返回登入',
        onSecondary: () => context.goNamed(AppRoute.login),
      );
    }
    if (state.stage == PasswordResetStage.completed) {
      return PasswordResetStatus(
        icon: Icons.lock_reset_outlined,
        title: '密碼重設完成',
        message: '所有已登入裝置都已失效。請使用新密碼重新登入。',
        primaryLabel: '重新登入',
        onPrimary: () => context.goNamed(AppRoute.login),
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordResetIntro(
            title: '設定新密碼',
            description: '密碼需為 15–128 個字元，可使用空白與 Emoji。',
            compact:
                MediaQuery.sizeOf(context).height -
                    MediaQuery.viewInsetsOf(context).bottom <
                600,
          ),
          TextFormField(
            key: const Key('newPasswordField'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: '新密碼',
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? '顯示密碼' : '隱藏密碼',
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const Key('confirmNewPasswordField'),
            controller: _confirmationController,
            obscureText: _obscureConfirmation,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: '確認新密碼',
              suffixIcon: IconButton(
                tooltip: _obscureConfirmation ? '顯示確認密碼' : '隱藏確認密碼',
                onPressed:
                    () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '請再次輸入新密碼';
              }
              if (value != _passwordController.text) {
                return '兩次輸入的密碼不一致';
              }
              return null;
            },
            onFieldSubmitted: state.isLoading ? null : (_) => _submit(),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              state.errorMessage!,
              key: const Key('passwordResetCompletionError'),
              style: const TextStyle(color: AppColors.registerError),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            key: const Key('passwordResetCompletionButton'),
            onPressed: state.isLoading ? null : _submit,
            child:
                state.isLoading
                    ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('重設密碼'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.goNamed(AppRoute.login),
            child: const Text('取消並返回登入'),
          ),
        ],
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入新密碼';
    }
    // Backend applies NFC before counting Unicode code points (Task 04).
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(passwordResetControllerProvider.notifier)
        .complete(token: widget.token, newPassword: _passwordController.text);
  }
}
