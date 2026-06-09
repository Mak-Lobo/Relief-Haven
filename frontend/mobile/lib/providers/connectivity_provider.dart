import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) async* {
  final connectivity = Connectivity();
  
  // Get initial status
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult.first;

  // Listen to changes
  await for (final results in connectivity.onConnectivityChanged) {
    if (results.isNotEmpty) {
      yield results.first;
    }
  }
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (result) => result == ConnectivityResult.none,
    loading: () => false,
    error: (_, __) => false,
  );
});
