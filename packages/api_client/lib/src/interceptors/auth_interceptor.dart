import 'dart:async';

import '../api_request.dart';
import '../interceptor.dart';

// Adds an "Authorization: Bearer <token>" header when there's a token.
// tokenProvider is called per request, so refreshed tokens just work. Return
// null to leave the request unauthenticated.
class AuthInterceptor extends ApiInterceptor {
  const AuthInterceptor(this.tokenProvider, {this.scheme = 'Bearer'});

  final FutureOr<String?> Function() tokenProvider;
  final String scheme;

  @override
  FutureOr<ApiRequest> onRequest(ApiRequest request) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) return request;
    return request.withHeaders({'Authorization': '$scheme $token'});
  }
}
