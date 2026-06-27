import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:relief_haven_mobile/providers/navigation_provider.dart';
import 'package:relief_haven_mobile/providers/connectivity_provider.dart';

class NavigationLogsPage extends ConsumerWidget {
  const NavigationLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isOffline = ref.watch(isOfflineProvider);
    final logsAsync = ref.watch(navigationLogsProvider);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Navigation Logs',
          style: TextStyle(fontWeight: .w700),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: isOffline
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: colors.error),
                  const SizedBox(height: 16),
                  Text(
                    'You are offline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Connect to the internet to view your navigation logs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            )
          : logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(child: Text('No navigation history.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    final rawDate = DateTime.tryParse(
                      log['navigation_date']?.toString() ?? '',
                    );
                    final formattedDate = rawDate != null
                        ? dateFormat.format(
                            rawDate.add(const Duration(hours: 3)),
                          )
                        : 'N/A';

                    return Card(
                      color: colors.primaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(
                          log['shelter_name'] ?? 'Unknown Shelter',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Distance: ${log['distance']} km'),
                        trailing: Text(
                          formattedDate,
                          style: TextStyle(fontWeight: .w500),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
