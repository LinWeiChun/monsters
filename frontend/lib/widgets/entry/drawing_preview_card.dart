import 'package:flutter/material.dart';

import '../../models/entry_drawing.dart';
import '../../theme/app_spacing.dart';

class DrawingPreviewCard extends StatelessWidget {
  const DrawingPreviewCard({
    required this.drawing,
    this.keyPrefix = 'entry',
    super.key,
  });

  final EntryDrawingFile drawing;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Card(
        key: Key('${keyPrefix}DrawingPreviewCard'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.memory(
                  drawing.bytes,
                  key: Key('${keyPrefix}DrawingPreview'),
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const SizedBox(
                        width: 220,
                        height: 120,
                        child: Center(child: Text('心情圖預覽無法顯示')),
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(drawing.sizeBytes / 1024).toStringAsFixed(1)} KB',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
