import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class EmailVerificationPendingPage extends ConsumerStatefulWidget {
  const EmailVerificationPendingPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<EmailVerificationPendingPage> createState() =>
      _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState
    extends ConsumerState<EmailVerificationPendingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  Timer? _timer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    if (_emailController.text.isNotEmpty) {
      _startCooldown(60);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.registerFormBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 72,
                      color: AppColors.registerPrimary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '請查看你的 Email',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.registerInk,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      '若這個 Email 可使用，我們會寄出驗證信。公開畫面不會揭露會員是否已存在。',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      key: const Key('verificationResendEmailField'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return '請輸入 Email';
                        }
                        if (!email.contains('@')) {
                          return '請輸入正確的 Email';
                        }
                        return null;
                      },
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.errorMessage!,
                        key: const Key('verificationResendError'),
                        style: const TextStyle(color: AppColors.registerError),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      key: const Key('verificationResendButton'),
                      onPressed:
                          state.isLoading || _cooldown > 0 ? null : _resend,
                      child:
                          state.isLoading
                              ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _cooldown > 0 ? '$_cooldown 秒後可重寄' : '重寄驗證信',
                              ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoute.login),
                      child: const Text('返回登入'),
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

  Future<void> _resend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await ref
        .read(authControllerProvider.notifier)
        .requestVerificationEmail(email: _emailController.text.trim());
    if (!mounted) {
      return;
    }
    final retryAfter = ref.read(authControllerProvider).retryAfter;
    _startCooldown(success ? 60 : retryAfter ?? 0);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('驗證信重寄要求已受理')));
    }
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() {
      _cooldown = seconds;
    });
    if (seconds <= 0) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cooldown = 0;
          });
        }
        return;
      }
      setState(() {
        _cooldown--;
      });
    });
  }
}
