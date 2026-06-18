import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/navigation_model.dart';
import '../services/requests/navigation_request.dart';
import '../services/location/shelter_cache.dart';
import 'location_provider.dart';
import 'connectivity_provider.dart';
import 'auth_provider.dart';

final navigationRequestProvider = Provider<NavigationRequest>((ref) {
  return NavigationRequest();
});

final shelterCacheProvider = Provider<ShelterCache>((ref) => ShelterCache());

/// Fetches the initial list of shelters from API or Cache.
/// Only runs once or when connectivity changes.
final baseSheltersProvider = FutureProvider.autoDispose<List<NearestShelterRouteModel>>((ref) async {
  final isOffline = ref.watch(isOfflineProvider);
  final cache = ref.watch(shelterCacheProvider);
  final request = ref.read(navigationRequestProvider);

  if (isOffline) {
    return cache.getShelters();
  }

  try {
    final initialPosition = await ref.read(currentPositionProvider.future);
    final shelters = await request.fetchNearestShelters(
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
    );
    await cache.saveShelters(shelters);
    return shelters;
  } catch (e) {
    final cached = await cache.getShelters();
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
});

/// Reactively updates and re-sorts the shelter list based on live position.
final nearestSheltersProvider = StreamProvider.autoDispose<List<NearestShelterRouteModel>>((ref) async* {
  final positionAsync = ref.watch(positionStreamProvider);
  final baseSheltersAsync = ref.watch(baseSheltersProvider);

  if (positionAsync.hasValue && baseSheltersAsync.hasValue) {
    final pos = positionAsync.value!;
    final baseShelters = baseSheltersAsync.value!;

    final updated = baseShelters.map((s) {
      final shelterLatLng = s.toLatLng();
      if (shelterLatLng == null) return s;

      final meters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        shelterLatLng.latitude,
        shelterLatLng.longitude,
      );

      return s.copyWith(
        distanceMeters: meters,
        distanceKm: meters / 1000,
      );
    }).toList();

    updated.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    yield updated;
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

final navigationLogsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final user = ref.watch(authProvider).authUser;
  if (user == null) {
    yield [];
    return;
  }
  
  final request = ref.read(navigationRequestProvider);
  
  while (true) {
    try {
      final response = await request.dio.get('/navigate/logs/user/${user.id}');
      final logs = (response.data as List).map((log) => log as Map<String, dynamic>).toList();
      yield logs;
    } catch (e) {
      // Keep streaming even on error
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});
