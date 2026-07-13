import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class HomeQuickAction extends StatelessWidget {
  const HomeQuickAction({
    required this.icon,
    required this.label,
    required this.supportingText,
    required this.onTap,
    this.emphasized = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String supportingText;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = emphasized ? colorScheme.primary : colorScheme.surface;
    final foreground =
        emphasized ? colorScheme.onPrimary : colorScheme.onSurface;

    return Material(
      color: onTap == null ? background.withValues(alpha: 0.62) : background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: emphasized ? Colors.transparent : colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 30, color: foreground),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: foreground),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      supportingText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_rounded, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
