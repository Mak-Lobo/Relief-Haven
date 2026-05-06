// lib/providers/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location/user_locate.dart';

final currentPositionProvider = FutureProvider<Position>((ref) async {
  return LocationHelper.getCurrentPosition();
});

// living streaming position continuously throughout
final positionStreamProvider = StreamProvider<Position>((ref) {
  return LocationHelper.positionStream();
});
