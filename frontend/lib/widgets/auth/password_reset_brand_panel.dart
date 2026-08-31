import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PasswordResetBrandPanel extends StatelessWidget {
  const PasswordResetBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        return ColoredBox(
          color: AppColors.registerBrandBackground,
          child: Padding(
            padding:
                compact
                    ? const EdgeInsets.all(AppSpacing.lg)
                    : const EdgeInsets.fromLTRB(54, 42, 54, 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (constraints.maxHeight >= 240)
                  Image.asset(
                    'assets/images/title.png',
                    width: 160,
                    semanticLabel: '貘nsters',
                  ),
                if (!compact) const Spacer(),
                if (compact)
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 330,
                        height: 330,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (!compact)
                  Center(
                    child: Image.asset(
                      'assets/images/icon.png',
                      width: 330,
                      height: 330,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (!compact) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '把登入權限找回來，\n再繼續和怪獸整理心情。',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.registerMuted,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '重設連結僅可使用一次，並會在 15 分鐘後失效。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.registerMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
