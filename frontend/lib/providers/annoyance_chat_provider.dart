import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annoyance_drawing.dart';
import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';

final annoyanceChatControllerProvider = StateNotifierProvider.autoDispose<
  AnnoyanceChatController,
  AnnoyanceChatState
>((ref) => AnnoyanceChatController());

class AnnoyanceChatState {
  const AnnoyanceChatState({
    this.step = AnnoyanceChatStep.intro,
    this.category,
    this.recordMethod,
    this.contentText = '',
    this.contentMedia,
    this.wantsDrawing,
    this.drawing,
    this.score,
    this.isShared,
  });

  final AnnoyanceChatStep step;
  final AnnoyanceCategory? category;
  final AnnoyanceRecordMethod? recordMethod;
  final String contentText;
  final AnnoyanceMediaFile? contentMedia;
  final bool? wantsDrawing;
  final AnnoyanceDrawingFile? drawing;
  final int? score;
  final bool? isShared;

  bool get isContentReady => switch (recordMethod) {
    AnnoyanceRecordMethod.text => contentText.trim().isNotEmpty,
    AnnoyanceRecordMethod.image ||
    AnnoyanceRecordMethod.audio ||
    AnnoyanceRecordMethod.video => contentMedia?.method == recordMethod,
    null => false,
  };

  AnnoyanceChatState copyWith({
    AnnoyanceChatStep? step,
    AnnoyanceCategory? category,
    bool clearCategory = false,
    AnnoyanceRecordMethod? recordMethod,
    bool clearRecordMethod = false,
    String? contentText,
    bool clearContentText = false,
    AnnoyanceMediaFile? contentMedia,
    bool clearContentMedia = false,
    bool? wantsDrawing,
    bool clearDrawingChoice = false,
    AnnoyanceDrawingFile? drawing,
    bool clearDrawing = false,
    int? score,
    bool clearScore = false,
    bool? isShared,
    bool clearSharing = false,
  }) {
    return AnnoyanceChatState(
      step: step ?? this.step,
      category: clearCategory ? null : category ?? this.category,
      recordMethod:
          clearRecordMethod ? null : recordMethod ?? this.recordMethod,
      contentText: clearContentText ? '' : contentText ?? this.contentText,
      contentMedia:
          clearContentMedia ? null : contentMedia ?? this.contentMedia,
      wantsDrawing:
          clearDrawingChoice ? null : wantsDrawing ?? this.wantsDrawing,
      drawing: clearDrawing ? null : drawing ?? this.drawing,
      score: clearScore ? null : score ?? this.score,
      isShared: clearSharing ? null : isShared ?? this.isShared,
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
      clearContentText: true,
      clearContentMedia: true,
      clearDrawingChoice: true,
      clearDrawing: true,
      clearScore: true,
      clearSharing: true,
    );
  }

  void selectRecordMethod(AnnoyanceRecordMethod recordMethod) {
    if (state.step != AnnoyanceChatStep.recordMethod) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.content,
      recordMethod: recordMethod,
      clearContentText: true,
      clearContentMedia: true,
      clearDrawingChoice: true,
      clearDrawing: true,
      clearScore: true,
      clearSharing: true,
    );
  }

  void updateTextContent(String content) {
    if (state.step != AnnoyanceChatStep.content ||
        state.recordMethod != AnnoyanceRecordMethod.text) {
      return;
    }
    state = state.copyWith(contentText: content, clearContentMedia: true);
  }

  void selectContentMedia(AnnoyanceMediaFile media) {
    if (state.step != AnnoyanceChatStep.content ||
        state.recordMethod == AnnoyanceRecordMethod.text ||
        state.recordMethod != media.method) {
      return;
    }
    state = state.copyWith(contentMedia: media, clearContentText: true);
  }

  void clearContent() {
    if (state.step != AnnoyanceChatStep.content) {
      return;
    }
    state = state.copyWith(clearContentText: true, clearContentMedia: true);
  }

  void confirmContent() {
    if (state.step != AnnoyanceChatStep.content || !state.isContentReady) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.drawingDecision,
      clearDrawingChoice: true,
      clearDrawing: true,
      clearScore: true,
      clearSharing: true,
    );
  }

  void selectDrawingChoice(bool wantsDrawing) {
    if (state.step != AnnoyanceChatStep.drawingDecision) {
      return;
    }
    state = state.copyWith(
      step: wantsDrawing ? AnnoyanceChatStep.drawing : AnnoyanceChatStep.score,
      wantsDrawing: wantsDrawing,
      clearDrawing: true,
    );
  }

  void saveDrawing(AnnoyanceDrawingFile drawing) {
    if (state.step != AnnoyanceChatStep.drawing ||
        drawing.sizeBytes <= 0 ||
        drawing.sizeBytes > AnnoyanceDrawingLimits.maxBytes ||
        !AnnoyanceDrawingLimits.mimeTypes.contains(drawing.mimeType)) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.score,
      wantsDrawing: true,
      drawing: drawing,
    );
  }

  void cancelDrawing() {
    if (state.step != AnnoyanceChatStep.drawing) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.drawingDecision,
      clearDrawingChoice: true,
      clearDrawing: true,
    );
  }

  void selectScore(int score) {
    if (state.step != AnnoyanceChatStep.score ||
        !annoyanceScores.contains(score)) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.sharing,
      score: score,
      clearSharing: true,
    );
  }

  void selectSharing(bool isShared) {
    if (state.step != AnnoyanceChatStep.sharing) {
      return;
    }
    state = state.copyWith(step: AnnoyanceChatStep.review, isShared: isShared);
  }

  void goBack() {
    state = switch (state.step) {
      AnnoyanceChatStep.category => const AnnoyanceChatState(),
      AnnoyanceChatStep.recordMethod => state.copyWith(
        step: AnnoyanceChatStep.category,
        clearCategory: true,
        clearRecordMethod: true,
        clearContentText: true,
        clearContentMedia: true,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
      ),
      AnnoyanceChatStep.content => state.copyWith(
        step: AnnoyanceChatStep.recordMethod,
        clearRecordMethod: true,
        clearContentText: true,
        clearContentMedia: true,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
      ),
      AnnoyanceChatStep.drawingDecision => state.copyWith(
        step: AnnoyanceChatStep.content,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
      ),
      AnnoyanceChatStep.drawing => state.copyWith(
        step: AnnoyanceChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
      ),
      AnnoyanceChatStep.score => state.copyWith(
        step: AnnoyanceChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
      ),
      AnnoyanceChatStep.sharing => state.copyWith(
        step: AnnoyanceChatStep.score,
        clearSharing: true,
      ),
      AnnoyanceChatStep.review => state.copyWith(
        step: AnnoyanceChatStep.sharing,
      ),
      _ => state,
    };
  }

  void restart() {
    state = const AnnoyanceChatState();
  }
}
