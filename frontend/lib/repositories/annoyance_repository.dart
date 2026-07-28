import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/annoyance_drawing.dart';
import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';
import '../models/annoyance_response.dart';
import '../models/entry_draft_snapshot.dart';

class AnnoyanceRepository {
  const AnnoyanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<EntryDraftSnapshot?> getDraft() async {
    final response = await _apiClient.get<EntryDraftEnvelopeModel>(
      '/annoyances/draft',
      fromJsonT:
          (json) =>
              EntryDraftEnvelopeModel.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message);
    return response.data.draft;
  }

  Future<EntryDraftSnapshot> saveDraft({
    required String step,
    required AnnoyanceCategory? category,
    required AnnoyanceRecordMethod? recordMethod,
    required String content,
    required AnnoyanceMediaFile? contentMedia,
    required bool? wantsDrawing,
    required AnnoyanceDrawingFile? drawing,
    required int? score,
    required bool? isShared,
  }) async {
    final contentBytes =
        contentMedia == null || contentMedia.isPersistedDraft
            ? null
            : await _readMediaBytes(contentMedia);
    final drawingBytes =
        drawing == null || drawing.isPersistedDraft
            ? null
            : await _readDrawingBytes(drawing);
    final formData = FormData.fromMap({
      'request': MultipartFile.fromString(
        jsonEncode({
          'step': step,
          'categoryCode': category?.code,
          'recordMethod': recordMethod?.apiValue,
          'content':
              recordMethod == AnnoyanceRecordMethod.text ? content : null,
          'wantsDrawing': wantsDrawing,
          'score': score,
          'isShared': isShared,
          'existingContentMediaId': contentMedia?.draftMediaId,
          'existingDrawingMediaId': drawing?.draftMediaId,
        }),
        filename: 'request.json',
        contentType: DioMediaType.parse(Headers.jsonContentType),
      ),
      if (contentMedia != null && contentBytes != null)
        'contentFile': MultipartFile.fromBytes(
          contentBytes,
          filename: contentMedia.name,
          contentType: DioMediaType.parse(contentMedia.mimeType),
        ),
      if (drawing != null && drawingBytes != null)
        'drawingFile': MultipartFile.fromBytes(
          drawingBytes,
          filename: drawing.name,
          contentType: DioMediaType.parse(drawing.mimeType),
        ),
    });
    final response = await _apiClient.put<EntryDraftEnvelopeModel>(
      '/annoyances/draft',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      fromJsonT:
          (json) =>
              EntryDraftEnvelopeModel.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message);
    final draft = response.data.draft;
    if (draft == null) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '草稿回應格式錯誤。',
      );
    }
    return draft;
  }

  Future<void> discardDraft() async {
    final response = await _apiClient.delete<Object?>(
      '/annoyances/draft',
      fromJsonT: (json) => json,
    );
    _requireSuccess(response.success, response.message);
  }

  Future<AnnoyanceResponse> submitDraft() async {
    final response = await _apiClient.post<AnnoyanceResponse>(
      '/annoyances/draft/submit',
      fromJsonT:
          (json) => AnnoyanceResponse.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message);
    return response.data;
  }

  Future<AnnoyanceResponse> create({
    required AnnoyanceCategory category,
    required AnnoyanceRecordMethod recordMethod,
    required String content,
    required AnnoyanceMediaFile? contentMedia,
    required AnnoyanceDrawingFile? drawing,
    required int score,
    required bool isShared,
  }) async {
    final formData = FormData.fromMap({
      'request': MultipartFile.fromString(
        jsonEncode(
          _requestJson(
            category: category,
            recordMethod: recordMethod,
            content: content,
            score: score,
            isShared: isShared,
          ),
        ),
        filename: 'request.json',
        contentType: DioMediaType.parse(Headers.jsonContentType),
      ),
      if (contentMedia case final selectedContentMedia?)
        'contentFile': MultipartFile.fromBytes(
          await _readMediaBytes(selectedContentMedia),
          filename: selectedContentMedia.name,
          contentType: DioMediaType.parse(selectedContentMedia.mimeType),
        ),
      if (drawing case final selectedDrawing?)
        'drawingFile': MultipartFile.fromBytes(
          await _readDrawingBytes(selectedDrawing),
          filename: selectedDrawing.name,
          contentType: DioMediaType.parse(selectedDrawing.mimeType),
        ),
    });

    final response = await _apiClient.post<AnnoyanceResponse>(
      '/annoyances',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      fromJsonT:
          (json) => AnnoyanceResponse.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }

  Map<String, dynamic> _requestJson({
    required AnnoyanceCategory category,
    required AnnoyanceRecordMethod recordMethod,
    required String content,
    required int score,
    required bool isShared,
  }) {
    return {
      'categoryCode': category.code,
      'recordMethod': recordMethod.apiValue,
      'content': recordMethod == AnnoyanceRecordMethod.text ? content : null,
      'score': score,
      'isShared': isShared,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Future<Uint8List> _readMediaBytes(AnnoyanceMediaFile media) async {
    if (media.bytes.isNotEmpty) {
      return media.bytes;
    }
    final file = media.file;
    if (file == null) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '找不到待上傳的媒體檔案。',
      );
    }
    return file.readAsBytes();
  }

  Future<Uint8List> _readDrawingBytes(AnnoyanceDrawingFile drawing) async {
    if (drawing.bytes.isNotEmpty) {
      return drawing.bytes;
    }
    final file = drawing.file;
    if (file == null) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: '找不到待上傳的心情圖。',
      );
    }
    return file.readAsBytes();
  }

  void _requireSuccess(bool success, String message) {
    if (!success) {
      throw ApiException(type: ApiErrorType.unknown, message: message);
    }
  }
}
