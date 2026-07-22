import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/diary_draft.dart';
import 'package:monsters/models/diary_response.dart';
import 'package:monsters/pages/diary_chat_page.dart';
import 'package:monsters/providers/diary_chat_provider.dart';
import 'package:monsters/repositories/diary_repository.dart';

void main() {
  for (final size in const [
    Size(1200, 800),
    Size(1440, 900),
    Size(1920, 1080),
  ]) {
    testWidgets('diary Web shell reflows without clipping at $size', (
      tester,
    ) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiaryChatPage())),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('diaryResponsiveShell')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('diaryResponsiveShell'))).width,
        size.width,
      );
      expect(find.byKey(const Key('diaryProgress')), findsOneWidget);
      expect(find.byKey(const Key('diaryOperationPanel')), findsOneWidget);
      expect(find.byKey(const Key('appTopNavigation')), findsOneWidget);
      expect(find.text('今天想留下什麼？'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('follows Penpot Diary Web text and structured entry steps', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiaryChatPage())),
    );

    expect(find.byKey(const Key('diaryChatGreeting')), findsOneWidget);
    expect(find.text('開始記錄'), findsOneWidget);
    expect(find.text('1 / 8　引導'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('diaryChatStartButton')));
    for (final method in ['TEXT', 'IMAGE', 'AUDIO', 'VIDEO']) {
      expect(find.byKey(Key('diaryRecordMethod$method')), findsOneWidget);
    }

    await _tapVisible(tester, find.byKey(const Key('diaryRecordMethodTEXT')));
    expect(find.byKey(const Key('diaryContentStep')), findsOneWidget);
    expect(find.text('不用完整，也不必寫得漂亮。'), findsOneWidget);
    expect(find.text('儲存並繼續'), findsOneWidget);
  });

  testWidgets('saves a private diary and reaches Phase 4 completed state', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diaryRepositoryProvider.overrideWithValue(_FakeDiaryRepository()),
        ],
        child: const MaterialApp(home: DiaryChatPage()),
      ),
    );

    await _tapVisible(tester, find.byKey(const Key('diaryChatStartButton')));
    await _tapVisible(tester, find.byKey(const Key('diaryRecordMethodTEXT')));
    await tester.enterText(
      find.byKey(const Key('diaryTextContentField')),
      '今天的風很舒服',
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('diaryContentContinueButton')),
    );
    expect(find.byKey(const Key('diaryDrawingChoiceCard')), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('diaryDrawingNoButton')));
    expect(find.byKey(const Key('diaryMoodScoreSelector')), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryScore3')));

    expect(find.byKey(const Key('diaryShareChoiceCard')), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diarySharePrivateButton')));
    expect(find.byKey(const Key('diaryReviewCard')), findsOneWidget);
    expect(find.text('私人日記'), findsOneWidget);

    final submitButton = find.byKey(const Key('diarySubmitButton'));
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    expect(find.byKey(const Key('diarySubmittingCard')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diaryCompletedCard')), findsOneWidget);
    expect(find.text('日記已好好收進來了'), findsWidgets);
    expect(find.text('私人日記已安全保存'), findsOneWidget);
    expect(find.textContaining('獎勵'), findsNothing);
    expect(find.textContaining('恭喜獲得'), findsNothing);
  });
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _FakeDiaryRepository extends DiaryRepository {
  _FakeDiaryRepository() : super(_dummyClient());

  @override
  Future<DiaryResponse> create({
    required DiaryRecordMethod recordMethod,
    required String content,
    required DiaryMediaFile? contentMedia,
    required DiaryDrawingFile? drawing,
    required int score,
    required bool isShared,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return DiaryResponse(
      id: 301,
      recordMethod: recordMethod.apiValue,
      content: content,
      score: score,
      isShared: isShared,
      occurredAt: '2026-07-22T10:00:00+08:00',
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
