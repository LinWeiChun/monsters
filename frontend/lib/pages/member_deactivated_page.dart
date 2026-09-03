import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class MemberDeactivatedPage extends StatelessWidget {
  const MemberDeactivatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFE8F1E8),
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontSize: 34,
                          color: Color(0xFF6F9271),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '帳號已停用',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '所有裝置已登出，公開內容已取消分享。恢復帳號後不會自動重新公開。',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      key: const Key('memberDeactivatedLoginButton'),
                      onPressed: () => context.goNamed(AppRoute.login),
                      child: const Text('前往登入'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
