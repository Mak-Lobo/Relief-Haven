import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:toastification/toastification.dart';

import '../pages/navigation_logs_page.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../pages/faq.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer();

  Future<void> _clearMapCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          'Clear Map Cache?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        content: Text(
          'This will delete all downloaded map tiles. You will need internet to view these areas again.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await const FMTCStore('mapCache').manage.reset();
        toastification.show(
          title: const Text('Cache Cleared'),
          description: const Text('All map tiles have been deleted.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
        );
      } catch (e) {
        toastification.show(
          title: const Text('Error clearing cache'),
          description: Text(e.toString()),
          type: ToastificationType.error,
        );
      }
    }
  }

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
                'Help & Information',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // FAQ link
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.help_outline_rounded,
                  color: colors.primary,
                ),
                title: Text(
                  'FAQ & Help',
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.history_rounded, color: colors.primary),
                title: Text(
                  'Navigation logs',
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationLogsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
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

              // Clear Cache
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_sweep_outlined, color: colors.error),
                title: Text(
                  'Clear Map Cache',
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                ),
                onTap: () => _clearMapCache(context),
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
                        const Icon(Icons.logout_rounded),
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
