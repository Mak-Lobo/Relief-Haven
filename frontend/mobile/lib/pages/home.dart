import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:relief_haven_mobile/providers/navigation_provider.dart';
import 'package:relief_haven_mobile/providers/location_provider.dart';
import 'package:relief_haven_mobile/providers/connectivity_provider.dart';
import 'package:relief_haven_mobile/models/navigation_model.dart';
import 'package:relief_haven_mobile/utils/elevated_button.dart';

import '../common_widgets/custom_drawer.dart';
import '../common_widgets/map.dart';
import 'route_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _downloadMap(BuildContext context, WidgetRef ref) async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      final userLatLng = LatLng(position.latitude, position.longitude);

      const store = FMTCStore('mapCache');
      await store.manage.create();

      final region = CircleRegion(userLatLng, 5).toDownloadable(
        minZoom: 10,
        maxZoom: 16,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
      );

      store.download.startForeground(region: region);

      toastification.show(
        title: const Text('Map Download Started'),
        description: const Text('Downloading maps for your current area...'),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 4),
      );
    } catch (e) {
      toastification.show(
        title: const Text('Download Failed'),
        description: Text(e.toString()),
        type: ToastificationType.error,
      );
    }
  }

  void _showDownloadPrompt(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          'Download Offline Map?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        content: Text(
          'This will download map tiles for a 5km radius around your current location so you can access them without internet.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadMap(context, ref);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final displayName = ref.watch(authProvider).displayName;
    final firstName = displayName.trim().split(RegExp(r'\s+')).first;
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "Welcome $firstName",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showDownloadPrompt(context, ref),
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Download Offline Map',
          ),
        ],
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: colors.errorContainer,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: colors.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are offline. Showing cached map and shelters.',
                        style: TextStyle(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Stack(
              children: [
                const SizedBox(height: 350, child: UserMap()),
                const Padding(
                  padding: EdgeInsets.only(top: 300, left: 20, right: 20),
                  child: _ShelterSection(),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: SizedBox(
                width: 270,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                    elevation: 8,
                    shadowColor: colors.shadow.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: colors.onError,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Send location to responders',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.onError,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ShelterSection extends StatelessWidget {
  const _ShelterSection();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final colors = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final sheltersAsync = ref.watch(nearestSheltersProvider);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 18, right: 18, top: 20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearest shelters',
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              sheltersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _ShelterMessageCard(
                  title: 'Unable to load shelters',
                  message: error.toString(),
                  icon: Icons.cloud_off_rounded,
                ),
                data: (shelters) {
                  if (shelters.isEmpty) {
                    return const _ShelterMessageCard(
                      title: 'No nearby shelters found',
                      message:
                          'We could not find any active shelters near your current location.',
                      icon: Icons.location_off_rounded,
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < shelters.length; i++) ...[
                        _ShelterCard(
                          rank: i + 1,
                          shelter: shelters[i],
                          onRoutePressed: () {
                            _showRouteDetails(context, shelters[i]);
                          },
                        ),
                        if (i != shelters.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Divider(height: 24, thickness: 1),
                          ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}

class _ShelterCard extends StatelessWidget {
  const _ShelterCard({
    required this.rank,
    required this.shelter,
    required this.onRoutePressed,
  });

  final int rank;
  final NearestShelterRouteModel shelter;
  final VoidCallback onRoutePressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // final badgeColor = !shelter.isActive
    //     ? colors.outline
    //     : shelter.isFull
    //     ? colors.error
    //     : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DistanceChip(label: shelter.distanceLabel),
              const SizedBox(height: 8),
              SizedBox(
                width: 150,
                child: Text(
                  shelter.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: onRoutePressed,
            icon: const Icon(Icons.alt_route_rounded),
            label: const Text('View route'),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(colors.onPrimary),
              backgroundColor: WidgetStatePropertyAll(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Chip(
      label: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: colors.secondaryContainer,
      side: BorderSide(color: colors.secondaryContainer),
      shape: const StadiumBorder(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Chip(
      avatar: Icon(icon, size: 16, color: foreground),
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: background,
      side: BorderSide(color: background),
      shape: const StadiumBorder(),
      labelPadding: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ShelterMessageCard extends StatelessWidget {
  const _ShelterMessageCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showRouteDetails(
  BuildContext context,
  NearestShelterRouteModel shelter,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => RouteViewScreen(shelter: shelter)),
  );
}

class _RouteDetailsSheet extends ConsumerWidget {
  const _RouteDetailsSheet({required this.shelter});

  final NearestShelterRouteModel shelter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeToShelterProvider(shelter.shelterId));
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return routeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route_outlined, size: 60, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Route unavailable',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (route) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shelter.name,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              shelter.areaLabel,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _RouteSummaryCard(route: route),
            const SizedBox(height: 16),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(18),
            //   decoration: BoxDecoration(
            //     color: colors.surfaceContainerHighest,
            //     borderRadius: BorderRadius.circular(24),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Route path',
            //         style: textTheme.titleMedium?.copyWith(
            //           fontWeight: FontWeight.w700,
            //         ),
            //       ),
            //       const SizedBox(height: 10),
            //       Text(
            //         route.geometry.isEmpty
            //             ? 'The backend did not return detailed geometry for this route.'
            //             : 'Detailed geometry received with ${route.geometry.length} route points.',
            //         style: textTheme.bodyMedium?.copyWith(
            //           color: colors.onSurfaceVariant,
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.route});

  final NavigationRouteModel route;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final duration = route.durationSeconds;
    final durationLabel = duration == null || duration <= 0
        ? 'Travel time unavailable'
        : duration < 3600
        ? '${(duration / 60).round()} min'
        : '${(duration / 3600).floor()}h ${(duration / 60).round() % 60}m';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniInfoChip(
                icon: Icons.alt_route_rounded,
                label: '${route.distanceKm.toStringAsFixed(1)} km',
                background: colors.secondaryContainer,
                foreground: colors.onSecondaryContainer,
              ),
              _MiniInfoChip(
                icon: Icons.schedule_rounded,
                label: durationLabel,
                background: colors.tertiaryContainer,
                foreground: colors.onTertiaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Navigation route is ready to guide you to the shelter.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated distance: ${route.distanceMeters.toStringAsFixed(0)} meters',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer.withValues(alpha: 0.78),
            ),
          ),
          Divider(color: colors.onPrimary, thickness: 1.75),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Start navigation'),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Home Screen')
Widget homeScreenPreview() {
  return _buildPreviewApp(const HomeScreen());
}

Widget _buildPreviewApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0277BD),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(),
        elevatedButtonTheme: customElevatedBtnTheme,
      ),
      home: child,
    ),
  );
}
