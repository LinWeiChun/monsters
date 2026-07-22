import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/diary_draft.dart';
import '../models/diary_response.dart';
import '../repositories/diary_repository.dart';
import 'api_client_provider.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(ref.watch(apiClientProvider));
});

final diaryChatControllerProvider =
    StateNotifierProvider.autoDispose<DiaryChatController, DiaryChatState>(
      (ref) => DiaryChatController(ref.watch(diaryRepositoryProvider)),
    );

class DiaryChatState {
  const DiaryChatState({
    this.step = DiaryChatStep.intro,
    this.recordMethod,
    this.contentText = '',
    this.contentMedia,
    this.wantsDrawing,
    this.drawing,
    this.score,
    this.isShared,
    this.createdDiary,
    this.submitError,
  });

  final DiaryChatStep step;
  final DiaryRecordMethod? recordMethod;
  final String contentText;
  final DiaryMediaFile? contentMedia;
  final bool? wantsDrawing;
  final DiaryDrawingFile? drawing;
  final int? score;
  final bool? isShared;
  final DiaryResponse? createdDiary;
  final String? submitError;

  bool get isContentReady => switch (recordMethod) {
    DiaryRecordMethod.text => contentText.trim().isNotEmpty,
    DiaryRecordMethod.image ||
    DiaryRecordMethod.audio ||
    DiaryRecordMethod.video => contentMedia?.method == recordMethod,
    null => false,
  };

  bool get canSubmit {
    return recordMethod != null &&
        isContentReady &&
        score != null &&
        isShared != null;
  }

  DiaryChatState copyWith({
    DiaryChatStep? step,
    DiaryRecordMethod? recordMethod,
    bool clearRecordMethod = false,
    String? contentText,
    bool clearContentText = false,
    DiaryMediaFile? contentMedia,
    bool clearContentMedia = false,
    bool? wantsDrawing,
    bool clearDrawingChoice = false,
    DiaryDrawingFile? drawing,
    bool clearDrawing = false,
    int? score,
    bool clearScore = false,
    bool? isShared,
    bool clearSharing = false,
    DiaryResponse? createdDiary,
    bool clearCreatedDiary = false,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return DiaryChatState(
      step: step ?? this.step,
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
      createdDiary:
          clearCreatedDiary ? null : createdDiary ?? this.createdDiary,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }
}

class DiaryChatController extends StateNotifier<DiaryChatState> {
  DiaryChatController([this._diaryRepository]) : super(const DiaryChatState());

  final DiaryRepository? _diaryRepository;

  void begin() {
    if (state.step == DiaryChatStep.intro) {
      state = state.copyWith(step: DiaryChatStep.recordMethod);
    }
  }

  void selectRecordMethod(DiaryRecordMethod recordMethod) {
    if (state.step != DiaryChatStep.recordMethod) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.content,
      recordMethod: recordMethod,
      clearContentText: true,
      clearContentMedia: true,
      clearDrawingChoice: true,
      clearDrawing: true,
      clearScore: true,
      clearSharing: true,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  void updateTextContent(String content) {
    if (state.step != DiaryChatStep.content ||
        state.recordMethod != DiaryRecordMethod.text) {
      return;
    }
    state = state.copyWith(contentText: content, clearContentMedia: true);
  }

  void selectContentMedia(DiaryMediaFile media) {
    if (state.step != DiaryChatStep.content ||
        state.recordMethod == DiaryRecordMethod.text ||
        state.recordMethod != media.method) {
      return;
    }
    state = state.copyWith(contentMedia: media, clearContentText: true);
  }

  void clearContent() {
    if (state.step == DiaryChatStep.content) {
      state = state.copyWith(clearContentText: true, clearContentMedia: true);
    }
  }

  void confirmContent() {
    if (state.step != DiaryChatStep.content || !state.isContentReady) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.drawingDecision,
      clearDrawingChoice: true,
      clearDrawing: true,
      clearScore: true,
      clearSharing: true,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  void selectDrawingChoice(bool wantsDrawing) {
    if (state.step != DiaryChatStep.drawingDecision) {
      return;
    }
    state = state.copyWith(
      step: wantsDrawing ? DiaryChatStep.drawing : DiaryChatStep.score,
      wantsDrawing: wantsDrawing,
      clearDrawing: true,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  void saveDrawing(DiaryDrawingFile drawing) {
    if (state.step != DiaryChatStep.drawing ||
        drawing.sizeBytes <= 0 ||
        drawing.sizeBytes > EntryDrawingLimits.maxBytes ||
        !EntryDrawingLimits.mimeTypes.contains(drawing.mimeType)) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.score,
      wantsDrawing: true,
      drawing: drawing,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  void cancelDrawing() {
    if (state.step == DiaryChatStep.drawing) {
      state = state.copyWith(
        step: DiaryChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      );
    }
  }

  void selectScore(int score) {
    if (state.step != DiaryChatStep.score || !diaryScores.contains(score)) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.sharing,
      score: score,
      clearSharing: true,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  void selectSharing(bool isShared) {
    if (state.step != DiaryChatStep.sharing) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.review,
      isShared: isShared,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
  }

  Future<void> submit() async {
    final repository = _diaryRepository;
    final draft = state;
    if (repository == null ||
        draft.step != DiaryChatStep.review ||
        !draft.canSubmit) {
      return;
    }

    state = draft.copyWith(
      step: DiaryChatStep.submitting,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );

    try {
      final response = await repository.create(
        recordMethod: draft.recordMethod!,
        content: draft.contentText.trim(),
        contentMedia: draft.contentMedia,
        drawing: draft.drawing,
        score: draft.score!,
        isShared: draft.isShared!,
      );
      state = state.copyWith(
        step: DiaryChatStep.completed,
        createdDiary: response,
      );
    } on ApiException catch (error) {
      state = draft.copyWith(submitError: error.message);
    } catch (_) {
      state = draft.copyWith(submitError: '儲存失敗，請稍後再試。');
    }
  }

  void goBack() {
    state = switch (state.step) {
      DiaryChatStep.recordMethod => const DiaryChatState(),
      DiaryChatStep.content => state.copyWith(
        step: DiaryChatStep.recordMethod,
        clearRecordMethod: true,
        clearContentText: true,
        clearContentMedia: true,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      ),
      DiaryChatStep.drawingDecision => state.copyWith(
        step: DiaryChatStep.content,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      ),
      DiaryChatStep.drawing => state.copyWith(
        step: DiaryChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      ),
      DiaryChatStep.score => state.copyWith(
        step: DiaryChatStep.drawingDecision,
        clearDrawingChoice: true,
        clearDrawing: true,
        clearScore: true,
        clearSharing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      ),
      DiaryChatStep.sharing => state.copyWith(
        step: DiaryChatStep.score,
        clearSharing: true,
        clearCreatedDiary: true,
        clearSubmitError: true,
      ),
      DiaryChatStep.review => state.copyWith(
        step: DiaryChatStep.sharing,
        clearSubmitError: true,
      ),
      _ => state,
    };
  }

  void restart() {
    state = const DiaryChatState();
  }
}
