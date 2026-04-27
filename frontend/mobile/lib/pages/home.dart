import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:relief_haven_mobile/utils/elevated_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "Welcome Mark",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_rounded),
          ),
        ],
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: _SearchBar(),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _MapPlaceholder(),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _ShelterSection(),
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
                      Text(
                        'Send location to responders',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.onError,
                              fontWeight: FontWeight.w700,
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 100,
      width: double.infinity,
      color: colors.primary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            const Spacer(),
            Text(
              'Welcome,Mark',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.notifications_none_rounded,
              color: colors.onPrimary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 24, color: colors.primary),
          const SizedBox(width: 12),
          Text(
            'Search for shelters',
            style: textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 72, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Map Placeholder',
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shelter map will be added here.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShelterSection extends StatelessWidget {
  const _ShelterSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const shelters = [
      ('0.5km', 'Thika Stadium'),
      ('0.5km', 'Thika Stadium'),
      ('0.5km', 'Thika Stadium'),
      ('0.5km', 'Thika Stadium'),
    ];

    return Container(
      width: double.infinity,
      padding: const .only(left: 18, right: 18, top: 20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Nearest shelters',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'View all',
                style: textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < shelters.length; i++) ...[
            _ShelterCard(distance: shelters[i].$1, name: shelters[i].$2),
            if (i != shelters.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 24, thickness: 1),
              ),
          ],
        ],
      ),
    );
  }
}

class _ShelterCard extends StatelessWidget {
  final String distance;
  final String name;

  const _ShelterCard({required this.distance, required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const .symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distance,
                  style: textTheme.labelMedium!.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            padding: .all(5),
            decoration: BoxDecoration(
              color: colors.inversePrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.home_outlined, size: 20, color: colors.primary),
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
  return MaterialApp(
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
  );
}
