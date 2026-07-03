import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '貘nsters',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.goNamed(AppRoute.login),
                  child: const Text('登入'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.goNamed(AppRoute.register),
                  child: const Text('註冊'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
