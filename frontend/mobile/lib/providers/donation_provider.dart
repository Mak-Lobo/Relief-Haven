import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/donation_model.dart';
import '../services/requests/donation_request.dart';
import 'auth_provider.dart';

final donationRequestProvider = Provider<DonationRequest>((ref) {
  return DonationRequest();
});

final donationHistoryProvider = FutureProvider.autoDispose<List<DonationModel>>(
  (ref) async {
    final authState = ref.watch(authProvider);
    final authUser = authState.authUser;
    if (authUser == null) {
      return [];
    }

    final request = ref.watch(donationRequestProvider);
    return request.fetchUserDonations(userId: authUser.id);
  },
);
