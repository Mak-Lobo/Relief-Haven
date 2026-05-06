import 'package:intl/intl.dart';

class DonationModel {
  final String donationId;
  final String userId;
  final double amountKes;
  final String transactionId;
  final String paymentService;
  final DateTime createdAt;

  const DonationModel({
    required this.donationId,
    required this.userId,
    required this.amountKes,
    required this.transactionId,
    required this.paymentService,
    required this.createdAt,
  });

  // ── Display helpers ──────────────────────────────────────────────────────

  /// Formatted KES amount: `KES 1,500.00`.
  String get formattedAmount {
    return NumberFormat.currency(
      symbol: 'KES ',
      decimalDigits: 2,
    ).format(amountKes);
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      donationId: json['donation_id'] as String,
      userId: json['user_id'] as String,
      amountKes: (json['amount_kes'] as num).toDouble(),
      transactionId: json['transaction_id'] as String,
      paymentService: json['payment_service'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  DonationModel copyWith({
    String? donationId,
    String? userId,
    double? amountKes,
    String? transactionId,
    String? paymentService,
    DateTime? createdAt,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      userId: userId ?? this.userId,
      amountKes: amountKes ?? this.amountKes,
      transactionId: transactionId ?? this.transactionId,
      paymentService: paymentService ?? this.paymentService,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationModel &&
          runtimeType == other.runtimeType &&
          donationId == other.donationId;

  @override
  int get hashCode => donationId.hashCode;
}
