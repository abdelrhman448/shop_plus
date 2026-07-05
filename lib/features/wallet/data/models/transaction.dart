import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

// One line in the history (earn, redeem, transfer, purchase).
// points is signed: + for credits, - for debits, like the sample data.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.merchantName,
    required this.merchantLogo,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final TransactionType type;
  final int points;
  final String description;
  final String? merchantName;
  final String? merchantLogo;
  final DateTime createdAt;
  final TransactionStatus status;

  // True when this adds points rather than spending them.
  bool get isCredit => points >= 0;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.fromWire(json['type'] as String),
      points: json['points'] as int,
      description: json['description'] as String,
      merchantName: json['merchantName'] as String?,
      merchantLogo: json['merchantLogo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: TransactionStatus.fromWire(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.wireValue,
      'points': points,
      'description': description,
      'merchantName': merchantName,
      'merchantLogo': merchantLogo,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'status': status.wireValue,
    };
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? points,
    String? description,
    String? merchantName,
    String? merchantLogo,
    DateTime? createdAt,
    TransactionStatus? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      description: description ?? this.description,
      merchantName: merchantName ?? this.merchantName,
      merchantLogo: merchantLogo ?? this.merchantLogo,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        points,
        description,
        merchantName,
        merchantLogo,
        createdAt,
        status,
      ];
}
