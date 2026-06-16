import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/navigation_model.dart';
import '../providers/navigation_provider.dart';
import '../providers/connectivity_provider.dart';

class RouteDetailsSheet extends ConsumerWidget {
  const RouteDetailsSheet({
    super.key,
    required this.shelter,
    this.isNavigating = false,
    this.onStartNavigation,
    this.onCancelNavigation,
  });

  final NearestShelterRouteModel shelter;
  final bool isNavigating;
  final VoidCallback? onStartNavigation;
  final VoidCallback? onCancelNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeToShelterProvider(shelter.shelterId));
    final isOffline = ref.watch(isOfflineProvider);
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
                isOffline 
                  ? 'Showing location from cache. Distances are hidden while offline.' 
                  : error.toString(),
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
            _RouteSummaryCard(
              route: route,
              liveShelter: shelter,
              isOffline: isOffline,
              isNavigating: isNavigating,
              onStartNavigation: onStartNavigation,
              onCancelNavigation: onCancelNavigation,
            ),
          ],
        );
      },
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.route,
    required this.liveShelter,
    required this.isOffline,
    required this.isNavigating,
    this.onStartNavigation,
    this.onCancelNavigation,
  });

  final NavigationRouteModel route;
  final NearestShelterRouteModel liveShelter;
  final bool isOffline;
  final bool isNavigating;
  final VoidCallback? onStartNavigation;
  final VoidCallback? onCancelNavigation;

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
        color: isNavigating
            ? colors.surfaceContainerHighest
            : colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOffline)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniInfoChip(
                  icon: Icons.alt_route_rounded,
                  label: liveShelter.distanceLabel, // Consistency fix
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
            isNavigating
                ? 'Keep following the route. You are almost there!'
                : 'Navigation route is ready to guide you to the shelter.',
            style: textTheme.bodyLarge?.copyWith(
              color: isNavigating
                  ? colors.onSurface
                  : colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isOffline) const SizedBox(height: 8),
          if (!isOffline)
            Text(
              'Estimated distance: ${liveShelter.distanceMeters.toStringAsFixed(0)} meters',
              style: textTheme.bodyMedium?.copyWith(
                color:
                    (isNavigating ? colors.onSurface : colors.onPrimaryContainer)
                        .withValues(alpha: 0.78),
              ),
            ),
          Divider(
            color: isNavigating ? colors.outline : colors.onPrimary,
            thickness: 1.75,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isNavigating
                  ? (onCancelNavigation ?? () => Navigator.of(context).pop())
                  : (onStartNavigation ?? () {}),
              style: FilledButton.styleFrom(
                backgroundColor: isNavigating ? colors.error : colors.primary,
                foregroundColor: isNavigating
                    ? colors.onError
                    : colors.onPrimary,
              ),
              icon: Icon(
                isNavigating ? Icons.close_rounded : Icons.navigation_rounded,
              ),
              label: Text(
                isNavigating ? 'Cancel navigation' : 'Start navigation',
              ),
            ),
          ),
        ],
      ),
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
