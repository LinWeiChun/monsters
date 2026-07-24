import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/diary_draft.dart';
import 'package:monsters/repositories/diary_repository.dart';

void main() {
  test('creates diary with multipart request and content file', () async {
    final adapter = _DiaryCreateAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = DiaryRepository(ApiClient(config: _config(), dio: dio));

    final response = await repository.create(
      recordMethod: DiaryRecordMethod.image,
      content: '',
      contentMedia: _imageMedia(),
      drawing: null,
      score: 4,
      isShared: false,
    );

    expect(response.id, 301);
    expect(response.reward, isNull);
    expect(adapter.path, '/diaries');
    expect(adapter.method, 'POST');
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

  test('sends one-based boundary scores in multipart request JSON', () async {
    for (final score in <int>[1, 5]) {
      final adapter = _DiaryCreateAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repository = DiaryRepository(
        ApiClient(config: _config(), dio: dio),
      );

      await repository.create(
        recordMethod: DiaryRecordMethod.text,
        content: '今天的心情是 $score 分',
        contentMedia: null,
        drawing: null,
        score: score,
        isShared: false,
      );

      expect(adapter.rawRequestBody, contains('"score":$score'));
    }
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

DiaryMediaFile _imageMedia() {
  final bytes = Uint8List.fromList([1, 2, 3]);
  return DiaryMediaFile(
    method: DiaryRecordMethod.image,
    file: XFile.fromData(bytes, name: 'content.png', mimeType: 'image/png'),
    bytes: bytes,
    name: 'content.png',
    mimeType: 'image/png',
    sizeBytes: bytes.length,
    duration: null,
  );
}

class _DiaryCreateAdapter implements HttpClientAdapter {
  String? path;
  String? method;
  FormData? formData;
  String? rawRequestBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    path = options.path;
    method = options.method;
    formData = options.data as FormData;
    final requestBytes = await requestStream?.fold<List<int>>(
      <int>[],
      (bytes, chunk) => bytes..addAll(chunk),
    );
    rawRequestBody =
        requestBytes == null
            ? null
            : utf8.decode(requestBytes, allowMalformed: true);

    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'message': 'Diary creation success',
        'data': {
          'id': 301,
          'recordMethod': 'IMAGE',
          'content': null,
          'score': 4,
          'isShared': false,
          'occurredAt': '2026-07-22T10:00:00+08:00',
          'media': [
            {
              'id': 401,
              'type': 'image',
              'contentType': 'image/png',
              'sizeBytes': 3,
              'durationSeconds': null,
              'downloadUrl': '/api/diaries/301/media/401',
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
