import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首頁'),
        actions: [
          IconButton(
            key: const Key('homeLogoutButton'),
            tooltip: '登出',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(AppRoute.login);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('首頁'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('homeAnnoyanceChatButton'),
                onPressed: () => context.goNamed(AppRoute.annoyanceChat),
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('新增煩惱'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                key: const Key('homeProfileButton'),
                onPressed: () => context.goNamed(AppRoute.profile),
                icon: const Icon(Icons.person_outline),
                label: const Text('個人資料'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const Key('homePasswordLockButton'),
                onPressed: () => context.goNamed(AppRoute.passwordLock),
                icon: const Icon(Icons.lock_outline),
                label: const Text('密碼鎖'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
