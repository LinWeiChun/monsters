import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/google_sign_in_web_button.dart';

class GoogleAccountLinkPage extends ConsumerStatefulWidget {
  const GoogleAccountLinkPage({super.key});

  @override
  ConsumerState<GoogleAccountLinkPage> createState() =>
      _GoogleAccountLinkPageState();
}

class _GoogleAccountLinkPageState extends ConsumerState<GoogleAccountLinkPage> {
  final _existingAccountFormKey = GlobalKey<FormState>();
  final _reauthenticationFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reauthenticationPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureReauthenticationPassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).initializeGoogleSignIn(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _reauthenticationPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final stage = state.googleLinkStage ?? GoogleLinkStage.required;

    return Scaffold(
      backgroundColor: AppColors.loginBrandBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 48.0 : 24.0;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.loginFormBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.loginFieldBorder),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        constraints.maxWidth >= 600
                            ? AppSpacing.xxl
                            : AppSpacing.lg,
                      ),
                      child: _stageContent(stage, state),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stageContent(GoogleLinkStage stage, AuthState state) {
    return switch (stage) {
      GoogleLinkStage.required => _existingAccountStage(state),
      GoogleLinkStage.reauthentication => _reauthenticationStage(state),
      GoogleLinkStage.confirmation => _confirmationStage(state),
      GoogleLinkStage.linked => _linkedStage(),
      GoogleLinkStage.conflict => _conflictStage(state),
    };
  }

  Widget _existingAccountStage(AuthState state) {
    return Form(
      key: _existingAccountFormKey,
      child: Column(
        key: const Key('googleLinkRequiredStage'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StageHeader(
            icon: Icons.link,
            title: '需要連結既有帳號',
            description: '這個 Google Email 已有貘nsters 帳號。請先登入原本帳號；系統不會自動合併。',
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            key: const Key('googleLinkEmailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(label: 'Email'),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return '請輸入 Email';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return '請輸入有效的 Email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const Key('googleLinkPasswordField'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              label: '密碼',
              suffixIcon: IconButton(
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator:
                (value) => value == null || value.isEmpty ? '請輸入密碼' : null,
            onFieldSubmitted: state.isLoading ? null : (_) => _loginExisting(),
          ),
          _error(state),
          const SizedBox(height: AppSpacing.lg),
          _primaryButton(
            key: const Key('googleLinkExistingLoginButton'),
            label: '登入既有帳號',
            loading: state.isLoading,
            onPressed: _loginExisting,
          ),
          const SizedBox(height: AppSpacing.sm),
          _cancelButton(state),
        ],
      ),
    );
  }

  Widget _reauthenticationStage(AuthState state) {
    return Form(
      key: _reauthenticationFormKey,
      child: Column(
        key: const Key('googleLinkReauthenticationStage'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StageHeader(
            icon: Icons.verified_user_outlined,
            title: '重新驗證原本登入方式',
            description: '請再次輸入目前密碼。驗證結果只可用於連結 Google，並在 5 分鐘後失效。',
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            key: const Key('googleLinkReauthenticationPasswordField'),
            controller: _reauthenticationPasswordController,
            obscureText: _obscureReauthenticationPassword,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              label: '目前密碼',
              suffixIcon: IconButton(
                onPressed:
                    () => setState(
                      () =>
                          _obscureReauthenticationPassword =
                              !_obscureReauthenticationPassword,
                    ),
                icon: Icon(
                  _obscureReauthenticationPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator:
                (value) => value == null || value.isEmpty ? '請輸入目前密碼' : null,
            onFieldSubmitted: state.isLoading ? null : (_) => _reauthenticate(),
          ),
          _error(state),
          const SizedBox(height: AppSpacing.lg),
          _primaryButton(
            key: const Key('googleLinkReauthenticateButton'),
            label: '驗證並繼續',
            loading: state.isLoading,
            onPressed: _reauthenticate,
          ),
          const SizedBox(height: AppSpacing.sm),
          _cancelButton(state),
        ],
      ),
    );
  }

  Widget _confirmationStage(AuthState state) {
    return Column(
      key: const Key('googleLinkConfirmationStage'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StageHeader(
          icon: Icons.g_mobiledata,
          title: '確認連結 Google',
          description: '確認後，Google 將成為這個會員的登入方式。目前裝置保持登入，其他裝置會被登出。',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SafetyNote(text: '取消不會建立連結，也不會把 Google 身分合併到任何其他會員。'),
        _error(state),
        const SizedBox(height: AppSpacing.lg),
        if (kIsWeb)
          const SizedBox(
            height: 56,
            child: Center(child: GoogleSignInWebButton()),
          )
        else
          _primaryButton(
            key: const Key('googleLinkConfirmButton'),
            label: '確認連結 Google',
            loading: state.isLoading,
            onPressed: _confirm,
          ),
        const SizedBox(height: AppSpacing.sm),
        _cancelButton(state),
      ],
    );
  }

  Widget _linkedStage() {
    return Column(
      key: const Key('googleLinkSuccessStage'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StageHeader(
          icon: Icons.check_circle_outline,
          title: 'Google 已連結',
          description: '目前裝置保持登入；其他裝置已依安全規則登出。之後可使用 Google 登入這個會員。',
        ),
        const SizedBox(height: AppSpacing.xl),
        _primaryButton(
          key: const Key('googleLinkHomeButton'),
          label: '回到首頁',
          loading: false,
          onPressed: () => context.goNamed(AppRoute.home),
        ),
      ],
    );
  }

  Widget _conflictStage(AuthState state) {
    return Column(
      key: const Key('googleLinkConflictStage'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StageHeader(
          icon: Icons.error_outline,
          title: '無法連結這個 Google 帳號',
          description: '沒有變更登入方式，也沒有自動合併帳號。請確認選擇正確的 Google 帳號後再試。',
        ),
        _error(state),
        const SizedBox(height: AppSpacing.lg),
        _primaryButton(
          key: const Key('googleLinkRestartButton'),
          label: '重新驗證',
          loading: state.isLoading,
          onPressed:
              () =>
                  ref
                      .read(authControllerProvider.notifier)
                      .restartGoogleAccountLink(),
        ),
        const SizedBox(height: AppSpacing.sm),
        _cancelButton(state),
      ],
    );
  }

  Widget _error(AuthState state) {
    final message = state.errorMessage;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        message,
        key: const Key('googleLinkErrorMessage'),
        style: const TextStyle(color: AppColors.profileError),
      ),
    );
  }

  Widget _primaryButton({
    required Key key,
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        key: key,
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.loginPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child:
            loading
                ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(label),
      ),
    );
  }

  Widget _cancelButton(AuthState state) {
    return TextButton(
      key: const Key('googleLinkCancelButton'),
      onPressed: state.isLoading ? null : _cancel,
      child: const Text('取消連結'),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.loginFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.loginPrimary, width: 2),
      ),
    );
  }

  Future<void> _loginExisting() async {
    if (_existingAccountFormKey.currentState?.validate() != true) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .loginExistingAccountForGoogleLink(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (success) _passwordController.clear();
  }

  Future<void> _reauthenticate() async {
    if (_reauthenticationFormKey.currentState?.validate() != true) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .reauthenticateGoogleLink(
          password: _reauthenticationPasswordController.text,
        );
    if (success) _reauthenticationPasswordController.clear();
  }

  Future<void> _confirm() async {
    await ref.read(authControllerProvider.notifier).confirmGoogleAccountLink();
  }

  Future<void> _cancel() async {
    final authenticated =
        await ref
            .read(authControllerProvider.notifier)
            .cancelGoogleAccountLink();
    if (!mounted) return;
    context.goNamed(authenticated ? AppRoute.home : AppRoute.login);
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 42, color: AppColors.loginPrimary),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.loginInk,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.loginMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.loginSessionBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.loginSessionText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
