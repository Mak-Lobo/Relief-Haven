import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import '../providers/location_provider.dart';
import '../providers/navigation_provider.dart';

class UserMap extends ConsumerStatefulWidget {
  const UserMap({super.key});

  @override
  ConsumerState<UserMap> createState() => _UserMapState();
}

class _UserMapState extends ConsumerState<UserMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);

  // Default center: Nairobi, Kenya
  static const _defaultCenter = LatLng(-1.286389, 36.817223);
  bool _hasMovedToUser = false;

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng point) {
    _animatedMapController.animateTo(dest: point, zoom: 15);
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionStreamProvider);
    final sheltersAsync = ref.watch(nearestSheltersProvider);
    final colors = Theme.of(context).colorScheme;

    // Listen for position changes to animate the map
    ref.listen(positionStreamProvider, (previous, next) {
      next.whenData((position) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        if (!_hasMovedToUser) {
          _moveToLocation(userLatLng);
          setState(() => _hasMovedToUser = true);
        }
      });
    });

    final List<Marker> shelterMarkers = sheltersAsync.maybeWhen(
      data: (shelters) => shelters
          .map((s) {
            final latLng = s.toLatLng();
            if (latLng == null) return null;

            Color markerColor = Colors.green;
            if (!s.isActive || s.isFull) {
              markerColor = Colors.red;
            } else if (s.occupancy >= s.capacity * 0.9) {
              markerColor = Colors.orange;
            }

            return Marker(
              width: 40,
              height: 40,
              point: latLng,
              rotate: true,
              alignment: Alignment.topCenter,
              child: Icon(Icons.location_on, color: markerColor, size: 40),
            );
          })
          .whereType<Marker>()
          .toList(),
      orElse: () => [],
    );

    final Marker? userMarker = positionAsync.maybeWhen(
      data: (position) => Marker(
        width: 32,
        height: 32,
        point: LatLng(position.latitude, position.longitude),
        alignment: Alignment.topCenter,
        rotate: true,
        child: const Icon(
          Icons.location_pin,
          color: Colors.blueAccent,
          size: 32,
        ),
      ),
      orElse: () => null,
    );

    return FlutterMap(
      mapController: _animatedMapController.mapController,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 13,
        keepAlive: true,
        backgroundColor: colors.surfaceContainerLow,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.relief_haven',
          tileProvider: const FMTCStore('mapCache').getTileProvider(),
        ),
        MarkerLayer(markers: [?userMarker, ...shelterMarkers]),
      ],
    );
  }
}
