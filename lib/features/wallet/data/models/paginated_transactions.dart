import 'package:equatable/equatable.dart';

import 'transaction.dart';

// One page of transactions + the info we need to fetch the next page.
class PaginatedTransactions extends Equatable {
  const PaginatedTransactions({
    required this.transactions,
    required this.page,
    required this.totalItems,
    required this.hasNext,
  });

  final List<Transaction> transactions;
  final int page;
  final int totalItems;
  final bool hasNext;

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) {
    return PaginatedTransactions(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      totalItems: json['totalItems'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'page': page,
      'totalItems': totalItems,
      'hasNext': hasNext,
    };
  }

  PaginatedTransactions copyWith({
    List<Transaction>? transactions,
    int? page,
    int? totalItems,
    bool? hasNext,
  }) {
    return PaginatedTransactions(
      transactions: transactions ?? this.transactions,
      page: page ?? this.page,
      totalItems: totalItems ?? this.totalItems,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  @override
  List<Object?> get props => [transactions, page, totalItems, hasNext];
}
