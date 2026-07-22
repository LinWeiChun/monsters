import 'package:flutter/material.dart';

import '../../models/entry_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class MoodScoreSelector extends StatelessWidget {
  const MoodScoreSelector({
    required this.onSelected,
    this.selectedScore,
    this.keyPrefix = 'entry',
    this.title = '選擇現在的感受分數',
    this.semanticLabel = '感受分數，1 到 5 分',
    super.key,
  });

  final ValueChanged<int> onSelected;
  final int? selectedScore;
  final String keyPrefix;
  final String title;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${keyPrefix}MoodScoreSelector'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '1 到 5 分都只是記錄，選擇最符合當下感受的數字即可。',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: semanticLabel,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 440;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: compact ? AppSpacing.sm : AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final score in entryScores)
                        _ScoreButton(
                          score: score,
                          keyPrefix: keyPrefix,
                          dimension: compact ? 82 : 92,
                          isSelected: score == selectedScore,
                          onPressed: () => onSelected(score),
                        ),
                    ],
                  );
                },
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
    required this.keyPrefix,
    required this.dimension,
    required this.isSelected,
    required this.onPressed,
  });

  final int score;
  final String keyPrefix;
  final double dimension;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: score.scoreLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('${keyPrefix}Score$score'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            key: Key(
              isSelected
                  ? '${keyPrefix}ScoreSelected$score'
                  : '${keyPrefix}ScoreOption$score',
            ),
            duration: const Duration(milliseconds: 160),
            width: dimension,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.entrySoft : AppColors.entrySurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSelected ? AppColors.entryPrimary : AppColors.entryBorder,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.entryPrimary.withValues(alpha: 0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/moodPoint_$score.png',
                  key: Key('${keyPrefix}ScoreImage$score'),
                  width: dimension - 20,
                  height: dimension - 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                Text(
                  score.scoreLabel,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppColors.entryPrimary
                            : AppColors.entryInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
