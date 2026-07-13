import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/annoyance_drawing.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/models/annoyance_response.dart';
import 'package:monsters/pages/annoyance_chat_page.dart';
import 'package:monsters/providers/annoyance_chat_provider.dart';
import 'package:monsters/providers/annoyance_media_provider.dart';
import 'package:monsters/repositories/annoyance_repository.dart';
import 'package:monsters/services/annoyance_media_service.dart';

void main() {
  testWidgets('uses structured selectors to reach the content step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnnoyanceChatPage(drawingExporter: _exportTestDrawing),
        ),
      ),
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

    expect(find.text('學業'), findsOneWidget);
    for (final method in ['TEXT', 'IMAGE', 'AUDIO', 'VIDEO']) {
      expect(find.byKey(Key('annoyanceRecordMethod$method')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('annoyanceRecordMethodTEXT')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceContentPrompt')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceContentStep')), findsOneWidget);
    expect(find.text('請輸入想記錄的內容。'), findsOneWidget);
  });

  testWidgets('back and restart actions rebuild the draft flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnnoyanceChatPage(drawingExporter: _exportTestDrawing),
        ),
      ),
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
    expect(find.text('職涯'), findsNothing);
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
    expect(find.byKey(const Key('annoyanceRecordingDuration')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceRecordButton')));
    await tester.pumpAndSettle();

    expect(mediaService.audioStopCount, 1);
    expect(find.byKey(const Key('annoyanceMediaPreviewCard')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceAudioPreview')), findsOneWidget);
  });

  testWidgets('draws, selects sharing, submits, and reaches completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          annoyanceRepositoryProvider.overrideWithValue(
            _FakeAnnoyanceRepository(),
          ),
        ],
        child: const MaterialApp(
          home: AnnoyanceChatPage(drawingExporter: _exportTestDrawing),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceCategoryLOVE')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceRecordMethodTEXT')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('annoyanceTextContentField')),
      '今天有一件事情讓我很煩惱',
    );
    await tester.pump();
    final continueButton = find.byKey(
      const Key('annoyanceContentContinueButton'),
    );
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceDrawingChoiceCard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('annoyanceDrawingYesButton')));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('moodDrawingGestureArea'));
    expect(canvas, findsOneWidget);
    await tester.drag(canvas, const Offset(100, 60));
    await tester.pump();
    await tester.tap(find.byKey(const Key('moodDrawingDoneButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceMoodScoreSelector')), findsOneWidget);
    expect(
      find.byKey(const Key('annoyanceDrawingPreviewCard')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('annoyanceScorePrompt')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceScore4')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceShareChoiceCard')), findsOneWidget);
    expect(find.text('4分'), findsOneWidget);
    expect(find.byKey(const Key('annoyanceSharingPrompt')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceSharePrivateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceReviewCard')), findsOneWidget);
    expect(find.text('保持私人'), findsWidgets);
    expect(find.byKey(const Key('annoyanceReviewPrompt')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceSubmitButton')));
    await tester.pump();
    expect(find.byKey(const Key('annoyanceSubmittingCard')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceCompletedCard')), findsOneWidget);
    expect(find.textContaining('101'), findsOneWidget);
    expect(find.byKey(const Key('annoyanceChatBackButton')), findsNothing);
  });
}

Future<Uint8List> _exportTestDrawing(List<MoodDrawingStroke> strokes) async {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
    'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
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

class _FakeAnnoyanceRepository extends AnnoyanceRepository {
  _FakeAnnoyanceRepository() : super(_dummyClient());

  @override
  Future<AnnoyanceResponse> create({
    required AnnoyanceCategory category,
    required AnnoyanceRecordMethod recordMethod,
    required String content,
    required AnnoyanceMediaFile? contentMedia,
    required AnnoyanceDrawingFile? drawing,
    required int score,
    required bool isShared,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return AnnoyanceResponse(
      id: 101,
      category: AnnoyanceCategoryResponse(
        code: category.code,
        name: category.name,
      ),
      recordMethod: recordMethod.apiValue,
      content: content,
      score: score,
      isShared: isShared,
      isSolved: false,
      occurredAt: '2026-07-13T10:00:00+08:00',
      media: const [],
    );
  }
}

ApiClient _dummyClient() {
  return ApiClient(
    config: const AppConfig(
      apiBaseUrl: 'http://example.com/api',
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 1),
      sendTimeout: Duration(seconds: 1),
    ),
    dio: Dio(),
  );
}
