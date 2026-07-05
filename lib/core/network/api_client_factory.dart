import 'dart:async';

import 'package:api_client/api_client.dart';

/// Builds the app's [ApiClient] for the (future) real ShopPlus API.
///
/// Centralizing construction here means base URL, timeouts, auth and logging
/// are configured in exactly one place. Not wired into the running app yet —
/// the app uses [MockWalletRepository] until the backend is available.
abstract final class ApiClientFactory {
  const ApiClientFactory._();

  static const _baseUrl = 'https://api.shopplus.com';

  static ApiClient create({FutureOr<String?> Function()? tokenProvider}) {
    return ApiClient(
      baseUrl: _baseUrl,
      timeout: const Duration(seconds: 15),
      retryPolicy: const RetryPolicy(maxRetries: 2),
      interceptors: [
        if (tokenProvider != null) AuthInterceptor(tokenProvider),
        const LoggingInterceptor(),
      ],
    );
  }
}
