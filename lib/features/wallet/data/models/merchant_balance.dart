import 'package:equatable/equatable.dart';

// How many points the user has with one merchant, plus their tier.
// Immutable value object (Equatable for value equality, copyWith for tweaks).
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
