import 'package:latlong2/latlong.dart';

class NearestShelterRouteModel {
  const NearestShelterRouteModel({
    required this.shelterId,
    required this.name,
    required this.subcounty,
    required this.county,
    required this.location,
    required this.capacity,
    required this.occupancy,
    required this.isActive,
    required this.distanceMeters,
    required this.distanceKm,
    this.durationSeconds,
  });

  final String shelterId;
  final String name;
  final String subcounty;
  final String county;
  final String location;
  final int capacity;
  final int occupancy;
  final bool isActive;
  final double distanceMeters;
  final double distanceKm;
  final double? durationSeconds;

  factory NearestShelterRouteModel.fromJson(Map<String, dynamic> json) {
    return NearestShelterRouteModel(
      shelterId: json['shelter_id'] as String,
      name: json['name'] as String,
      subcounty: json['subcounty'] as String,
      county: json['county'] as String,
      location: json['location'] as String,
      capacity: (json['capacity'] as num).toInt(),
      occupancy: (json['occupancy'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? false,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] == null
          ? null
          : (json['duration_seconds'] as num).toDouble(),
    );
  }

  int get availableSpaces => capacity - occupancy;
  bool get isFull => occupancy >= capacity;
  String get areaLabel => '$subcounty, $county';
  String get occupancyLabel => '$occupancy/$capacity occupied';
  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  String get routeDurationLabel {
    final seconds = durationSeconds;
    if (seconds == null || seconds <= 0) {
      return 'Route time unavailable';
    }

    final duration = Duration(seconds: seconds.round());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m away' : '${hours}h away';
    }

    return '${minutes == 0 ? 1 : minutes}m away';
  }

  String get availabilityLabel {
    if (!isActive) {
      return 'Temporarily inactive';
    }
    if (isFull) {
      return 'At capacity';
    }
    return '$availableSpaces spaces open';
  }

  LatLng? toLatLng() {
    final match = RegExp(
      r'^POINT\s*\(\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s*\)$',
      caseSensitive: false,
    ).firstMatch(location.trim());

    if (match == null) {
      return null;
    }

    final longitude = double.parse(match.group(1)!);
    final latitude = double.parse(match.group(2)!);
    return LatLng(latitude, longitude);
  }
}

class NavigationRouteModel {
  const NavigationRouteModel({
    required this.shelterId,
    required this.name,
    required this.location,
    required this.distanceMeters,
    required this.distanceKm,
    required this.geometry,
    this.durationSeconds,
  });

  final String shelterId;
  final String name;
  final String location;
  final double distanceMeters;
  final double distanceKm;
  final double? durationSeconds;
  final List<LatLng> geometry;

  factory NavigationRouteModel.fromJson(Map<String, dynamic> json) {
    final geometry = <LatLng>[];
    final rawGeometry = json['geometry'];

    if (rawGeometry is List) {
      for (final point in rawGeometry) {
        if (point is List && point.length >= 2) {
          final longitude = (point[0] as num).toDouble();
          final latitude = (point[1] as num).toDouble();
          geometry.add(LatLng(latitude, longitude));
        }
      }
    }

    return NavigationRouteModel(
      shelterId: json['shelter_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] == null
          ? null
          : (json['duration_seconds'] as num).toDouble(),
      geometry: geometry,
    );
  }
}
