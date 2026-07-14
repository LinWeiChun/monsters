import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class DrawingChoiceCard extends StatelessWidget {
  const DrawingChoiceCard({required this.onSelected, super.key});

  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('annoyanceDrawingChoiceCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('想畫一張心情圖嗎？', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  key: const Key('annoyanceDrawingYesButton'),
                  onPressed: () => onSelected(true),
                  icon: const Icon(Icons.draw_outlined),
                  label: const Text('想畫'),
                ),
                OutlinedButton.icon(
                  key: const Key('annoyanceDrawingNoButton'),
                  onPressed: () => onSelected(false),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('先不用'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
