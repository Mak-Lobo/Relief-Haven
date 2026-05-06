// lib/core/utils/location_helper.dart
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

final _log = Logger();

class LocationHelper {
  // ── Permission & position ──────────────────────────────────────────────

  /// Checks permissions, requests if needed, then returns current position.
  /// Throws a [LocationException] with a user-facing message on any failure.
  static Future<Position> getCurrentPosition() async {
    await _ensureServiceEnabled();
    await _ensurePermissionGranted();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      _log.d(
        '[Location] Got position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      _log.e('[Location] Failed to get position: $e');
      throw LocationException(
        'Could not determine your location. Please try again.',
      );
    }
  }

  // position updates
  static Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10, // emit only when user moves >= 10 metres
      ),
    );
  }

  // ── Coordinate utilities ───────────────────────────────────────────────

  // converts to string format acceptable to PostGIS (WKT) in the PostgreSQL backend
  static String toWkt(Position position) {
    return 'POINT(${position.longitude} ${position.latitude})';
  }

  static double distanceInKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final metres = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return metres / 1000;
  }

  // ── Internal checks ────────────────────────────────────────────────────

  static Future<void> _ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException(
        'Location services are turned off. '
        'Please enable GPS to find shelters near you.',
      );
    }
  }

  static Future<void> _ensurePermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location access is permanently blocked. '
        'Please allow it in your device Settings → App permissions.',
      );
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Location permission is required to find shelters near you.',
        );
      }
    }
  }
}

// custom error message

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}
