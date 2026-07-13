import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/annoyance_drawing.dart';
import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';
import '../models/annoyance_response.dart';
import '../repositories/annoyance_repository.dart';
import 'api_client_provider.dart';

final annoyanceRepositoryProvider = Provider<AnnoyanceRepository>((ref) {
  return AnnoyanceRepository(ref.watch(apiClientProvider));
});

final annoyanceChatControllerProvider = StateNotifierProvider.autoDispose<
  AnnoyanceChatController,
  AnnoyanceChatState
>((ref) => AnnoyanceChatController(ref.watch(annoyanceRepositoryProvider)));

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
    this.createdAnnoyance,
    this.submitError,
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
  final AnnoyanceResponse? createdAnnoyance;
  final String? submitError;

  bool get isContentReady => switch (recordMethod) {
    AnnoyanceRecordMethod.text => contentText.trim().isNotEmpty,
    AnnoyanceRecordMethod.image ||
    AnnoyanceRecordMethod.audio ||
    AnnoyanceRecordMethod.video => contentMedia?.method == recordMethod,
    null => false,
  };

  bool get canSubmit {
    return category != null &&
        recordMethod != null &&
        isContentReady &&
        score != null &&
        isShared != null;
  }

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
    AnnoyanceResponse? createdAnnoyance,
    bool clearCreatedAnnoyance = false,
    String? submitError,
    bool clearSubmitError = false,
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
      createdAnnoyance:
          clearCreatedAnnoyance
              ? null
              : createdAnnoyance ?? this.createdAnnoyance,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }
}

class AnnoyanceChatController extends StateNotifier<AnnoyanceChatState> {
  AnnoyanceChatController([this._annoyanceRepository])
    : super(const AnnoyanceChatState());

  final AnnoyanceRepository? _annoyanceRepository;

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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
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
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
    );
  }

  void selectSharing(bool isShared) {
    if (state.step != AnnoyanceChatStep.sharing) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.review,
      isShared: isShared,
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
    );
  }

  Future<void> submit() async {
    final repository = _annoyanceRepository;
    final draft = state;
    if (repository == null ||
        draft.step != AnnoyanceChatStep.review ||
        !draft.canSubmit) {
      return;
    }

    state = draft.copyWith(
      step: AnnoyanceChatStep.submitting,
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
    );

    try {
      final response = await repository.create(
        category: draft.category!,
        recordMethod: draft.recordMethod!,
        content: draft.contentText.trim(),
        contentMedia: draft.contentMedia,
        drawing: draft.drawing,
        score: draft.score!,
        isShared: draft.isShared!,
      );
      state = state.copyWith(
        step: AnnoyanceChatStep.completed,
        createdAnnoyance: response,
      );
    } on ApiException catch (error) {
      state = draft.copyWith(submitError: error.message);
    } catch (_) {
      state = draft.copyWith(submitError: '送出失敗，請稍後再試。');
    }
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
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
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
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
      ),
      AnnoyanceChatStep.drawingDecision => state.copyWith(
        step: AnnoyanceChatStep.content,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
      ),
      AnnoyanceChatStep.drawing => state.copyWith(
        step: AnnoyanceChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
      ),
      AnnoyanceChatStep.score => state.copyWith(
        step: AnnoyanceChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
      ),
      AnnoyanceChatStep.sharing => state.copyWith(
        step: AnnoyanceChatStep.score,
        clearSharing: true,
        clearCreatedAnnoyance: true,
        clearSubmitError: true,
      ),
      AnnoyanceChatStep.review => state.copyWith(
        step: AnnoyanceChatStep.sharing,
        clearSubmitError: true,
      ),
      _ => state,
    };
  }

  void restart() {
    state = const AnnoyanceChatState();
  }
}
