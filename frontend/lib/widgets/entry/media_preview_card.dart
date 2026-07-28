import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../models/entry_media.dart';
import '../../models/entry_record.dart';
import '../../services/entry_media_platform.dart';
import '../../services/entry_media_platform_factory.dart';
import '../../theme/app_spacing.dart';

class MediaPreviewCard extends StatelessWidget {
  const MediaPreviewCard({
    required this.media,
    required this.onRemove,
    required this.onReselect,
    this.keyPrefix = 'entry',
    super.key,
  });

  final EntryMediaFile media;
  final VoidCallback onRemove;
  final VoidCallback onReselect;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${keyPrefix}MediaPreviewCard'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreview(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              media.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(_metadataText(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              children: [
                TextButton.icon(
                  key: Key('${keyPrefix}MediaRemoveButton'),
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('移除'),
                ),
                FilledButton.tonalIcon(
                  key: Key('${keyPrefix}MediaReselectButton'),
                  onPressed: onReselect,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新選擇'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (media.file == null && media.bytes.isEmpty) {
      return _PersistedDraftPreview(method: media.method, keyPrefix: keyPrefix);
    }
    return switch (media.method) {
      EntryRecordMethod.image => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.memory(
          media.bytes,
          key: Key('${keyPrefix}ImagePreview'),
          height: 220,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) =>
                  const _PreviewError(message: '圖片預覽無法顯示，請重新選擇。'),
        ),
      ),
      EntryRecordMethod.audio => _AudioPreview(
        path: media.file!.path,
        keyPrefix: keyPrefix,
      ),
      EntryRecordMethod.video => _VideoPreview(
        path: media.file!.path,
        keyPrefix: keyPrefix,
      ),
      EntryRecordMethod.text => const SizedBox.shrink(),
    };
  }

  String _metadataText() {
    final size = media.sizeBytes / (1024 * 1024);
    final duration = media.duration;
    if (duration == null) {
      return '${media.mimeType} · ${size.toStringAsFixed(2)} MB';
    }
    return '${media.mimeType} · ${size.toStringAsFixed(2)} MB · '
        '${_formatDuration(duration)}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PersistedDraftPreview extends StatelessWidget {
  const _PersistedDraftPreview({required this.method, required this.keyPrefix});

  final EntryRecordMethod method;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      EntryRecordMethod.image => Icons.image_outlined,
      EntryRecordMethod.audio => Icons.graphic_eq,
      EntryRecordMethod.video => Icons.videocam_outlined,
      EntryRecordMethod.text => Icons.description_outlined,
    };
    return Container(
      key: Key('${keyPrefix}PersistedMediaPreview'),
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: AppSpacing.sm),
          const Text('媒體已安全暫存'),
          const SizedBox(height: AppSpacing.xs),
          Text('重新選擇即可更換檔案', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AudioPreview extends StatefulWidget {
  const _AudioPreview({required this.path, required this.keyPrefix});

  final String path;
  final String keyPrefix;

  @override
  State<_AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<_AudioPreview> {
  final _player = AudioPlayer();
  late final EntryMediaPlatform _platform;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _platform = createEntryMediaPlatform();
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const _PreviewError(message: '錄音預覽無法播放，請重新錄製。');
    }
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;
        return ListTile(
          key: Key('${widget.keyPrefix}AudioPreview'),
          leading: const Icon(Icons.graphic_eq),
          title: const Text('錄音預覽'),
          trailing: IconButton.filledTonal(
            key: Key('${widget.keyPrefix}AudioPlayButton'),
            tooltip: isPlaying ? '暫停' : '播放',
            onPressed: !_ready ? null : () => _toggleAudio(isPlaying),
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          ),
        );
      },
    );
  }

  Future<void> _load() async {
    try {
      await _platform.loadAudio(_player, widget.path);
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  Future<void> _toggleAudio(bool isPlaying) async {
    if (isPlaying) {
      await _player.pause();
      return;
    }
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.path, required this.keyPrefix});

  final String path;
  final String keyPrefix;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed) {
      return const _PreviewError(message: '影片預覽無法播放，請重新選擇。');
    }
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      key: Key('${widget.keyPrefix}VideoPreview'),
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          IconButton.filledTonal(
            key: Key('${widget.keyPrefix}VideoPlayButton'),
            tooltip: controller.value.isPlaying ? '暫停' : '播放',
            onPressed: () async {
              controller.value.isPlaying
                  ? await controller.pause()
                  : await controller.play();
              if (mounted) {
                setState(() {});
              }
            },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    try {
      final controller = createEntryMediaPlatform().createVideoController(
        widget.path,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
