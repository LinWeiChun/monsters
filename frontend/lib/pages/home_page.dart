import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首頁')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('首頁'),
              const SizedBox(height: AppSpacing.lg),
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
