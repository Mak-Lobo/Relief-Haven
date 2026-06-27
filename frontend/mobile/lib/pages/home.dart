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

      // Download shelters and save to cache
      final savedShelters = await ref.read(baseSheltersProvider.future);
      final cache = ref.read(shelterCacheProvider);
      await cache.saveShelters(savedShelters);
      ref.invalidate(isShelterCacheEmptyProvider);

      const store = FMTCStore('mapCache');
      await store.manage.create();

      final region = CircleRegion(userLatLng, 5).toDownloadable(
        minZoom: 10,
        maxZoom: 16,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
      );

      toastification.show(
        title: const Text('Offline Download Started'),
        description: const Text(
          'Downloading maps and caching nearby shelters...',
        ),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 4),
      );

      store.download.startForeground(region: region);
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
          'Download Offline Data?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        content: Text(
          'This will download map tiles for a 5km radius around your current location and cache nearby shelters so you can access them offline.',
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
    final isCacheEmpty = ref.watch(isShelterCacheEmptyProvider).value ?? true;
    final _mapKey = GlobalKey<UserMapController>();

    // recenter user
    Future<void> _centerOnUser() async {
      await _mapKey.currentState?.centerOnUser();
    }

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
            if (isCacheEmpty && isOffline)
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
                      Icons.warning_amber_rounded,
                      color: colors.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are offline and have no cached shelters. Please connect to download.',
                        style: TextStyle(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isOffline)
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
            Stack(
              children: [
                GestureDetector(
                  onDoubleTap: _centerOnUser,
                  child: SizedBox(height: 350, child: UserMap(key: _mapKey)),
                ),
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
        final isOffline = ref.watch(isOfflineProvider);

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
                isOffline ? 'Available shelters (Offline)' : 'Nearest shelters',
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
                    return _ShelterMessageCard(
                      title: isOffline
                          ? 'No cached shelters'
                          : 'No nearby shelters found',
                      message: isOffline
                          ? 'You are offline and have no cached shelters. Please connect to the internet to download data.'
                          : 'We could not find any active shelters near your current location.',
                      icon: Icons.location_off_rounded,
                    );
                  }

                  return Column(
                    children: [
                      for (var i = 0; i < shelters.length; i++) ...[
                        ShelterCard(
                          rank: i + 1,
                          shelter: shelters[i],
                          isOffline: isOffline,
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

class ShelterCard extends StatelessWidget {
  const ShelterCard({
    required this.rank,
    required this.shelter,
    required this.onRoutePressed,
    this.isOffline = false,
  });

  final int rank;
  final NearestShelterRouteModel shelter;
  final VoidCallback onRoutePressed;
  final bool isOffline;

  static Color getOfflineColor(int index) {
    final colors = [Colors.green, Colors.cyan, Colors.red, Colors.teal];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isOffline
            ? ShelterCard.getOfflineColor(rank - 1).withValues(alpha: 0.1)
            : colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: isOffline
            ? Border.all(
                color: ShelterCard.getOfflineColor(rank - 1),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          if (isOffline)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: ShelterCard.getOfflineColor(rank - 1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOffline) _DistanceChip(label: shelter.distanceLabel),
                if (!isOffline) const SizedBox(height: 8),
                Text(
                  shelter.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: isOffline
                        ? ShelterCard.getOfflineColor(rank - 1)
                        : colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onRoutePressed,
            icon: const Icon(Icons.alt_route_rounded),
            style: IconButton.styleFrom(
              backgroundColor: isOffline
                  ? ShelterCard.getOfflineColor(rank - 1)
                  : colors.primary,
              foregroundColor: isOffline ? Colors.white : colors.onPrimary,
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
