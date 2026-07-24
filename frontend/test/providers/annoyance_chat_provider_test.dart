import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/annoyance_drawing.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/models/annoyance_response.dart';
import 'package:monsters/providers/annoyance_chat_provider.dart';
import 'package:monsters/repositories/annoyance_repository.dart';

void main() {
  test('advances through structured category and record method steps', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);

    expect(controller.state.step, AnnoyanceChatStep.intro);

    controller.begin();
    expect(controller.state.step, AnnoyanceChatStep.category);

    controller.selectCategory(annoyanceCategories.first);
    expect(controller.state.step, AnnoyanceChatStep.recordMethod);
    expect(controller.state.category?.code, 'ACADEMIC');

    controller.selectRecordMethod(AnnoyanceRecordMethod.text);
    expect(controller.state.step, AnnoyanceChatStep.content);
    expect(controller.state.recordMethod, AnnoyanceRecordMethod.text);
  });

  test('ignores out-of-order selections and supports back and restart', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);

    controller.selectCategory(annoyanceCategories.first);
    expect(controller.state.step, AnnoyanceChatStep.intro);

    controller.begin();
    controller.selectCategory(annoyanceCategories[1]);
    controller.selectRecordMethod(AnnoyanceRecordMethod.video);
    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.recordMethod);
    expect(controller.state.category?.code, 'CAREER');
    expect(controller.state.recordMethod, isNull);

    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.category);
    expect(controller.state.category, isNull);

    controller.restart();
    expect(controller.state.step, AnnoyanceChatStep.intro);
  });

  test('stores only content matching the selected record method', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    controller.begin();
    controller.selectCategory(annoyanceCategories.first);
    controller.selectRecordMethod(AnnoyanceRecordMethod.image);

    controller.updateTextContent('不應保存的文字');
    expect(controller.state.contentText, isEmpty);

    final wrongMedia = _media(AnnoyanceRecordMethod.video);
    controller.selectContentMedia(wrongMedia);
    expect(controller.state.contentMedia, isNull);

    final image = _media(AnnoyanceRecordMethod.image);
    controller.selectContentMedia(image);
    expect(controller.state.contentMedia, same(image));
    expect(controller.state.isContentReady, isTrue);

    controller.goBack();
    expect(controller.state.contentMedia, isNull);
    expect(controller.state.isContentReady, isFalse);
  });

  test('trims text only when checking content readiness', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    controller.begin();
    controller.selectCategory(annoyanceCategories.first);
    controller.selectRecordMethod(AnnoyanceRecordMethod.text);

    controller.updateTextContent('   ');
    expect(controller.state.isContentReady, isFalse);

    controller.updateTextContent(' 想說的話 ');
    expect(controller.state.contentText, ' 想說的話 ');
    expect(controller.state.isContentReady, isTrue);
  });

  test('guards content confirmation and supports skipping drawing', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    controller.begin();
    controller.selectCategory(annoyanceCategories.first);
    controller.selectRecordMethod(AnnoyanceRecordMethod.text);

    controller.confirmContent();
    expect(controller.state.step, AnnoyanceChatStep.content);

    controller.updateTextContent('最近有點累');
    controller.confirmContent();
    expect(controller.state.step, AnnoyanceChatStep.drawingDecision);

    controller.selectDrawingChoice(false);
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.wantsDrawing, isFalse);
    expect(controller.state.drawing, isNull);

    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.drawingDecision);
    expect(controller.state.wantsDrawing, isNull);
  });

  test('stores one valid drawing and rejects invalid drawing data', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    controller.begin();
    controller.selectCategory(annoyanceCategories.first);
    controller.selectRecordMethod(AnnoyanceRecordMethod.text);
    controller.updateTextContent('想畫下現在的心情');
    controller.confirmContent();
    controller.selectDrawingChoice(true);

    expect(controller.state.step, AnnoyanceChatStep.drawing);
    controller.saveDrawing(_drawing(bytes: Uint8List(0)));
    expect(controller.state.step, AnnoyanceChatStep.drawing);

    final drawing = _drawing(bytes: Uint8List.fromList([1, 2, 3]));
    controller.saveDrawing(drawing);
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.wantsDrawing, isTrue);
    expect(controller.state.drawing, same(drawing));
  });

  test('stores only a score from 1 to 5 and supports revising it', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    _reachScoreStep(controller);

    controller.selectScore(0);
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.score, isNull);

    controller.selectScore(4);
    expect(controller.state.step, AnnoyanceChatStep.sharing);
    expect(controller.state.score, 4);

    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.score, 4);

    controller.selectScore(2);
    expect(controller.state.step, AnnoyanceChatStep.sharing);
    expect(controller.state.score, 2);
  });

  test('stores explicit sharing choice and supports revising it', () {
    final controller = AnnoyanceChatController();
    addTearDown(controller.dispose);
    _reachScoreStep(controller);

    controller.selectSharing(true);
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.isShared, isNull);

    controller.selectScore(3);
    controller.selectSharing(false);
    expect(controller.state.step, AnnoyanceChatStep.review);
    expect(controller.state.isShared, isFalse);

    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.sharing);
    expect(controller.state.isShared, isFalse);

    controller.selectSharing(true);
    expect(controller.state.step, AnnoyanceChatStep.review);
    expect(controller.state.isShared, isTrue);

    controller.goBack();
    controller.goBack();
    expect(controller.state.step, AnnoyanceChatStep.score);
    expect(controller.state.isShared, isNull);
  });

  test('submits a complete draft and stores created annoyance', () async {
    final repository = _FakeAnnoyanceRepository();
    final controller = AnnoyanceChatController(repository);
    addTearDown(controller.dispose);
    _reachScoreStep(controller);
    controller.selectScore(3);
    controller.selectSharing(true);

    await controller.submit();

    expect(controller.state.step, AnnoyanceChatStep.completed);
    expect(controller.state.createdAnnoyance?.id, 101);
    expect(controller.state.createdAnnoyance?.reward, isNull);
    expect(repository.createCount, 1);
    expect(repository.lastIsShared, isTrue);
    expect(repository.lastScore, 3);
  });

  test('returns to review with an error when submit fails', () async {
    final controller = AnnoyanceChatController(
      _FakeAnnoyanceRepository(
        exception: const ApiException(
          type: ApiErrorType.network,
          message: 'Network failed.',
        ),
      ),
    );
    addTearDown(controller.dispose);
    _reachScoreStep(controller);
    controller.selectScore(3);
    controller.selectSharing(false);

    await controller.submit();

    expect(controller.state.step, AnnoyanceChatStep.review);
    expect(controller.state.submitError, 'Network failed.');
    expect(controller.state.createdAnnoyance, isNull);
  });
}

