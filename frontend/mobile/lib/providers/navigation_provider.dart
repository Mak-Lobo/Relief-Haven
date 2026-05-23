import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/navigation_model.dart';
import '../services/requests/navigation_request.dart';
import 'location_provider.dart';

final navigationRequestProvider = Provider<NavigationRequest>((ref) {
  return NavigationRequest();
});

final nearestSheltersProvider =
    FutureProvider.autoDispose<List<NearestShelterRouteModel>>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final request = ref.watch(navigationRequestProvider);

  return request.fetchNearestShelters(
    latitude: position.latitude,
    longitude: position.longitude,
  );
});

final routeToShelterProvider =
    FutureProvider.autoDispose.family<NavigationRouteModel, String>(
  (ref, shelterId) async {
    final position = await ref.watch(currentPositionProvider.future);
    final request = ref.watch(navigationRequestProvider);

    return request.fetchRouteToShelter(
      shelterId: shelterId,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  },
);
