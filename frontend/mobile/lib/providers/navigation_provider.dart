import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/navigation_model.dart';
import '../services/requests/navigation_request.dart';
import '../services/location/shelter_cache.dart';
import 'location_provider.dart';
import 'connectivity_provider.dart';

final navigationRequestProvider = Provider<NavigationRequest>((ref) {
  return NavigationRequest();
});

final shelterCacheProvider = Provider<ShelterCache>((ref) => ShelterCache());

final nearestSheltersProvider =
    FutureProvider.autoDispose<List<NearestShelterRouteModel>>((ref) async {
  final isOffline = ref.watch(isOfflineProvider);
  final cache = ref.watch(shelterCacheProvider);

  if (isOffline) {
    return cache.getShelters();
  }

  try {
    final position = await ref.watch(currentPositionProvider.future);
    final request = ref.watch(navigationRequestProvider);

    final shelters = await request.fetchNearestShelters(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // Save to cache for offline use
    await cache.saveShelters(shelters);
    return shelters;
  } catch (e) {
    // If request fails but we have cached data, fallback to it
    final cached = await cache.getShelters();
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
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
