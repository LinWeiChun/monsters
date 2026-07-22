import 'package:flutter/material.dart';

import '../../models/entry_record.dart';
import '../../theme/app_spacing.dart';

class RecordMethodSelector extends StatelessWidget {
  const RecordMethodSelector({
    required this.onSelected,
    this.keyPrefix = 'entry',
    super.key,
  });

  final ValueChanged<EntryRecordMethod> onSelected;
  final String keyPrefix;

  static const _icons = <EntryRecordMethod, IconData>{
    EntryRecordMethod.text: Icons.notes,
    EntryRecordMethod.image: Icons.image_outlined,
    EntryRecordMethod.audio: Icons.mic_none,
    EntryRecordMethod.video: Icons.videocam_outlined,
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
          for (final method in EntryRecordMethod.values)
            SizedBox(
              width: 136,
              child: OutlinedButton.icon(
                key: Key('${keyPrefix}RecordMethod${method.apiValue}'),
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
