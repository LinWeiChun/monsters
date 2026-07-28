import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/diary_draft.dart';
import '../models/diary_response.dart';
import '../models/entry_draft_snapshot.dart';
import '../repositories/diary_repository.dart';
import 'api_client_provider.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(ref.watch(apiClientProvider));
});

final diaryChatControllerProvider =
    StateNotifierProvider<DiaryChatController, DiaryChatState>((ref) {
      final controller = DiaryChatController(
        ref.watch(diaryRepositoryProvider),
      );
      unawaited(controller.restoreDraft());
      return controller;
    });

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
    this.isRestoring = false,
    this.isSaving = false,
    this.draftError,
    this.lastSavedAt,
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
  final bool isRestoring;
  final bool isSaving;
  final String? draftError;
  final DateTime? lastSavedAt;

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

  String get draftStatusMessage {
    if (isRestoring) {
      return '●  正在載入草稿…';
    }
    if (isSaving) {
      return '●  草稿暫存中…';
    }
    if (draftError != null) {
      return '●  草稿暫存失敗，將在下次操作重試';
    }
    return '●  草稿自動暫存 30 天，可跨裝置繼續';
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
    bool? isRestoring,
    bool? isSaving,
    String? draftError,
    bool clearDraftError = false,
    DateTime? lastSavedAt,
    bool clearLastSavedAt = false,
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
      isRestoring: isRestoring ?? this.isRestoring,
      isSaving: isSaving ?? this.isSaving,
      draftError: clearDraftError ? null : draftError ?? this.draftError,
      lastSavedAt: clearLastSavedAt ? null : lastSavedAt ?? this.lastSavedAt,
    );
  }
}

class DiaryChatController extends StateNotifier<DiaryChatState> {
  DiaryChatController([this._diaryRepository]) : super(const DiaryChatState());

  final DiaryRepository? _diaryRepository;
  Timer? _saveDebounce;
  Future<void> _saveQueue = Future<void>.value();
  int _saveGeneration = 0;

  Future<void> restoreDraft() async {
    final repository = _diaryRepository;
    if (repository == null || state.isRestoring) {
      return;
    }
    state = state.copyWith(
      isRestoring: true,
      clearDraftError: true,
      clearSubmitError: true,
    );
    try {
      final snapshot = await repository.getDraft();
      if (state.step != DiaryChatStep.intro) {
        state = state.copyWith(isRestoring: false);
        return;
      }
      if (snapshot == null) {
        state = const DiaryChatState();
        return;
      }
      state = _stateFromSnapshot(snapshot);
    } on ApiException catch (error) {
      state = state.copyWith(isRestoring: false, draftError: error.message);
    } catch (_) {
      state = state.copyWith(isRestoring: false, draftError: '草稿載入失敗，仍可繼續記錄。');
    }
  }

  void begin() {
    if (state.step == DiaryChatStep.intro) {
      state = state.copyWith(step: DiaryChatStep.recordMethod);
      _scheduleSave();
    }
  }

  void selectRecordMethod(DiaryRecordMethod recordMethod) {
    if (state.step != DiaryChatStep.recordMethod) {
      return;
    }
    chooseRecordMethod(recordMethod);
    confirmRecordMethod();
  }

