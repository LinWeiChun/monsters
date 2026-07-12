import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/models/annoyance_draft.dart';
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
}
