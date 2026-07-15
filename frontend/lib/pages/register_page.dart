import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.registerBrandBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          if (isDesktop) {
            return Row(
              children: [
                const Expanded(flex: 43, child: _RegisterBrandPanel()),
                Expanded(
                  flex: 57,
                  child: ColoredBox(
                    color: AppColors.registerFormBackground,
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.xl,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: _RegisterForm(
                              formKey: _formKey,
                              accountController: _accountController,
                              emailController: _emailController,
                              userNameController: _userNameController,
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController,
                              obscurePassword: _obscurePassword,
                              obscureConfirmPassword: _obscureConfirmPassword,
                              authState: authState,
                              onTogglePassword: _togglePassword,
                              onToggleConfirmPassword: _toggleConfirmPassword,
                              onSubmit: _submit,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(36, 46, 36, 48),
              child: _RegisterForm(
                formKey: _formKey,
                accountController: _accountController,
                emailController: _emailController,
                userNameController: _userNameController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                obscurePassword: _obscurePassword,
                obscureConfirmPassword: _obscureConfirmPassword,
                authState: authState,
                onTogglePassword: _togglePassword,
                onToggleConfirmPassword: _toggleConfirmPassword,
                onSubmit: _submit,
                isMobile: true,
              ),
            ),
          );
        },
      ),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  String? _validateAccount(String? value) {
    final account = value?.trim() ?? '';
    if (account.isEmpty) {
      return '請輸入帳號';
    }
    if (account.length < 4) {
      return '帳號至少 4 個字';
    }
    if (account.length > 50) {
      return '帳號最多 50 個字';
    }
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(account)) {
      return '帳號需英文開頭，且只能使用英文、數字、底線';
    }
    return null;
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

  String? _validateUserName(String? value) {
    final userName = value?.trim() ?? '';
    if (userName.isEmpty) {
      return '請輸入暱稱';
    }
    if (userName.length > 80) {
      return '暱稱最多 80 個字';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return '請輸入密碼';
    }
    if (password.length < 8) {
      return '密碼至少 8 個字';
    }
    if (password.length > 72) {
      return '密碼最多 72 個字';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請再次輸入密碼';
    }
    if (value != _passwordController.text) {
      return '兩次輸入的密碼不一致';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          account: _accountController.text.trim().toLowerCase(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
          userName: _userNameController.text.trim(),
        );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('註冊成功，請登入')));
    context.goNamed(AppRoute.login);
  }
}

class _RegisterBrandPanel extends StatelessWidget {
  const _RegisterBrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.registerBrandBackground,
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
                '一起建立新的陪伴起點。\n怪獸會記得你的名字。',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.registerAccentText,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '貘nsters · 陪你整理每一種心情',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.registerMuted,
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

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.accountController,
    required this.emailController,
    required this.userNameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.authState,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    this.isMobile = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountController;
  final TextEditingController emailController;
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final AuthState authState;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fieldHeight = isMobile ? 54.0 : 56.0;

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
            '建立新帳號',
            style: (isMobile
                    ? textTheme.headlineSmall
                    : textTheme.headlineMedium)
                ?.copyWith(
                  color: AppColors.registerInk,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isMobile ? '建立帳號後，開始整理你的心情紀錄。' : '加入貘nsters，開始整理每一天的心情。',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.registerMuted,
              fontSize: isMobile ? 13 : null,
            ),
          ),
          SizedBox(height: isMobile ? 28 : 40),
          _RegisterTextField(
            label: '帳號',
            height: fieldHeight,
            child: TextFormField(
              key: const Key('registerAccountField'),
              controller: accountController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: _inputDecoration(hintText: 'weicho_lin'),
              validator: _RegisterValidators.of(context).account,
            ),
          ),
          SizedBox(height: isMobile ? 18 : AppSpacing.md),
          _RegisterTextField(
            label: 'Email',
            height: fieldHeight,
            child: TextFormField(
              key: const Key('registerEmailField'),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: _inputDecoration(hintText: 'user@example.com'),
              validator: _RegisterValidators.of(context).email,
            ),
          ),
          SizedBox(height: isMobile ? 18 : AppSpacing.md),
          _RegisterTextField(
            label: '暱稱',
            height: fieldHeight,
            child: TextFormField(
              key: const Key('registerUserNameField'),
              controller: userNameController,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.nickname],
              decoration: _inputDecoration(hintText: 'Wei'),
              validator: _RegisterValidators.of(context).userName,
            ),
          ),
          SizedBox(height: isMobile ? 18 : AppSpacing.md),
          _RegisterTextField(
            label: '密碼',
            height: fieldHeight,
            child: TextFormField(
              key: const Key('registerPasswordField'),
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _inputDecoration(
                hintText: '至少 8 個字',
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? '顯示密碼' : '隱藏密碼',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.registerPrimary,
                  ),
                ),
              ),
              validator: _RegisterValidators.of(context).password,
            ),
          ),
          SizedBox(height: isMobile ? 18 : AppSpacing.md),
          _RegisterTextField(
            label: '確認密碼',
            height: fieldHeight,
            child: TextFormField(
              key: const Key('registerConfirmPasswordField'),
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _inputDecoration(
                hintText: '再次輸入密碼',
                suffixIcon: IconButton(
                  tooltip: obscureConfirmPassword ? '顯示密碼' : '隱藏密碼',
                  onPressed: onToggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.registerPrimary,
                  ),
                ),
              ),
              validator: _RegisterValidators.of(context).confirmPassword,
              onFieldSubmitted: authState.isLoading ? null : (_) => onSubmit(),
            ),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              authState.errorMessage!,
              key: const Key('registerErrorMessage'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          SizedBox(height: isMobile ? 24 : AppSpacing.lg),
          SizedBox(
            height: fieldHeight,
            child: FilledButton(
              key: const Key('registerSubmitButton'),
              onPressed: authState.isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.registerPrimary,
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
                      : const Text('建立帳號'),
            ),
          ),
          SizedBox(height: isMobile ? 24 : AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.registerHintBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(
                '帳號需英文開頭，可使用英文、數字、底線。註冊成功後請回登入頁登入。',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.registerHintText,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 24 : AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Text(
                '已經有帳號？',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.registerMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed:
                    authState.isLoading
                        ? null
                        : () => context.goNamed(AppRoute.login),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.registerPrimary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('前往登入'),
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
        borderSide: const BorderSide(color: AppColors.registerFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.registerPrimary,
          width: 2,
        ),
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

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.label,
    required this.height,
    required this.child,
  });

  final String label;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.registerMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(height: height, child: child),
      ],
    );
  }
}

class _RegisterValidators {
  const _RegisterValidators._(this.state);

  final _RegisterPageState state;

  static _RegisterValidators of(BuildContext context) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    if (state == null) {
      throw StateError('Register validators require RegisterPage state.');
    }
    return _RegisterValidators._(state);
  }

  String? account(String? value) => state._validateAccount(value);

  String? email(String? value) => state._validateEmail(value);

  String? userName(String? value) => state._validateUserName(value);

  String? password(String? value) => state._validatePassword(value);

  String? confirmPassword(String? value) =>
      state._validateConfirmPassword(value);
}
