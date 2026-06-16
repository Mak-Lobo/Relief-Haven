import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../common_widgets/route_details_sheet.dart';
import '../models/navigation_model.dart';
import '../providers/connectivity_provider.dart';
import '../providers/location_provider.dart';
import '../providers/navigation_provider.dart';

class RouteViewScreen extends ConsumerStatefulWidget {
  const RouteViewScreen({super.key, required this.shelter});

  final NearestShelterRouteModel shelter;

  @override
  ConsumerState<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends ConsumerState<RouteViewScreen> {
  bool _isNavigating = false;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showNavigationModal());
  }

  void _showNavigationModal() {
    if (_isModalOpen) return;
    _isModalOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true, // Allow dismiss to see full map
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final positionAsync = ref.watch(positionStreamProvider);
            final routeAsync = ref.watch(
              routeToShelterProvider(widget.shelter.shelterId),
            );

            return positionAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => Center(child: Text(err.toString())),
              data: (position) {
                return routeAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (err, _) => Center(child: Text(err.toString())),
                  data: (route) {
                    final shelterPoint = widget.shelter.toLatLng();
                    double liveDistanceKm = widget.shelter.distanceKm;
                    if (shelterPoint != null) {
                      final meters = Geolocator.distanceBetween(
                        position.latitude,
                        position.longitude,
                        shelterPoint.latitude,
                        shelterPoint.longitude,
                      );
                      liveDistanceKm = meters / 1000;
                    }

                    final liveShelter = widget.shelter.copyWith(
                      distanceKm: liveDistanceKm,
                      distanceMeters: liveDistanceKm * 1000,
                    );

                    return DraggableScrollableSheet(
                      initialChildSize: 0.42,
                      minChildSize: 0.4,
                      maxChildSize: 0.85,
                      snap: true,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    child: RouteDetailsSheet(
                                      shelter: liveShelter,
                                      isNavigating: _isNavigating,
                                      onStartNavigation: () {
                                        setState(() => _isNavigating = true);
                                      },
                                      onCancelNavigation: () {
                                        Navigator.of(context).pop(); // modal
                                        Navigator.of(context).pop(); // screen
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    ).then((_) => setState(() => _isModalOpen = false));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final positionAsync = ref.watch(positionStreamProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final routeAsync = ref.watch(
      routeToShelterProvider(widget.shelter.shelterId),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isNavigating
          ? null
          : AppBar(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              title: const Text('Navigate to Shelter'),
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
              final shelterPoint = widget.shelter.toLatLng();
              final routePoints = route.geometry.isNotEmpty
                  ? route.geometry
                  : <LatLng>[userPoint, if (shelterPoint != null) shelterPoint];

              return Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: userPoint,
                        initialZoom: _isNavigating ? 17.0 : 15.5,
                        keepAlive: true,
                        backgroundColor: colors.surfaceContainerLow,
                        onTap: (_, __) => _showNavigationModal(),
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
                                strokeWidth: 5.0,
                                color: colors.inversePrimary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: userPoint,
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: _isNavigating
                                    ? (position.heading * (3.14159 / 180))
                                    : 0,
                                child: Icon(
                                  Icons.navigation_rounded,
                                  color: colors.inversePrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (shelterPoint != null)
                              Marker(
                                width: isOffline ? 120 : 40,
                                height: isOffline ? 80 : 40,
                                point: shelterPoint,
                                alignment: Alignment.topCenter,
                                child: isOffline
                                    ? Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              widget.shelter.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.redAccent,
                                            size: 30,
                                          ),
                                        ],
                                      )
                                    : const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.redAccent,
                                        size: 24,
                                      ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isNavigating)
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Card(
                        color: colors.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_run,
                                color: colors.onPrimary,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'Heading to ${widget.shelter.name}',
                                  style: TextStyle(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
