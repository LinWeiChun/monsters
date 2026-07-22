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
    Size(320, 700),
    Size(390, 844),
    Size(500, 900),
    Size(599, 900),
  ]) {
    testWidgets('diary Mobile follows the 390 canvas at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiaryChatPage())),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('diaryResponsiveShell')), findsOneWidget);
      expect(find.byKey(const Key('diaryMobileViewport')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('diaryMobileViewport'))).width,
        size.width,
      );
      expect(find.byKey(const Key('diaryMobileCanvas')), findsOneWidget);
      expect(find.byKey(const Key('appTopNavigation')), findsNothing);
      expect(find.text('1/8'), findsOneWidget);
      expect(find.text('今天想留下什麼？'), findsOneWidget);
      expect(find.text('不用整理好情緒，貘會陪你慢慢記。'), findsOneWidget);
      expect(find.text('約 2–4 分鐘'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

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

  testWidgets('follows Penpot Diary Mobile selection and confirmation steps', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiaryChatPage())),
    );

    await _tapVisible(tester, find.byKey(const Key('diaryChatStartButton')));
    expect(find.text('2/8'), findsOneWidget);
    expect(find.text('目前先選擇一種主要記錄方式，之後仍可編輯。'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('diaryRecordMethodTEXT')));
    expect(find.byKey(const Key('diaryContentStep')), findsNothing);
    expect(find.byKey(const Key('diaryMobileNextButton')), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));

    expect(find.text('3/8'), findsOneWidget);
    expect(find.byKey(const Key('diaryContentStep')), findsOneWidget);
    expect(find.text('不用完整，也不必寫得漂亮。'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('diaryTextContentField')),
      '今天的風很舒服',
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('diaryContentContinueButton')),
    );

    expect(find.text('4/8'), findsOneWidget);
    expect(find.text('「不用會畫畫，隨手畫也很好。」'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryDrawingNoButton')));

    expect(find.text('6/8'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryScore3')));
    expect(find.text('6/8'), findsOneWidget);
    expect(find.text('3 分'), findsOneWidget);
    expect(find.text('今天的感受比較平穩'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));

    expect(find.text('7/8'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diarySharePrivateButton')));
    expect(find.text('7/8'), findsOneWidget);
    expect(find.text('只給自己看'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));

    expect(find.text('8/8'), findsOneWidget);
    expect(find.byKey(const Key('diaryReviewCard')), findsOneWidget);
    expect(find.text('私人日記'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the Penpot Mobile drawing canvas state', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiaryChatPage())),
    );

    await _tapVisible(tester, find.byKey(const Key('diaryChatStartButton')));
    await _tapVisible(tester, find.byKey(const Key('diaryRecordMethodTEXT')));
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));
    await tester.enterText(
      find.byKey(const Key('diaryTextContentField')),
      '想畫下今天的心情',
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('diaryContentContinueButton')),
    );
    await _tapVisible(tester, find.byKey(const Key('diaryDrawingYesButton')));

    expect(find.text('5/8'), findsOneWidget);
    expect(find.text('畫下此刻的心情'), findsOneWidget);
    expect(find.text('選擇顏色，用手指自由畫。'), findsOneWidget);
    expect(find.byKey(const Key('moodDrawingGestureArea')), findsOneWidget);
    expect(find.byKey(const Key('moodDrawingDoneButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves a private diary through the Penpot Mobile flow', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
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
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));
    await tester.enterText(
      find.byKey(const Key('diaryTextContentField')),
      '今天的風很舒服',
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('diaryContentContinueButton')),
    );
    await _tapVisible(tester, find.byKey(const Key('diaryDrawingNoButton')));
    await _tapVisible(tester, find.byKey(const Key('diaryScore3')));
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));
    await _tapVisible(tester, find.byKey(const Key('diarySharePrivateButton')));
    await _tapVisible(tester, find.byKey(const Key('diaryMobileNextButton')));
    await _tapVisible(tester, find.byKey(const Key('diarySubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('完成'), findsOneWidget);
    expect(find.byKey(const Key('diaryCompletedCard')), findsOneWidget);
    expect(find.text('日記已好好收進來了'), findsOneWidget);
    expect(find.text('今日心情 · 3 分'), findsOneWidget);
    expect(find.text('私人日記\n已安全保存'), findsOneWidget);
    expect(find.byKey(const Key('mobileAppBottomNavigation')), findsOneWidget);
    expect(find.textContaining('獎勵'), findsNothing);
    expect(tester.takeException(), isNull);
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
