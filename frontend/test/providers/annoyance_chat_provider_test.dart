import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/providers/annoyance_chat_provider.dart';

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
