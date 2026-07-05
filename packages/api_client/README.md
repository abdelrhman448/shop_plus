# api_client

A small, dependency-light HTTP client built on `package:http` with:

- Configurable **base URL** and **timeout**
- **Interceptors** (auth token injection, logging, or your own)
- **Retry** with **exponential backoff** for transient failures (network, 5xx,
  408, 429)
- JSON encode/decode and a typed [`ApiException`] for error transformation
- An **injectable** `http.Client`, so it's trivial to unit-test

## Install

Path dependency (as used by the ShopPlus app):

```yaml
dependencies:
  api_client:
    path: packages/api_client
```

## Usage

```dart
import 'package:api_client/api_client.dart';

final client = ApiClient(
  baseUrl: 'https://api.shopplus.com',
  timeout: const Duration(seconds: 15),
  retryPolicy: const RetryPolicy(maxRetries: 2),
  interceptors: [
    AuthInterceptor(() async => await tokenStore.read()), // per-request token
    const LoggingInterceptor(),
  ],
);

// GET with query params
final res = await client.get('/wallet/transactions', query: {'page': '1'});
final data = res.data; // decoded JSON

// POST with a JSON body
try {
  final result = await client.post('/wallet/transfer', body: {
    'recipient': '+201012345678',
    'points': 500,
  });
  print(result.data);
} on ApiException catch (e) {
  // e.statusCode, e.code, e.message are all available for handling.
  print(e);
}
```

## Writing a custom interceptor

```dart
class RequestIdInterceptor extends ApiInterceptor {
  const RequestIdInterceptor();

  @override
  FutureOr<ApiRequest> onRequest(ApiRequest request) =>
      request.withHeaders({'X-Request-Id': newUuid()});
}
```

## Test

```bash
dart test
```

Tests use `package:http`'s `MockClient` to simulate responses and verify
success decoding, auth header injection, error transformation and retry/backoff.
