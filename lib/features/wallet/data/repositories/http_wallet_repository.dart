import 'package:api_client/api_client.dart';

import '../../../../core/error/wallet_exception.dart';
import '../models/models.dart';
import 'wallet_repository.dart';

// The real API version, on top of ApiClient. Drop-in replacement for the mock:
// swap one line in main.dart and nothing else changes. Here to show the seam;
// not actually wired up yet.
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

  // Turn transport-level ApiExceptions into our WalletException so the BLoC
  // only deals with one error type.
  Future<ApiResponse> _mapErrors(Future<ApiResponse> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw WalletException(e.code ?? 'NETWORK', e.message);
    }
  }
}
