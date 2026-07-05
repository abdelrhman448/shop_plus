import 'dart:async';

import 'package:api_client/api_client.dart';

// Builds the ApiClient for the real ShopPlus API (base URL, timeout, auth,
// logging in one spot). Not used yet — we're on MockWalletRepository until the
// backend is ready.
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
