import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/diary_draft.dart';
import 'package:monsters/models/diary_response.dart';
import 'package:monsters/providers/diary_chat_provider.dart';
import 'package:monsters/repositories/diary_repository.dart';

void main() {
  test('advances through diary content and drawing decision steps', () {
    final controller = DiaryChatController();
    addTearDown(controller.dispose);

    expect(controller.state.step, DiaryChatStep.intro);
    controller.begin();
    expect(controller.state.step, DiaryChatStep.recordMethod);

    controller.selectRecordMethod(DiaryRecordMethod.text);
    controller.updateTextContent(' 今天的風很舒服 ');
    expect(controller.state.isContentReady, isTrue);

    controller.confirmContent();
    expect(controller.state.step, DiaryChatStep.drawingDecision);
    controller.selectDrawingChoice(false);
    expect(controller.state.step, DiaryChatStep.score);
  });

  test('accepts only media matching the selected record method', () {
    final controller = DiaryChatController();
    addTearDown(controller.dispose);
    controller.begin();
    controller.selectRecordMethod(DiaryRecordMethod.image);

    controller.selectContentMedia(_media(DiaryRecordMethod.video));
    expect(controller.state.contentMedia, isNull);

    final image = _media(DiaryRecordMethod.image);
    controller.selectContentMedia(image);
    expect(controller.state.contentMedia, same(image));
    expect(controller.state.isContentReady, isTrue);
  });

  test('supports score, sharing, back, and restart', () {
    final controller = DiaryChatController();
    addTearDown(controller.dispose);
    _reachScoreStep(controller);

    controller.selectScore(0);
    expect(controller.state.step, DiaryChatStep.score);

    controller.selectScore(4);
    controller.selectSharing(false);
    expect(controller.state.step, DiaryChatStep.review);
    expect(controller.state.score, 4);
    expect(controller.state.isShared, isFalse);

    controller.goBack();
    expect(controller.state.step, DiaryChatStep.sharing);
    controller.restart();
    expect(controller.state, isA<DiaryChatState>());
    expect(controller.state.step, DiaryChatStep.intro);
  });

  test('keeps Mobile selections in place until the user confirms', () {
    final controller = DiaryChatController();
    addTearDown(controller.dispose);

    controller.begin();
    controller.chooseRecordMethod(DiaryRecordMethod.text);
    expect(controller.state.step, DiaryChatStep.recordMethod);
    expect(controller.state.recordMethod, DiaryRecordMethod.text);
    controller.confirmRecordMethod();

    controller.updateTextContent('今天值得記下來');
    controller.confirmContent();
    controller.selectDrawingChoice(false);
    controller.chooseScore(3);
    expect(controller.state.step, DiaryChatStep.score);
    expect(controller.state.score, 3);
    controller.confirmScore();

    controller.chooseSharing(false);
    expect(controller.state.step, DiaryChatStep.sharing);
    expect(controller.state.isShared, isFalse);
    controller.confirmSharing();
    expect(controller.state.step, DiaryChatStep.review);
  });

  test('submits a complete diary and keeps Phase 4 reward null', () async {
    final repository = _FakeDiaryRepository();
    final controller = DiaryChatController(repository);
    addTearDown(controller.dispose);
    _reachScoreStep(controller);
    controller.selectScore(3);
    controller.selectSharing(false);

    await controller.submit();

    expect(controller.state.step, DiaryChatStep.completed);
    expect(controller.state.createdDiary?.id, 301);
    expect(controller.state.createdDiary?.reward, isNull);
    expect(repository.createCount, 1);
  });

  test(
    'returns to review and exposes API error after submit failure',
    () async {
      final controller = DiaryChatController(
        _FakeDiaryRepository(
          exception: const ApiException(
            type: ApiErrorType.network,
            message: 'Network failed.',
          ),
        ),
      );
      addTearDown(controller.dispose);
      _reachScoreStep(controller);
      controller.selectScore(3);
      controller.selectSharing(true);

      await controller.submit();

      expect(controller.state.step, DiaryChatStep.review);
      expect(controller.state.submitError, 'Network failed.');
    },
  );
}

void _reachScoreStep(DiaryChatController controller) {
  controller.begin();
  controller.selectRecordMethod(DiaryRecordMethod.text);
  controller.updateTextContent('今天值得記下來');
  controller.confirmContent();
  controller.selectDrawingChoice(false);
}

DiaryMediaFile _media(DiaryRecordMethod method) {
  final bytes = Uint8List.fromList([1, 2, 3]);
  return DiaryMediaFile(
    method: method,
    file: XFile.fromData(bytes, name: 'content.bin'),
    bytes: bytes,
    name: 'content.bin',
    mimeType: 'application/octet-stream',
    sizeBytes: bytes.length,
    duration: null,
  );
}

class _FakeDiaryRepository extends DiaryRepository {
  _FakeDiaryRepository({this.exception}) : super(_dummyClient());

  final ApiException? exception;
  int createCount = 0;

  @override
  Future<DiaryResponse> create({
    required DiaryRecordMethod recordMethod,
    required String content,
    required DiaryMediaFile? contentMedia,
    required DiaryDrawingFile? drawing,
    required int score,
    required bool isShared,
  }) async {
    createCount += 1;
    final error = exception;
    if (error != null) {
      throw error;
    }
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
