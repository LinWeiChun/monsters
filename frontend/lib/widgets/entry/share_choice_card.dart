import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Shared private-or-community choice for Entry flows.
class ShareChoiceCard extends StatelessWidget {
  const ShareChoiceCard({
    required this.onSelected,
    this.selectedValue,
    this.keyPrefix = 'entry',
    this.title = '是否分享這筆記錄？',
    super.key,
  });

  final ValueChanged<bool> onSelected;
  final bool? selectedValue;
  final String keyPrefix;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${keyPrefix}ShareChoiceCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '預設會保持私人。分享到社群後，其他使用者可以在社群看到這筆內容。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _ShareOptionButton(
              key: Key('${keyPrefix}SharePrivateButton'),
              icon: Icons.lock_outline,
              title: '保持私人',
              subtitle: '只保存在你的紀錄中',
              isSelected: selectedValue == false,
              onPressed: () => onSelected(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ShareOptionButton(
              key: Key('${keyPrefix}SharePublicButton'),
              icon: Icons.groups_outlined,
              title: '分享到社群',
              subtitle: '讓社群中的使用者看見',
              isSelected: selectedValue == true,
              onPressed: () => onSelected(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionButton extends StatelessWidget {
  const _ShareOptionButton({
    required super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side:
              isSelected
                  ? BorderSide(color: colorScheme.primary, width: 2)
                  : null,
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
        icon: Icon(icon),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
