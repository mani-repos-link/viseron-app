import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:viseron_app/services/viseron_api.dart';
import 'package:viseron_app/core/exceptions.dart';

void main() {
  group('ViseronApi', () {
    late ViseronApi api;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/enabled')) {
          return http.Response('', 200, headers: {'set-cookie': '_xsrf=test_token; Path=/'});
        }
        if (request.url.path.endsWith('/auth/login')) {
          if (request.headers['X-XSRFToken'] == 'test_token') {
             return http.Response(
               jsonEncode({'header': 'h', 'payload': 'p'}), 
               200,
               headers: {'set-cookie': 'signature_cookie=s; Path=/'}
             );
          }
          return http.Response('Forbidden', 403);
        }
        if (request.url.path.endsWith('/cameras')) {
          if (request.headers['Authorization'] == 'Bearer h.p') {
            return http.Response(jsonEncode({'cam1': {'name': 'Test Cam'}}), 200);
          }
          return http.Response('Unauthorized', 401);
        }
        return http.Response('Not Found', 404);
      });

      api = ViseronApi(client: mockClient);
      api.setConnectionDetails('http://localhost:8888', null, 'user', 'pass');
    });

    test('Login flow extracts XSRF and JWT', () async {
      await api.login();
      // No exception means success
    });

    test('getCameras uses stored token', () async {
      await api.login();
      final cameras = await api.getCameras();
      expect(cameras.length, 1);
      expect(cameras[0].identifier, 'cam1');
    });

    test('Login throws AuthException on failure', () async {
      final badClient = MockClient((req) async => http.Response('Unauthorized', 401));
      final badApi = ViseronApi(client: badClient);
      badApi.setConnectionDetails('http://localhost', null, 'u', 'p');
      
      expect(() => badApi.login(), throwsA(isA<AuthException>()));
    });
  });
}
