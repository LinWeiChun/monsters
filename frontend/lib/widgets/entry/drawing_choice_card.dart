import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Shared drawing decision for Annoyance and Diary entry flows.
class DrawingChoiceCard extends StatelessWidget {
  const DrawingChoiceCard({
    required this.onSelected,
    this.keyPrefix = 'entry',
    this.title = '想畫一張心情圖嗎？',
    this.acceptLabel = '想畫',
    this.skipLabel = '先不用',
    super.key,
  });

  final ValueChanged<bool> onSelected;
  final String keyPrefix;
  final String title;
  final String acceptLabel;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${keyPrefix}DrawingChoiceCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
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
                  label: Text(acceptLabel),
                ),
                OutlinedButton.icon(
                  key: Key('${keyPrefix}DrawingNoButton'),
                  onPressed: () => onSelected(false),
                  icon: const Icon(Icons.skip_next),
                  label: Text(skipLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
