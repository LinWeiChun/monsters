import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/google_sign_in_web_button.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(authControllerProvider, (previous, next) {
      final previousResult = previous?.loginResult;
      final nextResult = next.loginResult;
      if (nextResult != null && previousResult != nextResult) {
        context.goNamed(AppRoute.home);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 220,
                        semanticLabel: '貘nsters',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '貘nsters',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '登入後開始記錄心情與煩惱',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      key: const Key('loginEmailField'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      key: const Key('loginPasswordField'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: '密碼',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? '顯示密碼' : '隱藏密碼',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted:
                          authState.isLoading ? null : (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            authState.isLoading ? null : _showForgotPassword,
                        child: const Text('忘記密碼'),
                      ),
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        authState.errorMessage!,
                        key: const Key('loginErrorMessage'),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      key: const Key('loginSubmitButton'),
                      onPressed: authState.isLoading ? null : _submit,
                      child:
                          authState.isLoading
                              ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('登入'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (kIsWeb)
                      const Center(child: GoogleSignInWebButton())
                    else
                      OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : _submitGoogle,
                        icon: const Icon(Icons.account_circle_outlined),
                        label: const Text('使用 Google 登入'),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed:
                          authState.isLoading
                              ? null
                              : () => context.goNamed(AppRoute.register),
                      child: const Text('還沒有帳號？前往註冊'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return '請輸入 Email';
    }
    if (!email.contains('@')) {
      return '請輸入有效的 Email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
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
    ).showSnackBar(const SnackBar(content: Text('忘記密碼頁將於後續 Task 建立')));
  }
}
