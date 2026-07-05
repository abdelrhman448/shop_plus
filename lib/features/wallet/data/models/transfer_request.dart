import 'package:equatable/equatable.dart';

/// The payload sent when a user transfers points to someone else.
///
/// [recipient] is a validated phone number or email. [note] is optional.
class TransferRequest extends Equatable {
  const TransferRequest({
    required this.recipient,
    required this.points,
    this.note,
  });

  final String recipient;
  final int points;
  final String? note;

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      recipient: json['recipient'] as String,
      points: json['points'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'points': points,
      if (note != null) 'note': note,
    };
  }

  TransferRequest copyWith({
    String? recipient,
    int? points,
    String? note,
  }) {
    return TransferRequest(
      recipient: recipient ?? this.recipient,
      points: points ?? this.points,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [recipient, points, note];
}
