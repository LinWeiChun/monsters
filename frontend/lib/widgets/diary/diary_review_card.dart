import 'package:flutter/material.dart';

import '../../models/diary_draft.dart';
import '../../providers/diary_chat_provider.dart';
import '../../theme/app_spacing.dart';

class DiaryReviewCard extends StatelessWidget {
  const DiaryReviewCard({
    required this.state,
    required this.onSubmit,
    super.key,
  });

  final DiaryChatState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('diaryReviewCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('確認今天的日記', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _ReviewRow(label: '記錄方式', value: state.recordMethod?.label ?? '-'),
            _ReviewRow(label: '日記內容', value: _contentSummary()),
            _ReviewRow(
              label: '心情圖',
              value: state.drawing == null ? '未加入' : '已加入',
            ),
            _ReviewRow(label: '今日心情', value: state.score?.scoreLabel ?? '-'),
            _ReviewRow(label: '分享狀態', value: _sharingLabel()),
            if (state.submitError case final error?) ...[
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  key: const Key('diarySubmitError'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('diarySubmitButton'),
              onPressed: state.canSubmit ? onSubmit : null,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('儲存這篇日記'),
            ),
          ],
        ),
      ),
    );
  }

  String _contentSummary() {
    if (state.recordMethod == DiaryRecordMethod.text) {
      return state.contentText.trim();
    }
    return state.contentMedia?.name ?? '-';
  }

  String _sharingLabel() {
    return state.isShared == true ? '匿名分享' : '私人日記';
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
