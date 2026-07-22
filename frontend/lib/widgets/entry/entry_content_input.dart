import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/entry_media.dart';
import '../../models/entry_record.dart';
import '../../services/entry_media_service.dart';
import '../../theme/app_spacing.dart';
import 'media_preview_card.dart';

class EntryContentInput extends StatefulWidget {
  const EntryContentInput({
    required this.method,
    required this.textContent,
    required this.media,
    required this.mediaService,
    required this.onTextChanged,
    required this.onMediaSelected,
    required this.onClear,
    required this.canContinue,
    required this.onContinue,
    this.keyPrefix = 'entry',
    this.textLabel = '記錄內容',
    this.textHint = '把想說的話慢慢寫下來…',
    this.maxTextLength,
    this.continueLabel = '使用這個內容',
    this.showTitle = true,
    super.key,
  });

  final EntryRecordMethod method;
  final String textContent;
  final EntryMediaFile? media;
  final EntryMediaService mediaService;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<EntryMediaFile> onMediaSelected;
  final VoidCallback onClear;
  final bool canContinue;
  final VoidCallback onContinue;
  final String keyPrefix;
  final String textLabel;
  final String textHint;
  final int? maxTextLength;
  final String continueLabel;
  final bool showTitle;

  @override
  State<EntryContentInput> createState() => _EntryContentInputState();
}

class _EntryContentInputState extends State<EntryContentInput> {
  late final TextEditingController _textController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isBusy = false;
  bool _isRecording = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.textContent);
  }

  @override
  void didUpdateWidget(covariant EntryContentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.method != oldWidget.method ||
        widget.textContent != _textController.text) {
      _textController.value = TextEditingValue(
        text: widget.textContent,
        selection: TextSelection.collapsed(offset: widget.textContent.length),
      );
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    if (_isRecording) {
      unawaited(widget.mediaService.cancelAudioRecording());
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${widget.keyPrefix}ContentStep'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTitle) ...[
              Text(_title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.method == EntryRecordMethod.text)
              TextField(
                key: Key('${widget.keyPrefix}TextContentField'),
                controller: _textController,
                minLines: 4,
                maxLines: 8,
                maxLength: widget.maxTextLength,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: widget.textLabel,
                  hintText: widget.textHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: widget.onTextChanged,
              )
            else if (widget.media case final media?)
              MediaPreviewCard(
                media: media,
                onRemove: _clearMedia,
                onReselect: _reselectMedia,
                keyPrefix: widget.keyPrefix,
              )
            else if (widget.method == EntryRecordMethod.audio)
              _buildRecorder()
            else
              _buildPickerActions(),
            if (_isBusy) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                key: Key('${widget.keyPrefix}MediaProgress'),
              ),
            ],
            if (_errorMessage case final message?) ...[
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  key: Key('${widget.keyPrefix}MediaError'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              _limitDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: Key('${widget.keyPrefix}ContentContinueButton'),
              onPressed:
                  widget.canContinue && !_isBusy && !_isRecording
                      ? widget.onContinue
                      : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(widget.continueLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerActions() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.tonalIcon(
          key: Key('${widget.keyPrefix}MediaGalleryButton'),
          onPressed:
              _isBusy ? null : () => _pickMedia(EntryMediaOrigin.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(
            widget.method == EntryRecordMethod.image ? '選取圖片' : '選取影片',
          ),
        ),
        OutlinedButton.icon(
          key: Key('${widget.keyPrefix}MediaCameraButton'),
          onPressed: _isBusy ? null : () => _pickMedia(EntryMediaOrigin.camera),
          icon: Icon(
            widget.method == EntryRecordMethod.image
                ? Icons.camera_alt_outlined
                : Icons.videocam_outlined,
          ),
          label: Text(widget.method == EntryRecordMethod.image ? '拍照' : '錄影'),
        ),
      ],
    );
  }

  Widget _buildRecorder() {
    return Column(
      children: [
        Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          size: 48,
          color:
              _isRecording
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _formatDuration(_recordingDuration),
          key: Key('${widget.keyPrefix}RecordingDuration'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          key: Key('${widget.keyPrefix}RecordButton'),
          onPressed:
              _isBusy
                  ? null
                  : (_isRecording ? _stopRecording : _startRecording),
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? '停止錄音' : '開始錄音'),
        ),
      ],
    );
  }

  Future<void> _pickMedia(EntryMediaOrigin origin) async {
    await _runBusy(() async {
      final media = switch (widget.method) {
        EntryRecordMethod.image => widget.mediaService.pickImage(origin),
        EntryRecordMethod.video => widget.mediaService.pickVideo(origin),
        _ => Future<EntryMediaFile?>.value(),
      };
      final selected = await media;
      if (selected != null) {
        widget.onMediaSelected(selected);
      }
    });
  }

  Future<void> _startRecording() async {
    await _runBusy(() async {
      await widget.mediaService.startAudioRecording();
      if (!mounted) {
        await widget.mediaService.cancelAudioRecording();
        return;
      }
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        final next = _recordingDuration + const Duration(seconds: 1);
        setState(() => _recordingDuration = next);
        if (next >= EntryMediaLimits.audioMaxDuration) {
          unawaited(_stopRecording());
        }
      });
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    if (mounted) {
      setState(() => _isRecording = false);
    }
    await _runBusy(() async {
      final selected = await widget.mediaService.stopAudioRecording();
      if (selected != null) {
        widget.onMediaSelected(selected);
      } else {
        throw const EntryMediaValidationException('沒有取得錄音內容，請再試一次。');
      }
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on EntryMediaValidationException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = '媒體操作失敗，請確認權限後再試一次。');
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _clearMedia() {
    setState(() => _errorMessage = null);
    widget.onClear();
  }

  void _reselectMedia() {
    _clearMedia();
    if (widget.method != EntryRecordMethod.audio) {
      unawaited(_pickMedia(EntryMediaOrigin.gallery));
    }
  }

  String get _title => switch (widget.method) {
    EntryRecordMethod.text => '寫下想說的話',
    EntryRecordMethod.image => '選擇一張圖片',
    EntryRecordMethod.audio => '錄下想說的話',
    EntryRecordMethod.video => '選擇一段影片',
  };

  String get _limitDescription => switch (widget.method) {
    EntryRecordMethod.text => '文字內容不可空白。',
    EntryRecordMethod.image => '支援 JPG、PNG、WebP，最多 5 MB。',
    EntryRecordMethod.audio => '支援 WAV 錄音，最多 10 MB 或 5 分鐘。',
    EntryRecordMethod.video => '支援 MP4、MOV、WebM，最多 50 MB 或 60 秒。',
  };

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
