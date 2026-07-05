import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_plus/core/error/wallet_exception.dart';
import 'package:shop_plus/features/wallet/data/models/models.dart';
import 'package:shop_plus/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shop_plus/features/wallet/presentation/transfer/transfer_cubit.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

class FakeTransferRequest extends Fake implements TransferRequest {}

void main() {
  late WalletRepository repository;

  setUpAll(() => registerFallbackValue(FakeTransferRequest()));

  setUp(() => repository = MockWalletRepository());

  const request = TransferRequest(recipient: 'friend@test.com', points: 500);
  const result = TransferResult(
    transactionId: 'txn_1',
    points: 500,
    newBalance: 15250,
    status: 'COMPLETED',
  );

  blocTest<TransferCubit, TransferState>(
    'emits [Submitting, Success] on a successful transfer',
    setUp: () => when(() => repository.transferPoints(any()))
        .thenAnswer((_) async => result),
    build: () => TransferCubit(repository),
    act: (cubit) => cubit.submit(request),
    expect: () => const [
      TransferSubmitting(),
      TransferSuccess(result),
    ],
  );

  blocTest<TransferCubit, TransferState>(
    'emits [Submitting, Failure] with the typed code on WalletException',
    setUp: () => when(() => repository.transferPoints(any())).thenThrow(
      const WalletException('INSUFFICIENT_BALANCE', 'not enough'),
    ),
    build: () => TransferCubit(repository),
    act: (cubit) => cubit.submit(request),
    expect: () => const [
      TransferSubmitting(),
      TransferFailure(
        code: WalletErrorCode.insufficientBalance,
        message: 'not enough',
      ),
    ],
  );

  blocTest<TransferCubit, TransferState>(
    'maps an unexpected error to WalletErrorCode.unknown',
    setUp: () =>
        when(() => repository.transferPoints(any())).thenThrow(Exception('x')),
    build: () => TransferCubit(repository),
    act: (cubit) => cubit.submit(request),
    expect: () => [
      const TransferSubmitting(),
      isA<TransferFailure>()
          .having((s) => s.code, 'code', WalletErrorCode.unknown),
    ],
  );
}
