import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annoyance_draft.dart';

final annoyanceChatControllerProvider = StateNotifierProvider.autoDispose<
  AnnoyanceChatController,
  AnnoyanceChatState
>((ref) => AnnoyanceChatController());

class AnnoyanceChatState {
  const AnnoyanceChatState({
    this.step = AnnoyanceChatStep.intro,
    this.category,
    this.recordMethod,
  });

  final AnnoyanceChatStep step;
  final AnnoyanceCategory? category;
  final AnnoyanceRecordMethod? recordMethod;

  AnnoyanceChatState copyWith({
    AnnoyanceChatStep? step,
    AnnoyanceCategory? category,
    bool clearCategory = false,
    AnnoyanceRecordMethod? recordMethod,
    bool clearRecordMethod = false,
  }) {
    return AnnoyanceChatState(
      step: step ?? this.step,
      category: clearCategory ? null : category ?? this.category,
      recordMethod:
          clearRecordMethod ? null : recordMethod ?? this.recordMethod,
    );
  }
}

class AnnoyanceChatController extends StateNotifier<AnnoyanceChatState> {
  AnnoyanceChatController() : super(const AnnoyanceChatState());

  void begin() {
    if (state.step != AnnoyanceChatStep.intro) {
      return;
    }
    state = state.copyWith(step: AnnoyanceChatStep.category);
  }

  void selectCategory(AnnoyanceCategory category) {
    if (state.step != AnnoyanceChatStep.category) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.recordMethod,
      category: category,
      clearRecordMethod: true,
    );
  }

  void selectRecordMethod(AnnoyanceRecordMethod recordMethod) {
    if (state.step != AnnoyanceChatStep.recordMethod) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.content,
      recordMethod: recordMethod,
    );
  }

  void goBack() {
    state = switch (state.step) {
      AnnoyanceChatStep.category => const AnnoyanceChatState(),
      AnnoyanceChatStep.recordMethod => state.copyWith(
        step: AnnoyanceChatStep.category,
        clearCategory: true,
        clearRecordMethod: true,
      ),
      AnnoyanceChatStep.content => state.copyWith(
        step: AnnoyanceChatStep.recordMethod,
        clearRecordMethod: true,
      ),
      _ => state,
    };
  }

  void restart() {
    state = const AnnoyanceChatState();
  }
}
