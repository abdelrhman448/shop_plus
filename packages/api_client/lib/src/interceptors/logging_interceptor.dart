import 'dart:async';

import '../api_request.dart';
import '../api_response.dart';
import '../interceptor.dart';

// Logs requests and responses. Defaults to print, but you can pass your own
// log function (handy in tests or a real logging setup).
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
