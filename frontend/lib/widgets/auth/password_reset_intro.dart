import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PasswordResetIntro extends StatelessWidget {
  const PasswordResetIntro({
    required this.title,
    required this.description,
    required this.compact,
    super.key,
  });

  final String title;
  final String description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Center(
            child: Image.asset(
              'assets/images/title.png',
              width: 150,
              semanticLabel: '貘nsters',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          title,
          style: (compact
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.headlineMedium)
              ?.copyWith(
                color: AppColors.registerInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.registerMuted),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
      ],
    );
  }
}
