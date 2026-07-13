import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/annoyance_drawing.dart';
import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';
import '../models/annoyance_response.dart';

class AnnoyanceRepository {
  const AnnoyanceRepository(this._apiClient);

  final ApiClient _apiClient;

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
          selectedContentMedia.bytes,
          filename: selectedContentMedia.name,
          contentType: DioMediaType.parse(selectedContentMedia.mimeType),
        ),
      if (drawing case final selectedDrawing?)
        'drawingFile': MultipartFile.fromBytes(
          selectedDrawing.bytes,
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
}
