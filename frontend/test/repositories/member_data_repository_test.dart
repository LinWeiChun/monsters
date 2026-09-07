import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/repositories/member_data_repository.dart';

void main() {
  test('reads owner-only profile and pending workflow targets', () async {
    RequestOptions? captured;
    final repository = _repository((request) {
      captured = request;
      return _success({
        'publicId': '00000000-0000-0000-0000-000000000001',
        'email': 'member@example.test',
        'publicNickname': '貘友',
        'birthday': '2000-01-02',
        'serviceRegion': 'TW',
        'eligibilityStatus': 'ADULT',
        'communityEligibilityStatus': 'ELIGIBLE',
        'memberState': 'ACTIVE',
        'version': 4,
        'pendingEmailChange': {
          'requestId': 'email-change-request',
          'status': 'PENDING_VERIFICATION',
          'target': 'new.member@example.test',
        },
        'pendingBirthdayCorrection': {
          'requestId': 'birthday-correction-request',
          'status': 'PENDING_REVIEW',
          'target': '2008-01-02',
        },
      });
    });

    final profile = await repository.getProfile();

    expect(captured?.uri.path, '/api/v1/members/me');
    expect(profile.version, 4);
    expect(profile.pendingEmailChange?.target, 'new.member@example.test');
    expect(profile.pendingBirthdayCorrection?.target, '2008-01-02');
  });

  test(
    'nickname update sends explicit community confirmation and version',
    () async {
      RequestOptions? captured;
      final repository = _repository((request) {
        captured = request;
        return _success(_profileJson(publicNickname: '新暱稱', version: 5));
      });

      final profile = await repository.updatePublicNickname(
        publicNickname: '新暱稱',
        expectedVersion: 4,
      );

      expect(captured?.uri.path, '/api/v1/members/me/public-nickname');
      expect(captured?.data, {
        'publicNickname': '新暱稱',
        'confirmExistingCommunityUpdate': true,
        'expectedVersion': 4,
      });
      expect(profile.publicNickname, '新暱稱');
      expect(profile.version, 5);
    },
  );

  test(
    'sensitive changes use purpose-bound reauthentication credential',
    () async {
      final requests = <RequestOptions>[];
      final repository = _repository((request) {
        requests.add(request);
        return switch (request.uri.path) {
          '/api/v1/auth/reauthentications/password' => _success({
            'credential': 'email-proof',
            'purpose': 'EMAIL_CHANGE',
            'expiresIn': 300,
          }),
          '/api/v1/members/me/email-change-requests' => _success(
            null,
            code: 'EMAIL_CHANGE_REQUEST_ACCEPTED',
          ),
          _ => throw StateError('Unexpected path ${request.uri.path}'),
        };
      }, sessionStore: const WebCookieSessionCredentialStore());

      final proof = await repository.reauthenticateWithPassword(
        password: 'synthetic-password',
        purpose: 'EMAIL_CHANGE',
      );
      await repository.requestEmailChange(
        newEmail: 'new.member@example.test',
        expectedVersion: 4,
        reauthenticationCredential: proof.credential,
      );

      expect(requests[0].data, {
        'password': 'synthetic-password',
        'purpose': 'EMAIL_CHANGE',
      });
      expect(
        requests[1].headers['X-Reauthentication-Credential'],
        'email-proof',
      );
      expect(requests[1].headers['X-Session-Transport'], 'COOKIE');
      expect(requests[1].headers['X-CSRF-Protection'], '1');
      expect(requests[1].extra['withCredentials'], isTrue);
      expect(requests[1].data, {
        'newEmail': 'new.member@example.test',
        'expectedVersion': 4,
      });
    },
  );

  test(
    'restoration is continuation-bound and never sends an expected version',
    () async {
      RequestOptions? captured;
      final repository = _repository((request) {
        captured = request;
        return _success({
          'memberState': 'ACTIVE',
          'version': 8,
          'nextAction': 'LOGIN_REQUIRED',
        });
      });

      final result = await repository.restore(
        continuationCredential: 'single-purpose-continuation',
      );

      expect(captured?.uri.path, '/api/v1/auth/member-restorations');
      expect(
        captured?.headers['Authorization'],
        'Continuation single-purpose-continuation',
      );
      expect(captured?.data, {'confirmed': true});
      expect(
        (captured?.data as Map<String, dynamic>).containsKey('expectedVersion'),
        isFalse,
      );
      expect(result.memberState, 'ACTIVE');
      expect(result.nextAction, 'LOGIN_REQUIRED');
    },
  );
}

MemberDataRepository _repository(
  ResponseBody Function(RequestOptions request) callback, {
  SessionCredentialStore sessionStore = const WebCookieSessionCredentialStore(),
}) {
  final dio = Dio()..httpClientAdapter = _CallbackAdapter(callback);
  return MemberDataRepository(
    ApiClient(config: _config, dio: dio),
    sessionStore: sessionStore,
  );
}

Map<String, Object?> _profileJson({
  String publicNickname = '貘友',
  int version = 4,
}) {
  return {
    'publicId': '00000000-0000-0000-0000-000000000001',
    'email': 'member@example.test',
    'publicNickname': publicNickname,
    'birthday': '2000-01-02',
    'serviceRegion': 'TW',
    'eligibilityStatus': 'ADULT',
    'communityEligibilityStatus': 'ELIGIBLE',
    'memberState': 'ACTIVE',
    'version': version,
    'pendingEmailChange': null,
    'pendingBirthdayCorrection': null,
  };
}

const _config = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.callback);

  final ResponseBody Function(RequestOptions request) callback;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => callback(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _success(Object? data, {String code = 'OK'}) {
  return ResponseBody.fromString(
    jsonEncode({'success': true, 'code': code, 'message': 'ok', 'data': data}),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
