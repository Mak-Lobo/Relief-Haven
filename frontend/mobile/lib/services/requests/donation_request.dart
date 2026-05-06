import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/donation_model.dart';
import 'base.dart';

final _logger = Logger();

class DonationInitiateRequest {
  final double amountKes;
  final String paymentService;
  final int? phone;

  const DonationInitiateRequest({
    required this.amountKes,
    required this.paymentService,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount_kes': amountKes,
      'payment_service': paymentService,
      if (phone != null) 'phone': phone,
    };
  }
}

class DonationRequest extends Base {
  static const String _initiatePath = '/donations/initiate';
  static const String _userHistoryPath = '/donations/user';
  final _supabase = Supabase.instance.client;

  Future<void> initiateDonation({
    required DonationInitiateRequest request,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw const RequestException('Please sign in before making a donation.');
    }

    if (request.amountKes <= 0) {
      throw const RequestException(
        'Donation amount must be greater than zero.',
      );
    }

    if (request.paymentService.trim().isEmpty) {
      throw const RequestException('Please choose a payment method.');
    }

    try {
      await dio.post(
        _initiatePath,
        data: {'user_id': currentUser.id, ...request.toJson()},
      );
      _logger.i(
        'STK Push sent for user ${currentUser.id} via ${request.paymentService}',
      );
    } on DioException catch (error) {
      final mappedError = mapDioException(
        error,
        fallbackMessage: 'Unable to start the donation right now.',
      );
      _logger.e('Donation initiation error', error: mappedError);
      throw mappedError;
    }
  }

  Future<List<DonationModel>> fetchUserDonations({
    required String userId,
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const RequestException('A user id is required to load donations.');
    }

    try {
      final response = await dio.get('$_userHistoryPath/$trimmedUserId');
      final donations = _extractDonationList(response.data);
      donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return donations;
    } on DioException catch (error) {
      final mappedError = mapDioException(
        error,
        fallbackMessage: 'Unable to load your donation history right now.',
      );
      _logger.e('Donation history fetch error', error: mappedError);
      throw mappedError;
    }
  }

  Map<String, dynamic>? _extractDonationPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final directDonation = data['donation'];
      if (directDonation is Map<String, dynamic>) {
        return directDonation;
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }

      if (data.containsKey('donation_id') || data.containsKey('id')) {
        return data;
      }
    }

    return null;
  }

  List<DonationModel> _extractDonationList(dynamic data) {
    if (data == null || data is String && data.trim().isEmpty) {
      return [];
    }

    if (data is List) {
      return _toDonationModels(data);
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['donations', 'results', 'data']) {
        final candidate = data[key];
        if (candidate is List) {
          return _toDonationModels(candidate);
        }
      }

      final singleDonation = _extractDonationPayload(data);
      if (singleDonation != null) {
        return [DonationModel.fromJson(singleDonation)];
      }
    }

    return [];
  }

  List<DonationModel> _toDonationModels(List items) {
    return items
        .whereType<Map>()
        .map((item) => DonationModel.fromJson(item.cast<String, dynamic>()))
        .toList();
  }
}
