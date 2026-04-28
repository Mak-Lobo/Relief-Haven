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

  /// Formatted KES amount: 'KES 1,500.00'
  String get formattedAmount {
    // intl NumberFormat used at the widget layer via DateFormatter utils.
    // Raw getter provided here for simple use.
    return 'KES ${amountKes.toStringAsFixed(2)}';
  }

  // ── Serialisation ────────────────────────────────────────────────────────

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

  // Map<String, dynamic> toJson() {
  //   return {
  //     'donation_id': donationId,
  //     'user_id': userId,
  //     'amount_kes': amountKes,
  //     'transaction_id': transactionId,
  //     'payment_service': paymentService,
  //     'created_at': createdAt.toIso8601String(),
  //   };
  // }

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

  // @override
  // String toString() =>
  //     'DonationModel(donationId: $donationId, amountKes: $amountKes, '
  //     'transactionId: $transactionId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationModel &&
          runtimeType == other.runtimeType &&
          donationId == other.donationId;

  @override
  int get hashCode => donationId.hashCode;
}

// ── STK Push initiation request ──────────────────────────────────────────────
//
// Sent by Flutter to POST /donations/initiate.
// Backend uses this to trigger the M-Pesa STK Push via Daraja API.
// The phone_number is optional to support using a number different from the
// one registered to the account.
//
// Fields:
//   amount_kes    → donation amount in Kenyan Shillings (must be >= 1.0)
//   payment_service → selected payment option (e.g. 'mpesa', 'airtel')
//   phone_number  → optional number for STK Push (e.g. 254712345678)

class DonationInitiateRequest {
  final double amountKes;
  final String paymentService;
  final int? phoneNumber;

  const DonationInitiateRequest({
    required this.amountKes,
    required this.paymentService,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount_kes': amountKes,
      'payment_service': paymentService,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
