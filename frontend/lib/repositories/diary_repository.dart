import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/diary_draft.dart';
import '../models/diary_response.dart';

class DiaryRepository {
  const DiaryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DiaryResponse> create({
    required DiaryRecordMethod recordMethod,
    required String content,
    required DiaryMediaFile? contentMedia,
    required DiaryDrawingFile? drawing,
    required int score,
    required bool isShared,
  }) async {
    final contentBytes =
        contentMedia == null ? null : await _readMediaBytes(contentMedia);
    final formData = FormData.fromMap({
      'request': MultipartFile.fromString(
        jsonEncode(
          _requestJson(
            recordMethod: recordMethod,
            content: content,
            score: score,
            isShared: isShared,
          ),
        ),
        filename: 'request.json',
        contentType: DioMediaType.parse(Headers.jsonContentType),
      ),
      if (contentMedia != null && contentBytes != null)
        'contentFile': MultipartFile.fromBytes(
          contentBytes,
          filename: contentMedia.name,
          contentType: DioMediaType.parse(contentMedia.mimeType),
        ),
      if (drawing case final selectedDrawing?)
        'drawingFile': MultipartFile.fromBytes(
          selectedDrawing.bytes,
          filename: selectedDrawing.name,
          contentType: DioMediaType.parse(selectedDrawing.mimeType),
        ),
    });

    final response = await _apiClient.post<DiaryResponse>(
      '/diaries',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      fromJsonT:
          (json) => DiaryResponse.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }

  Future<Uint8List> _readMediaBytes(DiaryMediaFile media) async {
    if (media.bytes.isNotEmpty) {
      return media.bytes;
    }
    return media.file.readAsBytes();
  }

  Map<String, dynamic> _requestJson({
    required DiaryRecordMethod recordMethod,
    required String content,
    required int score,
    required bool isShared,
  }) {
    return {
      'recordMethod': recordMethod.apiValue,
      'content': recordMethod == DiaryRecordMethod.text ? content : null,
      'score': score,
      'isShared': isShared,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
