import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/responsive_layout.dart';
import '../models/device_session.dart';
import '../providers/auth_provider.dart';
import '../providers/session_management_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/state/error_view.dart';
import '../widgets/state/loading_view.dart';

enum _ReauthenticationAction { one, others, all }

class SessionManagementPage extends ConsumerStatefulWidget {
  const SessionManagementPage({super.key});

  @override
  ConsumerState<SessionManagementPage> createState() =>
      _SessionManagementPageState();
}

class _SessionManagementPageState extends ConsumerState<SessionManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(sessionManagementControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionManagementControllerProvider);
    final page = state.page;
    if (state.isLoading && page == null) {
      return const Scaffold(body: LoadingView(message: '正在讀取登入裝置'));
    }
    if (page == null) {
      return Scaffold(
        body: ErrorView(
          message: state.errorMessage ?? '無法取得登入裝置',
          onRetry:
              () =>
                  ref.read(sessionManagementControllerProvider.notifier).load(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile:
              (context, constraints) => _SessionManagementCanvas(
                page: page,
                compact: true,
                state: state,
                onBack: () => _back(context),
                onPage: _loadPage,
                onRevokeCurrent: _revokeCurrent,
                onRevokeOne:
                    (session) => _requestPassword(
                      _ReauthenticationAction.one,
                      session: session,
                    ),
                onRevokeOthers:
                    () => _requestPassword(_ReauthenticationAction.others),
                onRevokeAll:
                    () => _requestPassword(_ReauthenticationAction.all),
              ),
          tablet:
              (context, constraints) => _SessionManagementCanvas(
                page: page,
                compact: false,
                state: state,
                onBack: () => _back(context),
                onPage: _loadPage,
                onRevokeCurrent: _revokeCurrent,
                onRevokeOne:
                    (session) => _requestPassword(
                      _ReauthenticationAction.one,
                      session: session,
                    ),
                onRevokeOthers:
                    () => _requestPassword(_ReauthenticationAction.others),
                onRevokeAll:
                    () => _requestPassword(_ReauthenticationAction.all),
              ),
          desktop:
              (context, constraints) => _SessionManagementCanvas(
                page: page,
                compact: false,
                state: state,
                onBack: () => _back(context),
                onPage: _loadPage,
                onRevokeCurrent: _revokeCurrent,
                onRevokeOne:
                    (session) => _requestPassword(
                      _ReauthenticationAction.one,
                      session: session,
                    ),
                onRevokeOthers:
                    () => _requestPassword(_ReauthenticationAction.others),
                onRevokeAll:
                    () => _requestPassword(_ReauthenticationAction.all),
              ),
        ),
      ),
    );
  }

  void _loadPage(int page) {
    ref.read(sessionManagementControllerProvider.notifier).load(page: page);
  }

  Future<void> _revokeCurrent() async {
    final confirmed = await _confirm(title: '登出目前裝置？', message: '完成後會回到登入畫面。');
    if (!confirmed || !mounted) return;
    final succeeded =
        await ref
            .read(sessionManagementControllerProvider.notifier)
            .revokeCurrent();
    if (succeeded && mounted) {
      await ref.read(authControllerProvider.notifier).completeRemoteLogout();
      if (mounted) context.goNamed(AppRoute.login);
    }
  }

  Future<void> _requestPassword(
    _ReauthenticationAction action, {
    DeviceSession? session,
  }) async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordReauthenticationDialog(),
    );
    if (password == null || !mounted) return;
    final controller = ref.read(sessionManagementControllerProvider.notifier);
    final succeeded = switch (action) {
      _ReauthenticationAction.one => await controller.revokeOne(
        session!.sessionId,
        password,
      ),
      _ReauthenticationAction.others => await controller.revokeOthers(password),
      _ReauthenticationAction.all => await controller.revokeAll(password),
    };
    if (succeeded && action == _ReauthenticationAction.all && mounted) {
      await ref.read(authControllerProvider.notifier).completeRemoteLogout();
      if (mounted) context.goNamed(AppRoute.login);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('確認登出'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.profile);
    }
  }
}

class _SessionManagementCanvas extends StatelessWidget {
  const _SessionManagementCanvas({
    required this.page,
    required this.compact,
    required this.state,
    required this.onBack,
    required this.onPage,
    required this.onRevokeCurrent,
    required this.onRevokeOne,
    required this.onRevokeOthers,
    required this.onRevokeAll,
  });

