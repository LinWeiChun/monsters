import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _checkedSession = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    final restored =
        await ref.read(authControllerProvider.notifier).restoreSession();
    if (!mounted) {
      return;
    }

    if (restored) {
      context.goNamed(AppRoute.home);
      return;
    }

    setState(() {
      _checkedSession = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
