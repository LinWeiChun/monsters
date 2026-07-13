import 'package:flutter/material.dart';

import '../../models/annoyance_response.dart';
import '../../theme/app_spacing.dart';

class AnnoyanceCompletedCard extends StatelessWidget {
  const AnnoyanceCompletedCard({
    required this.annoyance,
    required this.onCreateAnother,
    required this.onGoHome,
    super.key,
  });

  final AnnoyanceResponse annoyance;
  final VoidCallback onCreateAnother;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('annoyanceCompletedCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '煩惱已記錄完成',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '編號 ${annoyance.id}，分享狀態為${annoyance.isShared ? '分享到社群' : '保持私人'}。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('annoyanceCreateAnotherButton'),
              onPressed: onCreateAnother,
              icon: const Icon(Icons.add),
              label: const Text('再記一筆'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const Key('annoyanceCompletedHomeButton'),
              onPressed: onGoHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('回首頁'),
            ),
          ],
        ),
      ),
    );
  }
}
