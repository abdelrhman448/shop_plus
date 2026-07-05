import 'dart:async';

import 'api_request.dart';
import 'api_response.dart';

// Hook into requests/responses. onRequest runs in order (each can tweak the
// request); onResponse runs in reverse. Override just what you need.
abstract class ApiInterceptor {
  const ApiInterceptor();

  // Before sending: return the (maybe modified) request.
  FutureOr<ApiRequest> onRequest(ApiRequest request) => request;

  // After a successful response is decoded.
  FutureOr<void> onResponse(ApiRequest request, ApiResponse response) {}
}
