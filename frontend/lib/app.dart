import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

class MonstersApp extends ConsumerWidget {
  const MonstersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.listen<bool>(authSessionExpiredProvider, (previous, expired) {
      if (expired && previous != true) {
        router.goNamed(AppRoute.login);
      }
    });

    return MaterialApp.router(
      title: '貘nsters',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
