import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../services/location/user_locate.dart';
import '../providers/location_provider.dart';
import 'shimmer_loading.dart';

class UserMap extends ConsumerStatefulWidget {
  const UserMap({super.key});

  @override
  ConsumerState<UserMap> createState() => _UserMapState();
}

class _UserMapState extends ConsumerState<UserMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);
  final markers = ValueNotifier<List<AnimatedMarker>>([]);

  @override
  void dispose() {
    markers.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionStreamProvider);
    final colors = Theme.of(context).colorScheme;

    return positionAsync.when(
      loading: () => const MapShimmer(),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                e is LocationException
                    ? e.message
                    : 'Unable to determine your location.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(currentPositionProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (position) {
        final userLatLng = LatLng(position.latitude, position.longitude);

        return FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: userLatLng,
            initialZoom: 15,
            keepAlive: true,
            backgroundColor: colors.surfaceContainerLow,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.relief_haven',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 32,
                  height: 32,
                  point: userLatLng,
                  alignment: Alignment.topCenter,
                  rotate: true,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
