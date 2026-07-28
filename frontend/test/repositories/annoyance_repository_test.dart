import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/repositories/annoyance_repository.dart';

void main() {
  test('creates annoyance with multipart request payload', () async {
    final adapter = _AnnoyanceCreateAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = AnnoyanceRepository(
      ApiClient(config: _config(), dio: dio),
    );

    final response = await repository.create(
      category: annoyanceCategories.first,
      recordMethod: AnnoyanceRecordMethod.image,
      content: '',
      contentMedia: _imageMedia(),
      drawing: null,
      score: 4,
      isShared: true,
    );

    expect(response.id, 101);
    expect(response.reward, isNull);
    expect(adapter.path, '/annoyances');
    expect(adapter.method, 'POST');
    expect(adapter.formData, isNotNull);

    expect(
      adapter.formData!.files.map((file) => file.key),
      containsAll(['request', 'contentFile']),
    );
    final requestPart = adapter.formData!.files.singleWhere(
      (file) => file.key == 'request',
    );
    expect(requestPart.value.filename, 'request.json');
    expect(
      requestPart.value.contentType.toString(),
      startsWith(Headers.jsonContentType),
    );
  });

  test('uses durable annoyance draft endpoints with category state', () async {
    final adapter = _AnnoyanceDraftAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = AnnoyanceRepository(
      ApiClient(config: _config(), dio: dio),
    );

    final restored = await repository.getDraft();
    final saved = await repository.saveDraft(
      step: 'REVIEW',
      category: annoyanceCategories.first,
      recordMethod: AnnoyanceRecordMethod.text,
      content: '可繼續的煩惱',
      contentMedia: null,
      wantsDrawing: false,
      drawing: null,
      score: 3,
      isShared: false,
    );
    final submitted = await repository.submitDraft();
    await repository.discardDraft();

    expect(restored?.category?.code, 'ACADEMIC');
    expect(saved.content, '可繼續的煩惱');
    expect(submitted.id, 101);
    expect(adapter.requests, [
      'GET /annoyances/draft',
      'PUT /annoyances/draft',
      'POST /annoyances/draft/submit',
      'DELETE /annoyances/draft',
    ]);
  });
}

AppConfig _config() {
  return const AppConfig(
    apiBaseUrl: 'http://example.com/api',
    connectTimeout: Duration(seconds: 1),
    receiveTimeout: Duration(seconds: 2),
    sendTimeout: Duration(seconds: 3),
  );
}

AnnoyanceMediaFile _imageMedia() {
  final bytes = Uint8List.fromList([1, 2, 3]);
  return AnnoyanceMediaFile(
    method: AnnoyanceRecordMethod.image,
    file: XFile.fromData(bytes, name: 'content.png', mimeType: 'image/png'),
    bytes: bytes,
    name: 'content.png',
    mimeType: 'image/png',
    sizeBytes: bytes.length,
    duration: null,
  );
}

class _AnnoyanceCreateAdapter implements HttpClientAdapter {
  String? path;
  String? method;
  FormData? formData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    method = options.method;
    formData = options.data as FormData;

    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'Annoyance creation success',
        'data': {
          'id': 101,
          'category': {'code': 'ACADEMIC', 'name': '學業'},
          'recordMethod': 'IMAGE',
          'content': null,
          'score': 4,
          'isShared': true,
          'isSolved': false,
          'occurredAt': '2026-07-13T10:00:00+08:00',
          'media': [
            {
              'id': 201,
              'type': 'image',
              'contentType': 'image/png',
              'sizeBytes': 3,
              'durationSeconds': null,
              'downloadUrl': '/api/annoyances/101/media/201',
            },
          ],
          'reward': null,
        },
      }),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _AnnoyanceDraftAdapter implements HttpClientAdapter {
  final List<String> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add('${options.method} ${options.path}');
    final data =
        options.path == '/annoyances/draft/submit'
            ? {
              'id': 101,
              'category': {'code': 'ACADEMIC', 'name': '學業'},
              'recordMethod': 'TEXT',
              'content': '可繼續的煩惱',
              'score': 3,
              'isShared': false,
              'isSolved': false,
              'occurredAt': '2026-07-28T10:00:00+08:00',
              'media': <Object>[],
              'reward': null,
            }
            : options.method == 'DELETE'
            ? null
            : {
              'draft': {
                'id': 501,
                'entryType': 'ANNOYANCE',
                'step': 'REVIEW',
                'category': {'code': 'ACADEMIC', 'name': '學業'},
                'recordMethod': 'TEXT',
                'content': '可繼續的煩惱',
                'wantsDrawing': false,
                'score': 3,
                'isShared': false,
                'expiresAt': '2026-08-27T10:00:00+08:00',
                'contentMedia': null,
                'drawingMedia': null,
              },
            };
    return ResponseBody.fromString(
      jsonEncode({'success': true, 'message': 'success', 'data': data}),
      options.path == '/annoyances/draft/submit' ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
