import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('註冊')),
      body: Center(
        child: TextButton(
          onPressed: () => context.goNamed(AppRoute.login),
          child: const Text('已有帳號'),
        ),
      ),
    );
  }
}
