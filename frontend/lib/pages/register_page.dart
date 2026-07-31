import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../models/registration_policy.dart';
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
  static const _desktopFormWidth = 520.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).loadRegistrationPolicy(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.registerBrandBackground,
      body: ResponsiveLayout(
        mobile:
            (context, constraints) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _buildForm(
                      authState,
                      isMobile: true,
                      compactHeight:
                          constraints.maxHeight < 700 ||
                          MediaQuery.viewInsetsOf(context).bottom > 0,
                    ),
                  ),
                ),
              ),
            ),
        tablet:
            (context, constraints) => _RegisterCompactLayout(
              form: _buildForm(
                authState,
                compactHeight:
                    constraints.maxHeight < 760 ||
                    MediaQuery.viewInsetsOf(context).bottom > 0,
              ),
            ),
        desktop:
            (context, constraints) => Row(
              children: [
                const Expanded(flex: 43, child: _RegisterBrandPanel()),
                Expanded(
                  flex: 57,
                  child: ColoredBox(
                    color: AppColors.registerFormBackground,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _desktopFormWidth,
                            ),
                            child: _buildForm(
                              authState,
                              isDesktop: true,
                              compactHeight:
                                  constraints.maxHeight < 760 ||
                                  MediaQuery.viewInsetsOf(context).bottom > 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildForm(
    AuthState authState, {
    bool isDesktop = false,
    bool isMobile = false,
    bool compactHeight = false,
  }) {
    return _RegisterForm(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      obscurePassword: _obscurePassword,
      obscureConfirmPassword: _obscureConfirmPassword,
      authState: authState,
      onTogglePassword: _togglePassword,
      onToggleConfirmPassword: _toggleConfirmPassword,
      policy: authState.registrationPolicy,
      termsAccepted: _termsAccepted,
      privacyAccepted: _privacyAccepted,
      onTermsChanged:
          (value) => setState(() {
            _termsAccepted = value ?? false;
            _localError = null;
          }),
      onPrivacyChanged:
          (value) => setState(() {
            _privacyAccepted = value ?? false;
            _localError = null;
          }),
      localError: _localError,
      onSubmit: _submit,
      isDesktop: isDesktop,
      isMobile: isMobile,
      compactHeight: compactHeight,
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

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return '請輸入 Email';
    }
    if (!email.contains('@')) {
      return '請輸入正確的 Email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return '請輸入密碼';
    }
    final codePointCount = password.runes.length;
    if (codePointCount < 15) {
      return '密碼至少需要 15 個字元';
    }
    if (codePointCount > 128) {
      return '密碼最多可有 128 個字元';
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
    final formValid = _formKey.currentState!.validate();
    final policy = ref.read(authControllerProvider).registrationPolicy;
    if (policy == null) {
      setState(() {
        _localError = '目前無法載入註冊條款，請稍後再試';
      });
      return;
    }
    if (!_termsAccepted || !_privacyAccepted) {
      setState(() {
        _localError = '請同意目前的服務條款與隱私權政策';
      });
    }
    if (!formValid || !_termsAccepted || !_privacyAccepted) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
          acceptedTermsVersion: policy.termsVersion,
          acceptedPrivacyVersion: policy.privacyVersion,
        );

    if (!mounted || !success) {
      return;
    }

    context.goNamed(
      AppRoute.emailVerificationPending,
      extra: _emailController.text.trim().toLowerCase(),
    );
  }
}

class _RegisterBrandPanel extends StatelessWidget {
  const _RegisterBrandPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.registerBrandBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(54, 42, 54, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/title.png',
                width: 160,
                height: 50,
                fit: BoxFit.contain,
                semanticLabel: '貘nsters',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 360,
                    height: 360,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '從 Email 驗證開始，\n把每一天好好收進來。',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.registerAccentText,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '貘nsters · 陪你整理每一種心情',
                style: textTheme.bodySmall?.copyWith(
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

class _RegisterCompactLayout extends StatelessWidget {
  const _RegisterCompactLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.registerFormBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: form,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.authState,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.policy,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.localError,
    required this.onSubmit,
    this.isDesktop = false,
    this.isMobile = false,
    this.compactHeight = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final AuthState authState;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final RegistrationPolicy? policy;
  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<bool?> onPrivacyChanged;
  final String? localError;
  final VoidCallback onSubmit;
  final bool isDesktop;
  final bool isMobile;
  final bool compactHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fieldHeight = isMobile ? 48.0 : 50.0;
    const fieldGap = 8.0;
    const labelGap = 4.0;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed:
                    authState.isLoading ? null : () => _returnToLogin(context),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.registerPrimary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('‹  返回登入'),
              ),
            ),
            SizedBox(height: compactHeight ? 8 : 12),
          ],
          if (isMobile && !compactHeight) ...[
            Center(
              child: Image.asset(
                'assets/images/title.png',
                width: 100,
                semanticLabel: '貘nsters',
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            isMobile ? '開始你的陪伴旅程' : '建立新帳號',
            style: (isMobile
                    ? textTheme.headlineSmall
                    : textTheme.headlineMedium)
                ?.copyWith(
                  color: AppColors.registerInk,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          if (!compactHeight) ...[
            const SizedBox(height: 4),
            Text(
              '送出後請前往 Email 信箱完成驗證。',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.registerMuted,
                fontSize: isMobile ? 13 : null,
              ),
            ),
          ],
          SizedBox(height: compactHeight ? 8 : 12),
          _RegisterTextField(
            label: 'Email',
            height: fieldHeight,
            labelGap: labelGap,
            child: TextFormField(
              key: const Key('registerEmailField'),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: _registerInputDecoration(
                hintText: 'name@example.com',
              ),
              validator: _RegisterValidators.of(context).email,
            ),
          ),
          const SizedBox(height: fieldGap),
          _RegisterTextField(
            label: '密碼',
            height: fieldHeight,
            labelGap: labelGap,
            child: TextFormField(
              key: const Key('registerPasswordField'),
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _registerInputDecoration(
                hintText: '••••••••',
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
          const SizedBox(height: fieldGap),
          _RegisterTextField(
            label: '確認密碼',
            height: fieldHeight,
            labelGap: labelGap,
            child: TextFormField(
              key: const Key('registerConfirmPasswordField'),
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _registerInputDecoration(
                hintText: '••••••••',
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
          const SizedBox(height: 8),
          if (policy != null)
            _RegistrationPolicyCard(
              policy: policy!,
              termsAccepted: termsAccepted,
              privacyAccepted: privacyAccepted,
              onTermsChanged: onTermsChanged,
              onPrivacyChanged: onPrivacyChanged,
            )
          else if (authState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            const Text('目前無法載入註冊條款，請稍後再試'),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              authState.errorMessage!,
              key: const Key('registerErrorMessage'),
              style: const TextStyle(color: AppColors.registerError),
            ),
          ],
          if (localError != null) ...[
            const SizedBox(height: 4),
            Text(
              localError!,
              key: const Key('registerLocalErrorMessage'),
              style: const TextStyle(color: AppColors.registerError),
            ),
          ],
          if (!compactHeight) ...[
            const SizedBox(height: 8),
            _RegisterRuleCard(isMobile: isMobile),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: fieldHeight,
            child: FilledButton(
              key: const Key('registerSubmitButton'),
              onPressed:
                  authState.isLoading || policy == null ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.registerPrimary,
                foregroundColor: AppColors.registerOnPrimary,
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
                          color: AppColors.registerOnPrimary,
                        ),
                      )
                      : const Text('完成註冊'),
            ),
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              children: [
                Text(
                  '已有帳號？',
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
                          : () => _returnToLogin(context),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.registerPrimary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('返回登入'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

InputDecoration _registerInputDecoration({
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.registerFieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.registerFieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.registerPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.registerError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.registerError, width: 2),
    ),
  );
}

class _RegisterRuleCard extends StatelessWidget {
  const _RegisterRuleCard({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.registerRuleBackground,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppSpacing.md : 18,
          vertical: 8,
        ),
        child: Text(
          isMobile
              ? '第一步只需要 Email 與密碼\n暱稱、生日與資格資料將於驗證後填寫'
              : '第一步只需要 Email 與密碼　·　其他資格資料將於驗證後填寫',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.registerMuted,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _RegistrationPolicyCard extends StatelessWidget {
  const _RegistrationPolicyCard({
    required this.policy,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  final RegistrationPolicy policy;
  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<bool?> onPrivacyChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.registerRuleBackground,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PolicyAcceptanceRow(
              checkboxKey: const Key('termsAcceptanceCheckbox'),
              buttonKey: const Key('showTermsDialogButton'),
              label: '我同意目前的服務條款',
              buttonLabel: '查看',
              value: termsAccepted,
              onChanged: onTermsChanged,
              onShow:
                  () => _showPolicyDialog(
                    context,
                    title: '服務條款',
                    version: policy.termsVersion,
                    url: policy.termsUrl,
                  ),
            ),
            _PolicyAcceptanceRow(
              checkboxKey: const Key('privacyAcceptanceCheckbox'),
              buttonKey: const Key('showPrivacyDialogButton'),
              label: '我同意目前的隱私權政策',
              buttonLabel: '查看',
              value: privacyAccepted,
              onChanged: onPrivacyChanged,
              onShow:
                  () => _showPolicyDialog(
                    context,
                    title: '隱私權政策',
                    version: policy.privacyVersion,
                    url: policy.privacyUrl,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyAcceptanceRow extends StatelessWidget {
  const _PolicyAcceptanceRow({
    required this.checkboxKey,
    required this.buttonKey,
    required this.label,
    required this.buttonLabel,
    required this.value,
    required this.onChanged,
    required this.onShow,
  });

  final Key checkboxKey;
  final Key buttonKey;
  final String label;
  final String buttonLabel;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              key: checkboxKey,
              value: value,
              onChanged: onChanged,
            ),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            key: buttonKey,
            onPressed: onShow,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

Future<void> _showPolicyDialog(
  BuildContext context, {
  required String title,
  required String version,
  required String url,
}) async {
  final scrollController = ScrollController();
  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 560,
            height: 360,
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('版本：$version'),
                    const SizedBox(height: AppSpacing.md),
                    const Text('請透過以下官方網址閱讀此版本的完整內容：'),
                    const SizedBox(height: AppSpacing.sm),
                    SelectableText(url),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              key: const Key('closePolicyDialogButton'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('關閉'),
            ),
          ],
        ),
  );
  scrollController.dispose();
}

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.label,
    required this.height,
    required this.labelGap,
    required this.child,
  });

  final String label;
  final double height;
  final double labelGap;
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
        SizedBox(height: labelGap),
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

  String? email(String? value) => state._validateEmail(value);

  String? password(String? value) => state._validatePassword(value);

  String? confirmPassword(String? value) =>
      state._validateConfirmPassword(value);
}

void _returnToLogin(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.goNamed(AppRoute.login);
}
