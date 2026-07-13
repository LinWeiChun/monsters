import 'package:flutter/material.dart';

import '../../models/annoyance_draft.dart';
import '../../theme/app_spacing.dart';

class MoodScoreSelector extends StatelessWidget {
  const MoodScoreSelector({
    required this.onSelected,
    this.selectedScore,
    super.key,
  });

  final ValueChanged<int> onSelected;
  final int? selectedScore;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('annoyanceMoodScoreSelector'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('選擇現在的煩惱分數', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '1 到 5 分都只是記錄，選擇最符合當下感受的數字即可。',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: '煩惱分數，1 到 5 分',
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final score in annoyanceScores)
                    _ScoreButton(
                      score: score,
                      isSelected: score == selectedScore,
                      onPressed: () => onSelected(score),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.score,
    required this.isSelected,
    required this.onPressed,
  });

  final int score;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: score.scoreLabel,
      child: SizedBox.square(
        dimension: 64,
        child:
            isSelected
                ? FilledButton(
                  key: Key('annoyanceScore$score'),
                  onPressed: onPressed,
                  child: Text(score.scoreLabel),
                )
                : OutlinedButton(
                  key: Key('annoyanceScore$score'),
                  onPressed: onPressed,
                  child: Text(score.scoreLabel),
                ),
      ),
    );
  }
}