  void chooseRecordMethod(DiaryRecordMethod recordMethod) {
    if (state.step != DiaryChatStep.recordMethod) {
      return;
    }
    state = state.copyWith(
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
    _scheduleSave();
  }

  void confirmRecordMethod() {
    if (state.step != DiaryChatStep.recordMethod ||
        state.recordMethod == null) {
      return;
    }
    state = state.copyWith(step: DiaryChatStep.content);
    _scheduleSave();
  }

  void updateTextContent(String content) {
    if (state.step != DiaryChatStep.content ||
        state.recordMethod != DiaryRecordMethod.text) {
      return;
    }
    state = state.copyWith(contentText: content, clearContentMedia: true);
    _scheduleSave(debounce: true);
  }

  void selectContentMedia(DiaryMediaFile media) {
    if (state.step != DiaryChatStep.content ||
        state.recordMethod == DiaryRecordMethod.text ||
        state.recordMethod != media.method) {
      return;
    }
    state = state.copyWith(contentMedia: media, clearContentText: true);
    _scheduleSave();
  }

  void clearContent() {
    if (state.step == DiaryChatStep.content) {
      state = state.copyWith(clearContentText: true, clearContentMedia: true);
      _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
      _scheduleSave();
    }
  }

  void selectScore(int score) {
    if (state.step != DiaryChatStep.score || !diaryScores.contains(score)) {
      return;
    }
    chooseScore(score);
    confirmScore();
  }

  void chooseScore(int score) {
    if (state.step != DiaryChatStep.score || !diaryScores.contains(score)) {
      return;
    }
    state = state.copyWith(
      score: score,
      clearSharing: true,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
    _scheduleSave();
  }

  void confirmScore() {
    if (state.step != DiaryChatStep.score || state.score == null) {
      return;
    }
    state = state.copyWith(step: DiaryChatStep.sharing);
    _scheduleSave();
  }

  void selectSharing(bool isShared) {
    if (state.step != DiaryChatStep.sharing) {
      return;
    }
    chooseSharing(isShared);
    confirmSharing();
  }

  void chooseSharing(bool isShared) {
    if (state.step != DiaryChatStep.sharing) {
      return;
    }
    state = state.copyWith(
      isShared: isShared,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
    _scheduleSave();
  }

  void confirmSharing() {
    if (state.step != DiaryChatStep.sharing || state.isShared == null) {
      return;
    }
    state = state.copyWith(step: DiaryChatStep.review);
    _scheduleSave();
  }

  Future<void> submit() async {
    final repository = _diaryRepository;
    final draft = state;
    if (repository == null ||
        draft.step != DiaryChatStep.review ||
        !draft.canSubmit) {
      return;
    }
    _saveDebounce?.cancel();
    final saved = await _enqueueSave(state);
    if (!saved || state.step != DiaryChatStep.review) {
      return;
    }
    state = state.copyWith(
      step: DiaryChatStep.submitting,
      clearCreatedDiary: true,
      clearSubmitError: true,
    );
    try {
      final response = await repository.submitDraft();
      state = state.copyWith(
        step: DiaryChatStep.completed,
        createdDiary: response,
        isSaving: false,
        clearDraftError: true,
      );
    } on ApiException catch (error) {
      state = draft.copyWith(submitError: error.message, isSaving: false);
    } catch (_) {
      state = draft.copyWith(submitError: '儲存失敗，請稍後再試。', isSaving: false);
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
    _scheduleSave();
  }

  Future<void> restart() async {
    final repository = _diaryRepository;
    _saveDebounce?.cancel();
    _saveGeneration++;
    if (repository == null) {
      state = const DiaryChatState();
      return;
    }
    await _saveQueue;
    try {
      await repository.discardDraft();
      state = const DiaryChatState();
    } on ApiException catch (error) {
      state = state.copyWith(draftError: error.message, isSaving: false);
    } catch (_) {
      state = state.copyWith(draftError: '草稿刪除失敗，請稍後再試。', isSaving: false);
    }
  }

  void _scheduleSave({bool debounce = false}) {
    if (_diaryRepository == null ||
        state.isRestoring ||
        state.step == DiaryChatStep.submitting ||
        state.step == DiaryChatStep.completed) {
      return;
    }
    _saveDebounce?.cancel();
    if (debounce) {
      _saveDebounce = Timer(
        const Duration(milliseconds: 750),
        () => unawaited(_enqueueSave(state)),
      );
      return;
    }
    unawaited(_enqueueSave(state));
  }

  Future<bool> _enqueueSave(DiaryChatState snapshot) {
    final completer = Completer<bool>();
    final generation = _saveGeneration;
    _saveQueue = _saveQueue.then((_) async {
      if (generation != _saveGeneration) {
        completer.complete(true);
        return;
      }
      completer.complete(await _persist(snapshot, generation));
    });
    return completer.future;
  }

  Future<bool> _persist(DiaryChatState snapshot, int generation) async {
    final repository = _diaryRepository;
    if (repository == null) {
      return true;
    }
    state = state.copyWith(isSaving: true, clearDraftError: true);
    try {
      final saved = await repository.saveDraft(
        step: _apiStep(snapshot.step),
        recordMethod: snapshot.recordMethod,
        content: snapshot.contentText,
        contentMedia: snapshot.contentMedia,
        wantsDrawing: snapshot.wantsDrawing,
        drawing: snapshot.drawing,
        score: snapshot.score,
        isShared: snapshot.isShared,
      );
      if (generation == _saveGeneration) {
        final currentContent = state.contentMedia;
        final currentDrawing = state.drawing;
        state = state.copyWith(
          contentMedia:
              _sameMediaSelection(currentContent, snapshot.contentMedia)
                  ? _mergeContentMedia(currentContent, saved)
                  : currentContent,
          drawing:
              _sameDrawingSelection(currentDrawing, snapshot.drawing)
                  ? _mergeDrawing(currentDrawing, saved)
                  : currentDrawing,
          isSaving: false,
          lastSavedAt: DateTime.now(),
          clearDraftError: true,
        );
      }
      return true;
    } on ApiException catch (error) {
      if (generation == _saveGeneration) {
        state = state.copyWith(isSaving: false, draftError: error.message);
      }
      return false;
    } catch (_) {
      if (generation == _saveGeneration) {
        state = state.copyWith(isSaving: false, draftError: '草稿暫存失敗，請稍後再試。');
      }
      return false;
    }
  }

  DiaryChatState _stateFromSnapshot(EntryDraftSnapshot snapshot) {
    final recordMethod = _recordMethod(snapshot.recordMethod);
    return DiaryChatState(
      step: _step(snapshot.step),
      recordMethod: recordMethod,
      contentText: snapshot.content ?? '',
      contentMedia:
          recordMethod == null
              ? null
              : _remoteContentMedia(recordMethod, snapshot.contentMedia),
      wantsDrawing: snapshot.wantsDrawing,
      drawing: _remoteDrawing(snapshot.drawingMedia),
      score: snapshot.score,
      isShared: snapshot.isShared,
      lastSavedAt: DateTime.now(),
    );
  }

  DiaryMediaFile? _mergeContentMedia(
    DiaryMediaFile? current,
    EntryDraftSnapshot saved,
  ) {
    final remote = saved.contentMedia;
    if (remote == null) {
      return null;
    }
    if (current != null &&
        (current.draftMediaId == remote.id ||
            (current.draftMediaId == null &&
                current.name == remote.fileName &&
                current.mimeType == remote.contentType))) {
      return current.withDraftReference(
        draftMediaId: remote.id,
        downloadUrl: remote.downloadUrl,
      );
    }
    final method = _recordMethod(saved.recordMethod);
    return method == null ? current : _remoteContentMedia(method, remote);
  }

  DiaryDrawingFile? _mergeDrawing(
    DiaryDrawingFile? current,
    EntryDraftSnapshot saved,
  ) {
    final remote = saved.drawingMedia;
    if (remote == null) {
      return null;
    }
    if (current != null &&
        (current.draftMediaId == remote.id ||
            (current.draftMediaId == null &&
                current.name == remote.fileName &&
                current.mimeType == remote.contentType))) {
      return current.withDraftReference(
        draftMediaId: remote.id,
        downloadUrl: remote.downloadUrl,
      );
    }
    return _remoteDrawing(remote);
  }

  DiaryMediaFile? _remoteContentMedia(
    DiaryRecordMethod method,
    EntryDraftMediaSnapshot? media,
  ) {
    if (media == null || method == DiaryRecordMethod.text) {
      return null;
    }
    return DiaryMediaFile.fromDraft(
      method: method,
      draftMediaId: media.id,
      downloadUrl: media.downloadUrl,
      name: media.fileName,
      mimeType: media.contentType,
      sizeBytes: media.sizeBytes,
      duration:
          media.durationSeconds == null
              ? null
              : Duration(milliseconds: (media.durationSeconds! * 1000).round()),
    );
  }

  DiaryDrawingFile? _remoteDrawing(EntryDraftMediaSnapshot? media) {
    if (media == null) {
      return null;
    }
    return DiaryDrawingFile.fromDraft(
      draftMediaId: media.id,
      downloadUrl: media.downloadUrl,
      name: media.fileName,
      mimeType: media.contentType,
      sizeBytes: media.sizeBytes,
    );
  }

  bool _sameMediaSelection(DiaryMediaFile? current, DiaryMediaFile? captured) {
    if (identical(current, captured)) {
      return true;
    }
    if (current == null || captured == null) {
      return false;
    }
    return current.method == captured.method &&
        current.name == captured.name &&
        current.mimeType == captured.mimeType &&
        current.sizeBytes == captured.sizeBytes &&
        (captured.draftMediaId == null ||
            current.draftMediaId == captured.draftMediaId);
  }

  bool _sameDrawingSelection(
    DiaryDrawingFile? current,
    DiaryDrawingFile? captured,
  ) {
    if (identical(current, captured)) {
      return true;
    }
    if (current == null || captured == null) {
      return false;
    }
    return current.name == captured.name &&
        current.mimeType == captured.mimeType &&
        current.sizeBytes == captured.sizeBytes &&
        (captured.draftMediaId == null ||
            current.draftMediaId == captured.draftMediaId);
  }

  DiaryRecordMethod? _recordMethod(String? apiValue) {
    if (apiValue == null) {
      return null;
    }
    return DiaryRecordMethod.values.firstWhere(
      (method) => method.apiValue == apiValue,
    );
  }

  DiaryChatStep _step(String apiValue) {
    return DiaryChatStep.values.firstWhere(
      (step) => _apiStep(step) == apiValue,
      orElse: () => DiaryChatStep.intro,
    );
  }

  String _apiStep(DiaryChatStep step) {
    return switch (step) {
      DiaryChatStep.submitting || DiaryChatStep.completed => 'REVIEW',
      _ =>
        step.name
            .replaceAllMapped(RegExp('[A-Z]'), (match) => '_${match.group(0)}')
            .toUpperCase(),
    };
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
