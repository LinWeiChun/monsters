import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_exception.dart';
import '../providers/auth_provider.dart';
import '../providers/member_data_provider.dart';
import '../routes/app_routes.dart';

class MemberRestorationRouteData {
  const MemberRestorationRouteData(this.continuationCredential);

  final String continuationCredential;
}

class MemberRestorationPage extends ConsumerStatefulWidget {
  const MemberRestorationPage({
    super.key,
    required this.continuationCredential,
  });

  final String continuationCredential;

  @override
  ConsumerState<MemberRestorationPage> createState() =>
      _MemberRestorationPageState();
}

class _MemberRestorationPageState extends ConsumerState<MemberRestorationPage> {
  bool _confirmed = false;
  bool _loading = false;
  bool _restored = false;
  String? _error;

  Future<void> _restore() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(memberDataRepositoryProvider)
          .restore(continuationCredential: widget.continuationCredential);
      await ref.read(authControllerProvider.notifier).completeRemoteLogout();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _restored = true;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            error.code == 'MEMBER_RESTORATION_CONTINUATION_INVALID'
                ? '恢復驗證已過期，請重新登入'
                : error.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '目前無法恢復帳號，請稍後再試';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.continuationCredential.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F1E8),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Material(
                  color: const Color(0xFFFFFDFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Color(0xFFE9DDD4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '恢復驗證已失效',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('請重新登入，再進入恢復帳號流程。'),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.goNamed(AppRoute.login),
                          child: const Text('回到登入'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Material(
                color: const Color(0xFFFFFDFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE9DDD4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _restored ? '帳號已恢復' : '恢復你的帳號',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _restored
                            ? '請重新登入以建立新的安全 Session。先前取消的分享仍維持關閉。'
                            : '登入驗證已完成。恢復後不會直接進入私人頁面，也不會重新公開先前內容。',
                        textAlign: TextAlign.center,
                      ),
                      if (!_restored) ...[
                        const SizedBox(height: 20),
                        CheckboxListTile(
                          key: const Key('memberRestorationConfirmation'),
                          value: _confirmed,
                          title: const Text('我了解恢復後需要重新登入'),
                          onChanged:
                              _loading
                                  ? null
                                  : (value) => setState(
                                    () => _confirmed = value ?? false,
                                  ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFB4493F)),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        key: const Key('memberRestorationSubmit'),
                        onPressed:
                            _restored
                                ? () => context.goNamed(AppRoute.login)
                                : _confirmed && !_loading
                                ? _restore
                                : null,
                        child: Text(
                          _loading
                              ? '正在恢復…'
                              : _restored
                              ? '重新登入'
                              : '確認恢復',
                        ),
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
