import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/google_sign_in_web_button.dart';
import '../models/eligibility_policy.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      final previousResult = previous?.loginResult;
      final nextResult = next.loginResult;
      if (nextResult?.isAuthenticated == true && previousResult != nextResult) {
        context.goNamed(AppRoute.home);
      } else if (nextResult?.requiresGoogleAccountLink == true &&
          previousResult != nextResult) {
        context.goNamed(AppRoute.googleAccountLink);
      } else if (nextResult?.nextAction == 'COMPLETE_ELIGIBILITY' &&
          nextResult?.continuationCredential != null &&
          previousResult != nextResult) {
        context.goNamed(
          AppRoute.eligibility,
          extra: EligibilityRouteData(nextResult!.continuationCredential!),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.loginBrandBackground,
      body: ResponsiveLayout(
        desktop:
            (context, constraints) => Row(
              children: [
                const Expanded(flex: 43, child: _LoginBrandPanel()),
                Expanded(
                  flex: 57,
                  child: ColoredBox(
                    color: AppColors.loginFormBackground,
                    child: SafeArea(
                      child: _ViewportFit(
                        maxWidth: 500,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.xl,
                        ),
                        child: _LoginForm(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          authState: authState,
                          onTogglePassword: _togglePassword,
                          onSubmit: _submit,
                          onSubmitGoogle: _submitGoogle,
                          onForgotPassword: _showForgotPassword,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        tablet:
            (context, constraints) => ColoredBox(
              color: AppColors.loginFormBackground,
              child: SafeArea(
                child: _ViewportFit(
                  maxWidth: 600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.xs,
                  ),
                  child: _buildForm(authState, isMobile: true),
                ),
              ),
            ),
        mobile:
            (context, constraints) => SafeArea(
              child: _ViewportFit(
                maxWidth: 318,
                padding: const EdgeInsets.fromLTRB(36, 46, 36, 48),
                child: _buildForm(authState, isMobile: true),
              ),
            ),
      ),
    );
  }

  Widget _buildForm(AuthState authState, {bool isMobile = false}) {
    return _LoginForm(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      obscurePassword: _obscurePassword,
      authState: authState,
      onTogglePassword: _togglePassword,
      onSubmit: _submit,
      onSubmitGoogle: _submitGoogle,
      onForgotPassword: _showForgotPassword,
      isMobile: isMobile,
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted || !success) {
      return;
    }
  }

  Future<void> _submitGoogle() async {
    final success =
        await ref.read(authControllerProvider.notifier).googleLogin();

    if (!mounted || !success) {
      return;
    }
  }

  void _showForgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('忘記密碼流程將於後續 Task 開放')));
  }
}

class _ViewportFit extends StatelessWidget {
  const _ViewportFit({
    required this.maxWidth,
    required this.padding,
    required this.child,
  });

  final double maxWidth;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth.clamp(0.0, maxWidth);
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(width: contentWidth, child: child),
            ),
          );
        },
      ),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.loginBrandBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(54, 42, 54, 84),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/title.png',
                width: 160,
                semanticLabel: '貘nsters',
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 360,
                  height: 360,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                '歡迎回來。\n怪獸還在這裡等你。',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.loginMuted,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '貘nsters · 陪你整理每一種心情',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.loginMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.authState,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onSubmitGoogle,
    required this.onForgotPassword,
    this.isMobile = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final AuthState authState;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onSubmitGoogle;
  final VoidCallback onForgotPassword;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fieldHeight = isMobile ? 54.0 : 56.0;
    final title = isMobile ? '歡迎回來' : '登入貘nsters';
    final subtitle = isMobile ? '登入後，繼續和怪獸一起整理心情。' : '繼續整理你的心情與私人紀錄。';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile) ...[
            Center(
              child: Image.asset(
                'assets/images/title.png',
                width: 150,
                semanticLabel: '貘nsters',
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            title,
            style: (isMobile
                    ? textTheme.headlineSmall
                    : textTheme.headlineMedium)
                ?.copyWith(
                  color: AppColors.loginInk,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.loginMuted,
              fontSize: isMobile ? 13 : null,
            ),
          ),
          SizedBox(height: isMobile ? 28 : 48),
          const _FieldLabel('Email'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              key: const Key('loginEmailField'),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: _inputDecoration(hintText: ''),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return '請輸入 Email';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return '請輸入有效的 Email';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: isMobile ? 20 : AppSpacing.lg),
          const _FieldLabel('密碼'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              key: const Key('loginPasswordField'),
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              decoration: _inputDecoration(
                hintText: '',
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? '顯示密碼' : '隱藏密碼',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.loginPrimary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入密碼';
                }
                return null;
              },
              onFieldSubmitted: authState.isLoading ? null : (_) => onSubmit(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: authState.isLoading ? null : onForgotPassword,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                foregroundColor: AppColors.loginPrimary,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('忘記密碼？'),
            ),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              authState.errorMessage!,
              key: const Key('loginErrorMessage'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (authState.continuationMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              authState.continuationMessage!,
              key: const Key('loginContinuationMessage'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
          SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),
          SizedBox(
            height: fieldHeight,
            child: FilledButton(
              key: const Key('loginSubmitButton'),
              onPressed: authState.isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.loginPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child:
                  authState.isLoading
                      ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('登入'),
            ),
          ),
          SizedBox(height: isMobile ? 28 : AppSpacing.xl),
          const _DividerLabel(),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.lg),
          _GoogleLoginAction(
            isLoading: authState.isLoading,
            onSubmitGoogle: onSubmitGoogle,
            height: fieldHeight,
          ),
          SizedBox(height: isMobile ? 20 : 40),
          _SessionNote(isMobile: isMobile),
          SizedBox(height: isMobile ? 28 : AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Text(
                '還沒有帳號？',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.loginMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed:
                    authState.isLoading
                        ? null
                        : () => context.pushNamed(AppRoute.register),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.loginPrimary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('建立新帳號'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.loginFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.loginPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.loginMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.loginFieldBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '或',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.loginMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.loginFieldBorder)),
      ],
    );
  }
}

class _GoogleLoginAction extends StatelessWidget {
  const _GoogleLoginAction({
    required this.isLoading,
    required this.onSubmitGoogle,
    required this.height,
  });

  final bool isLoading;
  final VoidCallback onSubmitGoogle;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SizedBox(
        height: height,
        child: const Center(child: GoogleSignInWebButton()),
      );
    }

    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        key: const Key('loginGoogleButton'),
        onPressed: isLoading ? null : onSubmitGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.loginInk,
          side: const BorderSide(color: AppColors.loginFieldBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        icon: const CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Text(
            'G',
            style: TextStyle(
              color: AppColors.googleInitial,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        label: const Text('使用 Google 登入'),
      ),
    );
  }
}

class _SessionNote extends StatelessWidget {
  const _SessionNote({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.loginSessionBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.circle,
                size: 8,
                color: AppColors.loginSessionText,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isMobile
                    ? '未登出且 30 天內再次開啟，\n會直接回到陪伴首頁。'
                    : '未登出且 30 天內再次開啟，會直接回到首頁。',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.loginSessionText,
                  fontWeight: isMobile ? FontWeight.w600 : FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
