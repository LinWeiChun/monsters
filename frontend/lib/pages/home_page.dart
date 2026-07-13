import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';
import '../widgets/home/companion_hero.dart';
import '../widgets/home/home_navigation.dart';
import '../widgets/home/home_quick_action.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(
      authControllerProvider.select(
        (state) => state.loginResult?.user.userName.trim(),
      ),
    );
    final greetingName = userName == null || userName.isEmpty ? '你' : userName;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return _DesktopHome(
            greetingName: greetingName,
            onLogout: () => _logout(context, ref),
          );
        }
        return _MobileHome(
          greetingName: greetingName,
          onLogout: () => _logout(context, ref),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      context.goNamed(AppRoute.login);
    }
  }
}

class _MobileHome extends StatelessWidget {
  const _MobileHome({required this.greetingName, required this.onLogout});

  final String greetingName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/app_logo.png',
          height: 42,
          semanticLabel: '貘nsters',
        ),
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            key: const Key('homeAccountMenu'),
            tooltip: '個人選單',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (action) => _handleMenuAction(context, action),
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: _HomeMenuAction.profile,
                    child: Text('個人資料'),
                  ),
                  PopupMenuItem(
                    value: _HomeMenuAction.passwordLock,
                    child: Text('密碼鎖'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: _HomeMenuAction.logout,
                    child: Text('登出'),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CompanionHero(
                    key: const Key('mobileCompanionHero'),
                    greetingName: greetingName,
                    compact: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: const Key('homeAnnoyanceChatButton'),
                    onPressed: () => context.goNamed(AppRoute.annoyanceChat),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('記下現在的心情'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Row(
                    children: [
                      Expanded(
                        child: HomeQuickAction(
                          icon: Icons.menu_book_rounded,
                          label: '寫日記',
                          supportingText: '即將開放',
                          onTap: null,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: HomeQuickAction(
                          icon: Icons.history_rounded,
                          label: '回顧記錄',
                          supportingText: '即將開放',
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeMobileNavigation(
        onUnavailableSelected: () => _showUnavailableMessage(context),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, _HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.profile:
        context.goNamed(AppRoute.profile);
        return;
      case _HomeMenuAction.passwordLock:
        context.goNamed(AppRoute.passwordLock);
        return;
      case _HomeMenuAction.logout:
        onLogout();
        return;
    }
  }
}

class _DesktopHome extends StatelessWidget {
  const _DesktopHome({required this.greetingName, required this.onLogout});

  final String greetingName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            HomeDesktopNavigation(
              onHomeSelected: () {},
              onProfileSelected: () => context.goNamed(AppRoute.profile),
              onPasswordLockSelected:
                  () => context.goNamed(AppRoute.passwordLock),
              onUnavailableSelected: () => _showUnavailableMessage(context),
              onLogout: onLogout,
            ),
            VerticalDivider(width: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '陪你整理今天的心情',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '選一件現在最想做的事，不需要一次處理所有情緒。',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          height: 520,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: CompanionHero(
                                  key: const Key('desktopCompanionHero'),
                                  greetingName: greetingName,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(
                                flex: 4,
                                child: _DesktopActions(
                                  onAddAnnoyance:
                                      () => context.goNamed(
                                        AppRoute.annoyanceChat,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

class _DesktopActions extends StatelessWidget {
  const _DesktopActions({required this.onAddAnnoyance});

  final VoidCallback onAddAnnoyance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeQuickAction(
          key: const Key('homeAnnoyanceChatButton'),
          icon: Icons.chat_bubble_outline_rounded,
          label: '記下現在的心情',
          supportingText: '用聊天方式記錄煩惱',
          emphasized: true,
          onTap: onAddAnnoyance,
        ),
        const SizedBox(height: AppSpacing.md),
        const HomeQuickAction(
          icon: Icons.menu_book_rounded,
          label: '寫一篇日記',
          supportingText: 'Phase 4 即將開放',
          onTap: null,
        ),
        const SizedBox(height: AppSpacing.md),
        const HomeQuickAction(
          icon: Icons.history_rounded,
          label: '回顧心情記錄',
          supportingText: '歷史記錄與心的軌跡即將開放',
          onTap: null,
        ),
      ],
    );
  }
}

enum _HomeMenuAction { profile, passwordLock, logout }

void _showUnavailableMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('此功能將依開發排程開放')));
}
