import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../common_widgets/route_details_sheet.dart';
import '../models/navigation_model.dart';
import '../providers/location_provider.dart';
import '../providers/navigation_provider.dart';

class RouteViewScreen extends ConsumerWidget {
  const RouteViewScreen({super.key, required this.shelter});

  final NearestShelterRouteModel shelter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final positionAsync = ref.watch(currentPositionProvider);
    final routeAsync = ref.watch(routeToShelterProvider(shelter.shelterId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Navigate to...'),
      ),
      body: positionAsync.when(
        loading: () => _RouteLoadingState(colors: colors),
        error: (error, _) =>
            _RouteErrorState(colors: colors, message: error.toString()),
        data: (position) {
          return routeAsync.when(
            loading: () => _RouteLoadingState(colors: colors),
            error: (error, _) =>
                _RouteErrorState(colors: colors, message: error.toString()),
            data: (route) {
              final userPoint = LatLng(position.latitude, position.longitude);
              final shelterPoint = shelter.toLatLng();
              final routePoints = route.geometry.isNotEmpty
                  ? route.geometry
                  : <LatLng>[userPoint, if (shelterPoint != null) shelterPoint];
              final center = shelterPoint == null
                  ? userPoint
                  : LatLng(
                      (userPoint.latitude + shelterPoint.latitude) / 2,
                      (userPoint.longitude + shelterPoint.longitude) / 2,
                    );

              return Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14,
                        keepAlive: true,
                        backgroundColor: colors.surfaceContainerLow,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.relief_haven',
                        ),
                        if (routePoints.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                strokeWidth: 4.5,
                                color: colors.inversePrimary.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 42,
                              height: 42,
                              point: userPoint,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.person_pin_circle_rounded,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                            if (shelterPoint != null)
                              Marker(
                                width: 42,
                                height: 42,
                                point: shelterPoint,
                                alignment: Alignment.topCenter,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.redAccent,
                                  size: 42,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.475,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.16),
                              blurRadius: 24,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const .symmetric(
                            vertical: 20,
                            horizontal: 15,
                          ),
                          child: RouteDetailsSheet(shelter: shelter),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _RouteLoadingState extends StatelessWidget {
  const _RouteLoadingState({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surfaceContainerLow,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RouteErrorState extends StatelessWidget {
  const _RouteErrorState({required this.colors, required this.message});

  final ColorScheme colors;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colors.surfaceContainerLow,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded, size: 60, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load route map',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
