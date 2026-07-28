import 'package:flutter/material.dart';

import '../../models/diary_response.dart';
import '../../theme/app_spacing.dart';

class DiaryCompletedCard extends StatelessWidget {
  const DiaryCompletedCard({
    required this.diary,
    required this.onCreateAnother,
    required this.onGoHome,
    super.key,
  });

  final DiaryResponse diary;
  final VoidCallback onCreateAnother;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('diaryCompletedCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '日記已好好收進來了',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('今日心情 · ${diary.score} 分', textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              diary.isShared ? '已匿名分享' : '私人日記已安全保存',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              key: const Key('diaryCompletedHomeButton'),
              onPressed: onGoHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('回到陪伴首頁'),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              key: const Key('diaryCreateAnotherButton'),
              onPressed: onCreateAnother,
              icon: const Icon(Icons.edit_note),
              label: const Text('再寫一篇日記'),
            ),
          ],
        ),
      ),
    );
  }
}
