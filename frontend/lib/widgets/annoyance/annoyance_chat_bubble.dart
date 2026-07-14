import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AnnoyanceChatBubble extends StatelessWidget {
  const AnnoyanceChatBubble({
    required this.message,
    required this.isUser,
    super.key,
  });

  final String message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(message),
      ),
    );
  }
}
