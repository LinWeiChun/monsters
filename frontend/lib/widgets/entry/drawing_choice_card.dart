import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Shared drawing decision for Annoyance and Diary entry flows.
class DrawingChoiceCard extends StatelessWidget {
  const DrawingChoiceCard({
    required this.onSelected,
    this.keyPrefix = 'entry',
    super.key,
  });

  final ValueChanged<bool> onSelected;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${keyPrefix}DrawingChoiceCard'),
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
                  key: Key('${keyPrefix}DrawingYesButton'),
                  onPressed: () => onSelected(true),
                  icon: const Icon(Icons.draw_outlined),
                  label: const Text('想畫'),
                ),
                OutlinedButton.icon(
                  key: Key('${keyPrefix}DrawingNoButton'),
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
