import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/annoyance_drawing.dart';
import '../../theme/app_spacing.dart';
import 'mood_drawing_controls.dart';
import 'mood_drawing_exporter.dart';
import 'mood_drawing_painter.dart';

typedef MoodDrawingExport =
    Future<Uint8List> Function(List<MoodDrawingStroke> strokes);

class MoodDrawingCanvas extends StatefulWidget {
  const MoodDrawingCanvas({
    required this.onCompleted,
    required this.onCancel,
    this.exportPng,
    super.key,
  });

  final ValueChanged<AnnoyanceDrawingFile> onCompleted;
  final VoidCallback onCancel;
  final MoodDrawingExport? exportPng;

  @override
  State<MoodDrawingCanvas> createState() => _MoodDrawingCanvasState();
}

class _MoodDrawingCanvasState extends State<MoodDrawingCanvas> {
  final List<MoodDrawingStroke> _strokes = [];
  List<Offset>? _activePoints;
  Color _selectedColor = moodDrawingPalette.first;
  double _brushWidth = 6;
  bool _isEraser = false;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildToolbar(context),
              const SizedBox(height: AppSpacing.sm),
              Expanded(child: _buildCanvas(context)),
              const SizedBox(height: AppSpacing.sm),
              MoodDrawingControls(
                brushWidth: _brushWidth,
                selectedColor: _selectedColor,
                isEraser: _isEraser,
                isEnabled: !_isExporting,
                onWidthChanged: (value) => setState(() => _brushWidth = value),
                onEraserChanged: (value) => setState(() => _isEraser = value),
                onColorChanged:
                    (color) => setState(() {
                      _selectedColor = color;
                      _isEraser = false;
                    }),
              ),
              if (_errorMessage case final message?) ...[
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    key: const Key('moodDrawingError'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          key: const Key('moodDrawingCancelButton'),
          onPressed: _isExporting ? null : widget.onCancel,
          icon: const Icon(Icons.arrow_back),
          label: const Text('取消'),
        ),
        const Spacer(),
        IconButton(
          key: const Key('moodDrawingUndoButton'),
          tooltip: '復原上一筆',
          onPressed: _strokes.isEmpty || _isExporting ? null : _undo,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          key: const Key('moodDrawingClearButton'),
          tooltip: '清除畫布',
          onPressed: _strokes.isEmpty || _isExporting ? null : _clear,
          icon: const Icon(Icons.delete_outline),
        ),
        FilledButton.icon(
          key: const Key('moodDrawingDoneButton'),
          onPressed: _strokes.isEmpty || _isExporting ? null : _complete,
          icon:
              _isExporting
                  ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.check),
          label: const Text('完成'),
        ),
      ],
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final activeStroke =
        _activePoints == null
            ? null
            : MoodDrawingStroke(
              points: _activePoints!,
              color: _selectedColor,
              width: _brushWidth,
              isEraser: _isEraser,
            );
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MoodDrawingPainter.backgroundColor,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return GestureDetector(
                  key: const Key('moodDrawingGestureArea'),
                  behavior: HitTestBehavior.opaque,
                  onPanStart:
                      (details) => _startStroke(details.localPosition, size),
                  onPanUpdate:
                      (details) => _updateStroke(details.localPosition, size),
                  onPanEnd: (_) => _endStroke(),
                  child: CustomPaint(
                    key: const Key('moodDrawingPaint'),
                    painter: MoodDrawingPainter(
                      strokes: [
                        ..._strokes,
                        if (activeStroke != null) activeStroke,
                      ],
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _startStroke(Offset position, Size size) {
    setState(() {
      _errorMessage = null;
      _activePoints = [_normalize(position, size)];
    });
  }

  void _updateStroke(Offset position, Size size) {
    final points = _activePoints;
    if (points == null) {
      return;
    }
    setState(() => points.add(_normalize(position, size)));
  }

  void _endStroke() {
    final points = _activePoints;
    if (points == null || points.isEmpty) {
      return;
    }
    setState(() {
      _strokes.add(
        MoodDrawingStroke(
          points: List.unmodifiable(points),
          color: _selectedColor,
          width: _brushWidth,
          isEraser: _isEraser,
        ),
      );
      _activePoints = null;
    });
  }

  Offset _normalize(Offset position, Size size) {
    return Offset(
      (position.dx / size.width).clamp(0.0, 1.0),
      (position.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _undo() => setState(() => _strokes.removeLast());

  void _clear() => setState(_strokes.clear);

  Future<void> _complete() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });
    try {
      final bytes = await (widget.exportPng ?? MoodDrawingExporter.renderPng)(
        _strokes,
      );
      if (bytes.length > AnnoyanceDrawingLimits.maxBytes) {
        throw const FormatException('心情圖超過 5 MB，請減少筆畫後再試。');
      }
      final name = 'mood-${DateTime.now().microsecondsSinceEpoch}.png';
      widget.onCompleted(
        AnnoyanceDrawingFile(
          file: XFile.fromData(bytes, name: name, mimeType: 'image/png'),
          bytes: bytes,
          name: name,
        ),
      );
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = '心情圖產生失敗，請再試一次。');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
