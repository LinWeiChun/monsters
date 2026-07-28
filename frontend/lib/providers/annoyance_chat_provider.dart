import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/annoyance_drawing.dart';
import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';
import '../models/annoyance_response.dart';
import '../models/entry_draft_snapshot.dart';
import '../repositories/annoyance_repository.dart';
import 'api_client_provider.dart';

final annoyanceRepositoryProvider = Provider<AnnoyanceRepository>((ref) {
  return AnnoyanceRepository(ref.watch(apiClientProvider));
});

final annoyanceChatControllerProvider =
    StateNotifierProvider<AnnoyanceChatController, AnnoyanceChatState>((ref) {
      final controller = AnnoyanceChatController(
        ref.watch(annoyanceRepositoryProvider),
      );
      unawaited(controller.restoreDraft());
      return controller;
    });

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
    this.isRestoring = false,
    this.isSaving = false,
    this.draftError,
    this.lastSavedAt,
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
  final bool isRestoring;
  final bool isSaving;
  final String? draftError;
  final DateTime? lastSavedAt;

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
    return '●  草稿自動暫存 30 天，內容預設保持私人';
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
    bool? isRestoring,
    bool? isSaving,
    String? draftError,
    bool clearDraftError = false,
    DateTime? lastSavedAt,
    bool clearLastSavedAt = false,
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
      isRestoring: isRestoring ?? this.isRestoring,
      isSaving: isSaving ?? this.isSaving,
      draftError: clearDraftError ? null : draftError ?? this.draftError,
      lastSavedAt: clearLastSavedAt ? null : lastSavedAt ?? this.lastSavedAt,
    );
  }
}

class AnnoyanceChatController extends StateNotifier<AnnoyanceChatState> {
  AnnoyanceChatController([this._annoyanceRepository])
    : super(const AnnoyanceChatState());

  final AnnoyanceRepository? _annoyanceRepository;
  Timer? _saveDebounce;
  Future<void> _saveQueue = Future<void>.value();
  int _saveGeneration = 0;

