import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

const moodDrawingPalette = <Color>[
  Color(0xFF2D2926),
  Color(0xFFA0522D),
  Color(0xFFD84343),
  Color(0xFFF59E0B),
  Color(0xFF2563EB),
  Color(0xFF159957),
];

/// Shared drawing controls for Entry flows.
class MoodDrawingControls extends StatelessWidget {
  const MoodDrawingControls({
    required this.brushWidth,
    required this.selectedColor,
    required this.isEraser,
    required this.isEnabled,
    required this.onWidthChanged,
    required this.onEraserChanged,
    required this.onColorChanged,
    super.key,
  });

  final double brushWidth;
  final Color selectedColor;
  final bool isEraser;
  final bool isEnabled;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<bool> onEraserChanged;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.line_weight),
            Expanded(
              child: Slider(
                key: const Key('moodDrawingWidthSlider'),
                value: brushWidth,
                min: 2,
                max: 16,
                divisions: 7,
                label: brushWidth.round().toString(),
                onChanged: isEnabled ? onWidthChanged : null,
              ),
            ),
            IconButton.filledTonal(
              key: const Key('moodDrawingEraserButton'),
              tooltip: isEraser ? '切換畫筆' : '切換橡皮擦',
              onPressed: isEnabled ? () => onEraserChanged(!isEraser) : null,
              icon: Icon(isEraser ? Icons.edit : Icons.auto_fix_normal),
            ),
          ],
        ),
        Wrap(
          key: const Key('moodDrawingPalette'),
          spacing: AppSpacing.sm,
          children: [
            for (var index = 0; index < moodDrawingPalette.length; index += 1)
              Semantics(
                label: '畫筆顏色 ${index + 1}',
                selected:
                    !isEraser && selectedColor == moodDrawingPalette[index],
                child: IconButton(
                  key: Key('moodDrawingColor$index'),
                  tooltip: '選擇畫筆顏色 ${index + 1}',
                  onPressed:
                      isEnabled
                          ? () => onColorChanged(moodDrawingPalette[index])
                          : null,
                  icon: Icon(
                    selectedColor == moodDrawingPalette[index] && !isEraser
                        ? Icons.check_circle
                        : Icons.circle,
                    color: moodDrawingPalette[index],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
