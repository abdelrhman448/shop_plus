import 'package:equatable/equatable.dart';

import 'merchant_balance.dart';

// The user's total balance plus the per-merchant breakdown.
// Immutable + JSON. Dates go out as ISO-8601 UTC to match the API.
class PointsBalance extends Equatable {
  const PointsBalance({
    required this.totalPoints,
    required this.pendingPoints,
    required this.expiringPoints,
    required this.expiringDate,
    required this.lastUpdated,
    required this.balancesByMerchant,
  });

  final int totalPoints;
  final int pendingPoints;
  final int expiringPoints;
  final DateTime expiringDate;
  final DateTime lastUpdated;
  final List<MerchantBalance> balancesByMerchant;

  factory PointsBalance.fromJson(Map<String, dynamic> json) {
    return PointsBalance(
      totalPoints: json['totalPoints'] as int,
      pendingPoints: json['pendingPoints'] as int,
      expiringPoints: json['expiringPoints'] as int,
      expiringDate: DateTime.parse(json['expiringDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      balancesByMerchant: (json['balancesByMerchant'] as List<dynamic>)
          .map((e) => MerchantBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'pendingPoints': pendingPoints,
      'expiringPoints': expiringPoints,
      'expiringDate': expiringDate.toUtc().toIso8601String(),
      'lastUpdated': lastUpdated.toUtc().toIso8601String(),
      'balancesByMerchant':
          balancesByMerchant.map((e) => e.toJson()).toList(),
    };
  }

  PointsBalance copyWith({
    int? totalPoints,
    int? pendingPoints,
    int? expiringPoints,
    DateTime? expiringDate,
    DateTime? lastUpdated,
    List<MerchantBalance>? balancesByMerchant,
  }) {
    return PointsBalance(
      totalPoints: totalPoints ?? this.totalPoints,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      expiringPoints: expiringPoints ?? this.expiringPoints,
      expiringDate: expiringDate ?? this.expiringDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      balancesByMerchant: balancesByMerchant ?? this.balancesByMerchant,
    );
  }

  @override
  List<Object?> get props => [
        totalPoints,
        pendingPoints,
        expiringPoints,
        expiringDate,
        lastUpdated,
        balancesByMerchant,
      ];
}
