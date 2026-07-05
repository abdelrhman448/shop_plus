import 'package:equatable/equatable.dart';

/// Points a user holds with a single merchant, plus their loyalty tier.
///
/// Immutable value object: [Equatable] gives value equality and [copyWith]
/// allows creating modified copies without mutating the original.
class MerchantBalance extends Equatable {
  const MerchantBalance({
    required this.merchantId,
    required this.merchantName,
    required this.merchantLogo,
    required this.points,
    required this.tier,
  });

  final String merchantId;
  final String merchantName;
  final String merchantLogo;
  final int points;
  final String tier;

  factory MerchantBalance.fromJson(Map<String, dynamic> json) {
    return MerchantBalance(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      merchantLogo: json['merchantLogo'] as String,
      points: json['points'] as int,
      tier: json['tier'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantLogo': merchantLogo,
      'points': points,
      'tier': tier,
    };
  }

  MerchantBalance copyWith({
    String? merchantId,
    String? merchantName,
    String? merchantLogo,
    int? points,
    String? tier,
  }) {
    return MerchantBalance(
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantLogo: merchantLogo ?? this.merchantLogo,
      points: points ?? this.points,
      tier: tier ?? this.tier,
    );
  }

  @override
  List<Object?> get props => [
        merchantId,
        merchantName,
        merchantLogo,
        points,
        tier,
      ];
}