  Future<void> restoreDraft() async {
    final repository = _annoyanceRepository;
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
      if (state.step != AnnoyanceChatStep.intro) {
        state = state.copyWith(isRestoring: false);
        return;
      }
      if (snapshot == null) {
        state = const AnnoyanceChatState();
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
    if (state.step != AnnoyanceChatStep.intro) {
      return;
    }
    state = state.copyWith(step: AnnoyanceChatStep.category);
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
  }

  void updateTextContent(String content) {
    if (state.step != AnnoyanceChatStep.content ||
        state.recordMethod != AnnoyanceRecordMethod.text) {
      return;
    }
    state = state.copyWith(contentText: content, clearContentMedia: true);
    _scheduleSave(debounce: true);
  }

  void selectContentMedia(AnnoyanceMediaFile media) {
    if (state.step != AnnoyanceChatStep.content ||
        state.recordMethod == AnnoyanceRecordMethod.text ||
        state.recordMethod != media.method) {
      return;
    }
    state = state.copyWith(contentMedia: media, clearContentText: true);
    _scheduleSave();
  }

  void clearContent() {
    if (state.step != AnnoyanceChatStep.content) {
      return;
    }
    state = state.copyWith(clearContentText: true, clearContentMedia: true);
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
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
    _scheduleSave();
  }

  Future<void> submit() async {
    final repository = _annoyanceRepository;
    final draft = state;
    if (repository == null ||
        draft.step != AnnoyanceChatStep.review ||
        !draft.canSubmit) {
      return;
    }
    _saveDebounce?.cancel();
    final saved = await _enqueueSave(state);
    if (!saved || state.step != AnnoyanceChatStep.review) {
      return;
    }
    state = state.copyWith(
      step: AnnoyanceChatStep.submitting,
      clearCreatedAnnoyance: true,
      clearSubmitError: true,
    );
    try {
      final response = await repository.submitDraft();
      state = state.copyWith(
        step: AnnoyanceChatStep.completed,
        createdAnnoyance: response,
        isSaving: false,
        clearDraftError: true,
      );
    } on ApiException catch (error) {
      state = draft.copyWith(submitError: error.message, isSaving: false);
    } catch (_) {
      state = draft.copyWith(submitError: '送出失敗，請稍後再試。', isSaving: false);
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
    _scheduleSave();
  }

  Future<void> restart() async {
    final repository = _annoyanceRepository;
    _saveDebounce?.cancel();
    _saveGeneration++;
    if (repository == null) {
      state = const AnnoyanceChatState();
      return;
    }
    await _saveQueue;
    try {
      await repository.discardDraft();
      state = const AnnoyanceChatState();
    } on ApiException catch (error) {
      state = state.copyWith(draftError: error.message, isSaving: false);
    } catch (_) {
      state = state.copyWith(draftError: '草稿刪除失敗，請稍後再試。', isSaving: false);
    }
  }

  void _scheduleSave({bool debounce = false}) {
    if (_annoyanceRepository == null ||
        state.isRestoring ||
        state.step == AnnoyanceChatStep.submitting ||
        state.step == AnnoyanceChatStep.completed) {
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

  Future<bool> _enqueueSave(AnnoyanceChatState snapshot) {
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

  Future<bool> _persist(AnnoyanceChatState snapshot, int generation) async {
    final repository = _annoyanceRepository;
    if (repository == null) {
      return true;
    }
    state = state.copyWith(isSaving: true, clearDraftError: true);
    try {
      final saved = await repository.saveDraft(
        step: _apiStep(snapshot.step),
        category: snapshot.category,
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

  AnnoyanceChatState _stateFromSnapshot(EntryDraftSnapshot snapshot) {
    final recordMethod = _recordMethod(snapshot.recordMethod);
    return AnnoyanceChatState(
      step: _step(snapshot.step),
      category:
          snapshot.category == null
              ? null
              : AnnoyanceCategory(
                code: snapshot.category!.code,
                name: snapshot.category!.name,
              ),
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

  AnnoyanceMediaFile? _mergeContentMedia(
    AnnoyanceMediaFile? current,
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

  AnnoyanceDrawingFile? _mergeDrawing(
    AnnoyanceDrawingFile? current,
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

  AnnoyanceMediaFile? _remoteContentMedia(
    AnnoyanceRecordMethod method,
    EntryDraftMediaSnapshot? media,
  ) {
    if (media == null || method == AnnoyanceRecordMethod.text) {
      return null;
    }
    return AnnoyanceMediaFile.fromDraft(
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

  AnnoyanceDrawingFile? _remoteDrawing(EntryDraftMediaSnapshot? media) {
    if (media == null) {
      return null;
    }
    return AnnoyanceDrawingFile.fromDraft(
      draftMediaId: media.id,
      downloadUrl: media.downloadUrl,
      name: media.fileName,
      mimeType: media.contentType,
      sizeBytes: media.sizeBytes,
    );
  }

  bool _sameMediaSelection(
    AnnoyanceMediaFile? current,
    AnnoyanceMediaFile? captured,
  ) {
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
    AnnoyanceDrawingFile? current,
    AnnoyanceDrawingFile? captured,
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

  AnnoyanceRecordMethod? _recordMethod(String? apiValue) {
    if (apiValue == null) {
      return null;
    }
    return AnnoyanceRecordMethod.values.firstWhere(
      (method) => method.apiValue == apiValue,
    );
  }

  AnnoyanceChatStep _step(String apiValue) {
    return AnnoyanceChatStep.values.firstWhere(
      (step) => _apiStep(step) == apiValue,
      orElse: () => AnnoyanceChatStep.intro,
    );
  }

  String _apiStep(AnnoyanceChatStep step) {
    return switch (step) {
      AnnoyanceChatStep.submitting || AnnoyanceChatStep.completed => 'REVIEW',
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
