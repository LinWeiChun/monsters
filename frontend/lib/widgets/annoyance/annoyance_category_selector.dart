import 'package:flutter/material.dart';

import '../../models/annoyance_draft.dart';
import '../../theme/app_spacing.dart';

class AnnoyanceCategorySelector extends StatelessWidget {
  const AnnoyanceCategorySelector({required this.onSelected, super.key});

  final ValueChanged<AnnoyanceCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '選擇煩惱類別',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final category in annoyanceCategories)
            OutlinedButton(
              key: Key('annoyanceCategory${category.code}'),
              onPressed: () => onSelected(category),
              child: Text(category.name),
            ),
        ],
      ),
    );
  }
}
