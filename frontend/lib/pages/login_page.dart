import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登入')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.goNamed(AppRoute.home),
          child: const Text('前往首頁'),
        ),
      ),
    );
  }
}
