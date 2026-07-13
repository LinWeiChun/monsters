import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class CompanionHero extends StatelessWidget {
  const CompanionHero({
    required this.greetingName,
    this.compact = false,
    super.key,
  });

  final String greetingName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: '陪伴怪獸向$greetingName問候',
      child: Container(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child:
            compact
                ? Column(
                  children: [
                    const _MonsterImage(size: 176),
                    const SizedBox(height: AppSpacing.md),
                    _Greeting(greetingName: greetingName),
                  ],
                )
                : Row(
                  children: [
                    const Expanded(child: _MonsterImage(size: 260)),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: _Greeting(greetingName: greetingName)),
                  ],
                ),
      ),
    );
  }
}

class _MonsterImage extends StatelessWidget {
  const _MonsterImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greetingName，我在這裡。',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '今天有什麼想說的嗎？慢慢來就好。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
