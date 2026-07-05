import 'package:api_client/api_client.dart';

import '../../../../core/error/wallet_exception.dart';
import '../models/models.dart';
import 'wallet_repository.dart';

/// Real API implementation of [WalletRepository] backed by [ApiClient].
///
/// This is the drop-in replacement for `MockWalletRepository` once the backend
/// is live: change one line in `main.dart` and the rest of the app is unchanged.
/// It is included to demonstrate the seam; it is not wired into the running app.
class HttpWalletRepository implements WalletRepository {
  const HttpWalletRepository(this._client);

  final ApiClient _client;

  @override
  Future<PointsBalance> getBalance() async {
    final response = await _mapErrors(() => _client.get('/wallet/balance'));
    return PointsBalance.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  }) async {
    final response = await _mapErrors(
      () => _client.get('/wallet/transactions', query: {
        'page': '$page',
        'limit': '$limit',
        if (type != null) 'type': type.wireValue,
      }),
    );
    return PaginatedTransactions.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TransferResult> transferPoints(TransferRequest request) async {
    final response = await _mapErrors(
      () => _client.post('/wallet/transfer', body: request.toJson()),
    );
    return TransferResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Translates transport-level [ApiException]s into domain [WalletException]s
  /// so the BLoC layer only ever deals with one error type.
  Future<ApiResponse> _mapErrors(Future<ApiResponse> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw WalletException(e.code ?? 'NETWORK', e.message);
    }
  }
}
