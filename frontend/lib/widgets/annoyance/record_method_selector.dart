import 'package:flutter/material.dart';

import '../../models/annoyance_draft.dart';
import '../../theme/app_spacing.dart';

class RecordMethodSelector extends StatelessWidget {
  const RecordMethodSelector({required this.onSelected, super.key});

  final ValueChanged<AnnoyanceRecordMethod> onSelected;

  static const _icons = <AnnoyanceRecordMethod, IconData>{
    AnnoyanceRecordMethod.text: Icons.notes,
    AnnoyanceRecordMethod.image: Icons.image_outlined,
    AnnoyanceRecordMethod.audio: Icons.mic_none,
    AnnoyanceRecordMethod.video: Icons.videocam_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '選擇記錄方式',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final method in AnnoyanceRecordMethod.values)
            SizedBox(
              width: 136,
              child: OutlinedButton.icon(
                key: Key('annoyanceRecordMethod${method.apiValue}'),
                onPressed: () => onSelected(method),
                icon: Icon(_icons[method]),
                label: Text(method.label),
              ),
            ),
        ],
      ),
    );
  }
}
