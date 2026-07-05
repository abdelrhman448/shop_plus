import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('ApiClient', () {
    test('GET decodes a JSON body on success', () async {
      final client = ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/wallet/balance');
          return http.Response(jsonEncode({'totalPoints': 15750}), 200,
              headers: {'content-type': 'application/json'});
        }),
      );

      final response = await client.get('/wallet/balance');

      expect(response.statusCode, 200);
      expect((response.data as Map)['totalPoints'], 15750);
    });

    test('forwards query parameters', () async {
      late Uri capturedUri;
      final client = ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response('[]', 200);
        }),
      );

      await client.get('/wallet/transactions', query: {'page': '2'});

      expect(capturedUri.queryParameters['page'], '2');
    });

    test('AuthInterceptor injects a bearer token', () async {
      String? authHeader;
      final client = ApiClient(
        baseUrl: 'https://api.test',
        interceptors: [AuthInterceptor(() => 'abc123')],
        httpClient: MockClient((request) async {
          authHeader = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
      );

      await client.get('/me');

      expect(authHeader, 'Bearer abc123');
    });

    test('throws a typed ApiException on a 4xx with server code/message',
        () async {
      final client = ApiClient(
        baseUrl: 'https://api.test',
        retryPolicy: RetryPolicy.none,
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({'code': 'INSUFFICIENT_BALANCE', 'message': 'nope'}),
            400,
          );
        }),
      );

      expect(
        () => client.post('/wallet/transfer', body: {'points': 999999}),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.code, 'code', 'INSUFFICIENT_BALANCE')
              .having((e) => e.message, 'message', 'nope'),
        ),
      );
    });

    test('retries retryable failures then succeeds', () async {
      var calls = 0;
      final client = ApiClient(
        baseUrl: 'https://api.test',
        // Zero-delay backoff keeps the test fast.
        retryPolicy: const RetryPolicy(maxRetries: 3, baseDelay: Duration.zero),
        httpClient: MockClient((request) async {
          calls++;
          if (calls < 3) return http.Response('', 503);
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      final response = await client.get('/health');

      expect(calls, 3);
      expect(response.isSuccess, isTrue);
    });

    test('does not retry non-retryable errors', () async {
      var calls = 0;
      final client = ApiClient(
        baseUrl: 'https://api.test',
        retryPolicy: const RetryPolicy(maxRetries: 3, baseDelay: Duration.zero),
        httpClient: MockClient((request) async {
          calls++;
          return http.Response('{}', 404);
        }),
      );

      await expectLater(
        client.get('/missing'),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 1);
    });
  });
}
