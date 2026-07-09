import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_lock_provider.dart';
import '../theme/app_spacing.dart';

enum PasswordLockMode { set, verify }

class PasswordLockPage extends ConsumerStatefulWidget {
  const PasswordLockPage({super.key});

  @override
  ConsumerState<PasswordLockPage> createState() => _PasswordLockPageState();
}

class _PasswordLockPageState extends ConsumerState<PasswordLockPage> {
  final _formKey = GlobalKey<FormState>();
  final _lockPasswordController = TextEditingController();
  final _confirmLockPasswordController = TextEditingController();
  PasswordLockMode _mode = PasswordLockMode.set;
  bool _obscureLockPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _lockPasswordController.dispose();
    _confirmLockPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordLockControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('密碼鎖')),
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
                    Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '設定與驗證四位數密碼鎖',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '密碼鎖會交由後端安全驗證，不會保存在裝置端。',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SegmentedButton<PasswordLockMode>(
                      key: const Key('passwordLockModeSelector'),
                      segments: const [
                        ButtonSegment(
                          value: PasswordLockMode.set,
                          icon: Icon(Icons.edit_outlined),
                          label: Text('設定'),
                        ),
                        ButtonSegment(
                          value: PasswordLockMode.verify,
                          icon: Icon(Icons.verified_user_outlined),
                          label: Text('驗證'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: state.isLoading ? null : _changeMode,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      key: const Key('passwordLockField'),
                      controller: _lockPasswordController,
                      obscureText: _obscureLockPassword,
                      keyboardType: TextInputType.number,
                      textInputAction:
                          _mode == PasswordLockMode.set
                              ? TextInputAction.next
                              : TextInputAction.done,
                      inputFormatters: _pinInputFormatters,
                      decoration: InputDecoration(
                        labelText: '四位數密碼鎖',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        suffixIcon: IconButton(
                          tooltip: _obscureLockPassword ? '顯示密碼鎖' : '隱藏密碼鎖',
                          onPressed: () {
                            setState(() {
                              _obscureLockPassword = !_obscureLockPassword;
                            });
                          },
                          icon: Icon(
                            _obscureLockPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: _validatePin,
                      onFieldSubmitted:
                          _mode == PasswordLockMode.verify && !state.isLoading
                              ? (_) => _submit()
                              : null,
                    ),
                    if (_mode == PasswordLockMode.set) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        key: const Key('passwordLockConfirmField'),
                        controller: _confirmLockPasswordController,
                        obscureText: _obscureConfirmPassword,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: _pinInputFormatters,
                        decoration: InputDecoration(
                          labelText: '再次輸入密碼鎖',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            tooltip:
                                _obscureConfirmPassword ? '顯示確認密碼' : '隱藏確認密碼',
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: _validateConfirmPin,
                        onFieldSubmitted:
                            state.isLoading ? null : (_) => _submit(),
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage!,
                        key: const Key('passwordLockErrorMessage'),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    if (state.verified == false) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '密碼鎖驗證失敗，請再試一次',
                        key: const Key('passwordLockVerifyFailedMessage'),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      key: const Key('passwordLockSubmitButton'),
                      onPressed: state.isLoading ? null : _submit,
                      icon:
                          state.isLoading
                              ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _mode == PasswordLockMode.set
                                    ? Icons.save_outlined
                                    : Icons.check_circle_outline,
                              ),
                      label: Text(
                        state.isLoading
                            ? '處理中'
                            : _mode == PasswordLockMode.set
                            ? '儲存密碼鎖'
                            : '驗證密碼鎖',
                      ),
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

  List<TextInputFormatter> get _pinInputFormatters {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];
  }

  void _changeMode(Set<PasswordLockMode> selectedModes) {
    final nextMode = selectedModes.first;
    setState(() {
      _mode = nextMode;
      _lockPasswordController.clear();
      _confirmLockPasswordController.clear();
    });
  }

  String? _validatePin(String? value) {
    final pin = value?.trim() ?? '';
    if (pin.isEmpty) {
      return '請輸入密碼鎖';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return '密碼鎖需為 4 位數字';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    final validation = _validatePin(value);
    if (validation != null) {
      return validation;
    }
    if (value != _lockPasswordController.text) {
      return '兩次輸入的密碼鎖不一致';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(passwordLockControllerProvider.notifier);
    final success =
        _mode == PasswordLockMode.set
            ? await controller.setPasswordLock(_lockPasswordController.text)
            : await controller.verifyPasswordLock(_lockPasswordController.text);

    if (!mounted) {
      return;
    }

    if (_mode == PasswordLockMode.set && success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密碼鎖已更新')));
      _lockPasswordController.clear();
      _confirmLockPasswordController.clear();
      return;
    }

    if (_mode == PasswordLockMode.verify && success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密碼鎖驗證成功')));
      _lockPasswordController.clear();
    }
  }
}