void _reachScoreStep(AnnoyanceChatController controller) {
  controller.begin();
  controller.selectCategory(annoyanceCategories.first);
  controller.selectRecordMethod(AnnoyanceRecordMethod.text);
  controller.updateTextContent('最近有點累');
  controller.confirmContent();
  controller.selectDrawingChoice(false);
}

AnnoyanceMediaFile _media(AnnoyanceRecordMethod method) {
  final bytes = Uint8List.fromList([1, 2, 3]);
  return AnnoyanceMediaFile(
    method: method,
    file: XFile.fromData(bytes, name: 'content.bin'),
    bytes: bytes,
    name: 'content.bin',
    mimeType: 'application/octet-stream',
    sizeBytes: bytes.length,
    duration:
        method == AnnoyanceRecordMethod.video
            ? const Duration(seconds: 1)
            : null,
  );
}

AnnoyanceDrawingFile _drawing({required Uint8List bytes}) {
  return AnnoyanceDrawingFile(
    file: XFile.fromData(bytes, name: 'mood.png', mimeType: 'image/png'),
    bytes: bytes,
    name: 'mood.png',
  );
}

class _FakeAnnoyanceRepository extends AnnoyanceRepository {
  _FakeAnnoyanceRepository({this.exception}) : super(_dummyClient());

  final ApiException? exception;
  int createCount = 0;
  int? lastScore;
  bool? lastIsShared;

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
    createCount += 1;
    lastScore = score;
    lastIsShared = isShared;
    final error = exception;
    if (error != null) {
      throw error;
    }
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
