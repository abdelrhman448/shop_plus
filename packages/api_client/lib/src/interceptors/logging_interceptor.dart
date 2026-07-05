import 'dart:async';

import '../api_request.dart';
import '../api_response.dart';
import '../interceptor.dart';

/// Logs outgoing requests and incoming responses via the injected [log] sink.
///
/// The sink defaults to `print`, but tests (or production logging setups) can
/// pass their own function to capture output.
class LoggingInterceptor extends ApiInterceptor {
  const LoggingInterceptor({this.log = print});

  final void Function(String message) log;

  @override
  FutureOr<ApiRequest> onRequest(ApiRequest request) {
    log('--> ${request.method.name.toUpperCase()} ${request.path}');
    return request;
  }

  @override
  FutureOr<void> onResponse(ApiRequest request, ApiResponse response) {
    log('<-- ${response.statusCode} ${request.path}');
  }
}
