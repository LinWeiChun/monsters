import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_exception.dart';
import '../providers/member_data_provider.dart';
import '../routes/app_routes.dart';

class EmailChangePage extends ConsumerStatefulWidget {
  const EmailChangePage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<EmailChangePage> createState() => _EmailChangePageState();
}

class _EmailChangePageState extends ConsumerState<EmailChangePage> {
  bool _loading = true;
  bool _success = false;
  String? _message;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_complete);
  }

  @override
  void didUpdateWidget(covariant EmailChangePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      _loading = true;
      _success = false;
      _message = null;
      _complete();
    }
  }

  Future<void> _complete() async {
    if (!mounted) return;
    final requestId = ++_requestId;
    if (widget.token.isEmpty) {
      setState(() {
        _loading = false;
        _message = 'Email 驗證連結無效';
      });
      return;
    }
    try {
      await ref
          .read(memberDataRepositoryProvider)
          .completeEmailChange(token: widget.token);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _success = true;
        _message = 'Email 已完成變更';
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _message = switch (error.code) {
          'EMAIL_CHANGE_TOKEN_EXPIRED' => 'Email 驗證連結已過期',
          'EMAIL_CHANGE_TOKEN_USED' => 'Email 驗證連結已使用',
          _ => 'Email 驗證連結無效',
        };
      });
    } on Object {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _message = '目前無法完成 Email 變更，請稍後再試';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MemberStatusScaffold(
      title: _loading ? '正在驗證 Email' : _message!,
      description:
          _loading
              ? '請稍候，系統正在確認單次驗證連結。'
              : _success
              ? '其他裝置的登入狀態已更新；下次登入請使用新 Email。'
              : '請回個人資料確認目前 Email，必要時重新申請。',
      icon:
          _loading
              ? '…'
              : _success
              ? '✓'
              : '!',
      success: _success,
      loading: _loading,
      buttonLabel: _success ? '前往登入' : '回到登入',
      onPressed: _loading ? null : () => context.goNamed(AppRoute.login),
    );
  }
}

class _MemberStatusScaffold extends StatelessWidget {
  const _MemberStatusScaffold({
    required this.title,
    required this.description,
    required this.icon,
    required this.success,
    required this.buttonLabel,
    required this.onPressed,
    this.loading = false,
  });

  final String title;
  final String description;
  final String icon;
  final bool success;
  final bool loading;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = success ? const Color(0xFF6F9271) : const Color(0xFFB4493F);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE9DDD4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(38),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loading)
                        const CircularProgressIndicator()
                      else
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          child: Text(
                            icon,
                            style: TextStyle(
                              color: accent,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(description, textAlign: TextAlign.center),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: onPressed,
                        child: Text(buttonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
