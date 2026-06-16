import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donation_model.dart';
import 'auth_provider.dart';
import '../services/requests/donation_request.dart';

final donationRequestProvider = Provider((ref) => DonationRequest());

final donationHistoryProvider = StreamProvider.autoDispose<List<DonationModel>>((ref) {
  final user = ref.watch(authProvider).authUser;
  if (user == null) return Stream.value([]);
  return ref.watch(donationRequestProvider).getDonationsStream(userId: user.id);
});
