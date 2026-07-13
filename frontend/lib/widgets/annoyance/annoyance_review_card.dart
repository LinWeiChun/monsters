import 'package:flutter/material.dart';

import '../../models/annoyance_draft.dart';
import '../../providers/annoyance_chat_provider.dart';
import '../../theme/app_spacing.dart';

class AnnoyanceReviewCard extends StatelessWidget {
  const AnnoyanceReviewCard({
    required this.state,
    required this.onSubmit,
    super.key,
  });

  final AnnoyanceChatState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('annoyanceReviewCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('送出前確認', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _ReviewRow(label: '煩惱類型', value: state.category?.name ?? '-'),
            _ReviewRow(label: '記錄方式', value: state.recordMethod?.label ?? '-'),
            _ReviewRow(label: '主要內容', value: _contentSummary()),
            _ReviewRow(
              label: '心情圖',
              value: state.drawing == null ? '未加入' : '已加入',
            ),
            _ReviewRow(label: '煩惱分數', value: state.score?.scoreLabel ?? '-'),
            _ReviewRow(label: '分享狀態', value: _sharingLabel()),
            if (state.submitError case final error?) ...[
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  key: const Key('annoyanceSubmitError'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('annoyanceSubmitButton'),
              onPressed: state.canSubmit ? onSubmit : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('確認送出'),
            ),
          ],
        ),
      ),
    );
  }

  String _contentSummary() {
    if (state.recordMethod == AnnoyanceRecordMethod.text) {
      return state.contentText.trim();
    }
    return state.contentMedia?.name ?? '-';
  }

  String _sharingLabel() {
    return state.isShared == true ? '分享到社群' : '保持私人';
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