  final DeviceSessionPage page;
  final bool compact;
  final SessionManagementState state;
  final VoidCallback onBack;
  final ValueChanged<int> onPage;
  final VoidCallback onRevokeCurrent;
  final ValueChanged<DeviceSession> onRevokeOne;
  final VoidCallback onRevokeOthers;
  final VoidCallback onRevokeAll;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('sessionManagementViewport'),
      color: AppColors.profileBackground,
      child: Column(
        children: [
          SizedBox(
            height: compact ? 58 : 72,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 40),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('sessionManagementBack'),
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '登入裝置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.profileInk,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    key: const Key('revokeCurrentSession'),
                    onPressed: state.isMutating ? null : onRevokeCurrent,
                    child: const Text('登出目前裝置'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SizedBox(
                    width: compact ? constraints.maxWidth : 900,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 16 : 32,
                        compact ? 14 : 24,
                        compact ? 16 : 32,
                        compact ? 10 : 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '查看最近登入的裝置，並登出不再使用的工作階段。',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          if (state.errorMessage != null)
                            _StatusBanner(
                              message: state.errorMessage!,
                              error: true,
                            )
                          else if (state.successMessage != null)
                            _StatusBanner(message: state.successMessage!),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Column(
                              children: [
                                for (final session in page.items) ...[
                                  Expanded(
                                    child: _DeviceSessionCard(
                                      session: session,
                                      disabled: state.isMutating,
                                      onRevoke: () => onRevokeOne(session),
                                    ),
                                  ),
                                  if (session != page.items.last)
                                    const SizedBox(height: 8),
                                ],
                                for (var i = page.items.length; i < 3; i++)
                                  const Spacer(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Pagination(page: page, onPage: onPage),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  key: const Key('revokeOtherSessions'),
                                  onPressed:
                                      state.isMutating ? null : onRevokeOthers,
                                  child: const Text('登出其他裝置'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  key: const Key('revokeAllSessions'),
                                  onPressed:
                                      state.isMutating ? null : onRevokeAll,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.profileError,
                                  ),
                                  child: Text(
                                    state.isMutating ? '處理中' : '登出所有裝置',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceSessionCard extends StatelessWidget {
  const _DeviceSessionCard({
    required this.session,
    required this.disabled,
    required this.onRevoke,
  });

  final DeviceSession session;
  final bool disabled;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final icon = switch (session.deviceType) {
      'ANDROID' => Icons.android,
      'IOS' => Icons.phone_iphone,
      'WEB' => Icons.language,
      _ => Icons.devices_other,
    };
    return Container(
      key: Key('deviceSession-${session.sessionId}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              session.current
                  ? AppColors.profilePrimary
                  : AppColors.profileBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.deviceSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${session.current ? '目前裝置 · ' : ''}最後活動 ${_formatTime(session.lastActivityAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!session.current)
            TextButton(
              onPressed: disabled ? null : onRevoke,
              child: const Text('登出'),
            ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.month}/${value.day} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.page, required this.onPage});

  final DeviceSessionPage page;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('sessionPreviousPage'),
          onPressed: page.page > 0 ? () => onPage(page.page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${page.totalPages == 0 ? 0 : page.page + 1} / ${page.totalPages}',
        ),
        IconButton(
          key: const Key('sessionNextPage'),
          onPressed:
              page.page + 1 < page.totalPages
                  ? () => onPage(page.page + 1)
                  : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFE8E8) : const Color(0xFFE8F7EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _PasswordReauthenticationDialog extends StatefulWidget {
  const _PasswordReauthenticationDialog();

  @override
  State<_PasswordReauthenticationDialog> createState() =>
      _PasswordReauthenticationDialogState();
}

class _PasswordReauthenticationDialogState
    extends State<_PasswordReauthenticationDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('sessionReauthenticationDialog'),
      title: const Text('重新驗證'),
      content: SizedBox(
        width: 360,
        child: TextField(
          key: const Key('sessionReauthenticationPassword'),
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '密碼',
            helperText: '驗證結果僅供 5 分鐘內管理登入裝置',
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('繼續')),
      ],
    );
  }

  void _submit() {
    if (controller.text.isNotEmpty) {
      Navigator.pop(context, controller.text);
    }
  }
}
