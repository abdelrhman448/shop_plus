import 'package:equatable/equatable.dart';

/// The successful outcome of a points transfer.
class TransferResult extends Equatable {
  const TransferResult({
    required this.transactionId,
    required this.points,
    required this.newBalance,
    required this.status,
  });

  final String transactionId;
  final int points;
  final int newBalance;
  final String status;

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transactionId: json['transactionId'] as String,
      points: json['points'] as int,
      newBalance: json['newBalance'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'points': points,
      'newBalance': newBalance,
      'status': status,
    };
  }

  TransferResult copyWith({
    String? transactionId,
    int? points,
    int? newBalance,
    String? status,
  }) {
    return TransferResult(
      transactionId: transactionId ?? this.transactionId,
      points: points ?? this.points,
      newBalance: newBalance ?? this.newBalance,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [transactionId, points, newBalance, status];
}
