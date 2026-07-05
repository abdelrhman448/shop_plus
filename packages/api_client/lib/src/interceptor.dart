import 'dart:async';

import 'api_request.dart';
import 'api_response.dart';

/// Hook into the request/response lifecycle.
///
/// Interceptors run in order for [onRequest] (each may transform the request)
/// and in reverse order for [onResponse]. Override only what you need.
abstract class ApiInterceptor {
  const ApiInterceptor();

  /// Called before a request is sent. Return the (possibly modified) request.
  FutureOr<ApiRequest> onRequest(ApiRequest request) => request;

  /// Called after a successful response is decoded.
  FutureOr<void> onResponse(ApiRequest request, ApiResponse response) {}
}
