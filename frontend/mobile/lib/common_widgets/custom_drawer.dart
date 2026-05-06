import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = ref.watch(authProvider).displayName;
    final themeMode = ref.watch(themeProvider);
    final systemIsDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && systemIsDark);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(Icons.person, color: colors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              Text(
                'Settings',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // Theme toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: colors.primary,
                ),
                title: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  activeThumbColor: colors.primary,
                ),
              ),

              const Spacer(),
              const Divider(),

              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).signOut();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(colors.error),
                      foregroundColor: WidgetStatePropertyAll(colors.onError),
                    ),
                    child: Row(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        Icon(Icons.logout_rounded),
                        Text(
                          "Sign Out",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onError,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
