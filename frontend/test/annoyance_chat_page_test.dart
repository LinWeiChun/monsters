import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/pages/annoyance_chat_page.dart';
import 'package:monsters/providers/annoyance_media_provider.dart';
import 'package:monsters/services/annoyance_media_service.dart';

void main() {
  testWidgets('uses structured selectors to reach the content step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AnnoyanceChatPage())),
    );

    expect(find.byKey(const Key('annoyanceChatGreeting')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();

    for (final code in [
      'ACADEMIC',
      'CAREER',
      'LOVE',
      'FRIENDSHIP',
      'FAMILY',
      'OTHER',
    ]) {
      expect(find.byKey(Key('annoyanceCategory$code')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('annoyanceCategoryACADEMIC')));
    await tester.pumpAndSettle();

    expect(find.text('課業'), findsOneWidget);
    for (final method in ['TEXT', 'IMAGE', 'AUDIO', 'VIDEO']) {
      expect(find.byKey(Key('annoyanceRecordMethod$method')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('annoyanceRecordMethodTEXT')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceContentPrompt')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceContentStep')), findsOneWidget);
    expect(find.text('慢慢來，接下來把想說的話寫下來就好。'), findsOneWidget);
  });

  testWidgets('back and restart actions rebuild the draft flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AnnoyanceChatPage())),
    );

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceCategoryCAREER')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceChatBackButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceCategoryCAREER')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceRecordMethodTEXT')), findsNothing);

    await tester.tap(find.byKey(const Key('annoyanceChatRestartButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);
    expect(find.text('事業'), findsNothing);
  });

  testWidgets('selects, previews, and removes one image', (tester) async {
    final mediaService = _FakeMediaService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          annoyanceMediaServiceProvider.overrideWithValue(mediaService),
        ],
        child: const MaterialApp(home: AnnoyanceChatPage()),
      ),
    );

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceCategoryOTHER')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceRecordMethodIMAGE')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('annoyanceMediaGalleryButton')));
    await tester.pumpAndSettle();

    expect(mediaService.lastOrigin, AnnoyanceMediaOrigin.gallery);
    expect(find.byKey(const Key('annoyanceMediaPreviewCard')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceImagePreview')), findsOneWidget);

    final removeButton = find.byKey(const Key('annoyanceMediaRemoveButton'));
    await tester.ensureVisible(removeButton);
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceMediaPreviewCard')), findsNothing);
    expect(
      find.byKey(const Key('annoyanceMediaGalleryButton')),
      findsOneWidget,
    );
  });

  testWidgets('records audio and shows a playback preview', (tester) async {
    final mediaService = _FakeMediaService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          annoyanceMediaServiceProvider.overrideWithValue(mediaService),
        ],
        child: const MaterialApp(home: AnnoyanceChatPage()),
      ),
    );

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceCategoryFAMILY')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceRecordMethodAUDIO')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('annoyanceRecordButton')));
    await tester.pump();
    expect(mediaService.audioStartCount, 1);
    expect(find.text('停止錄音'), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceRecordButton')));
    await tester.pumpAndSettle();

    expect(mediaService.audioStopCount, 1);
    expect(find.byKey(const Key('annoyanceMediaPreviewCard')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceAudioPreview')), findsOneWidget);
  });
}

class _FakeMediaService implements AnnoyanceMediaService {
  AnnoyanceMediaOrigin? lastOrigin;
  int audioStartCount = 0;
  int audioStopCount = 0;

  @override
  Future<AnnoyanceMediaFile?> pickImage(AnnoyanceMediaOrigin origin) async {
    lastOrigin = origin;
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
      'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    return AnnoyanceMediaFile(
      method: AnnoyanceRecordMethod.image,
      file: XFile.fromData(bytes, name: 'preview.png', mimeType: 'image/png'),
      bytes: bytes,
      name: 'preview.png',
      mimeType: 'image/png',
      sizeBytes: bytes.length,
      duration: null,
    );
  }

  @override
  Future<AnnoyanceMediaFile?> pickVideo(AnnoyanceMediaOrigin origin) async {
    lastOrigin = origin;
    return null;
  }

  @override
  Future<void> startAudioRecording() async {
    audioStartCount += 1;
  }

  @override
  Future<AnnoyanceMediaFile?> stopAudioRecording() async {
    audioStopCount += 1;
    return AnnoyanceMediaFile(
      method: AnnoyanceRecordMethod.audio,
      file: XFile('recording.wav', mimeType: 'audio/wav'),
      bytes: base64Decode(''),
      name: 'recording.wav',
      mimeType: 'audio/wav',
      sizeBytes: 1024,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Future<void> cancelAudioRecording() async {}

  @override
  Future<void> dispose() async {}
}
