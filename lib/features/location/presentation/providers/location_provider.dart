import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/location_repository_impl.dart';
import '../../domain/location_permission_state.dart';

final locationRepositoryProvider = Provider<LocationRepository>(
  (_) => LocationRepositoryImpl(),
);

/// Notifier that drives the permission state machine.
class LocationPermissionNotifier
    extends AsyncNotifier<LocationPermissionStatus> {
  @override
  Future<LocationPermissionStatus> build() async {
    final repo = ref.read(locationRepositoryProvider);
    return repo.checkPermission();
  }

  /// Show the rationale screen before requesting.
  void showRationale() {
    state = const AsyncData(LocationPermissionStatus.showingRationale);
  }

  /// Request fine location permission from the OS.
  Future<void> requestPermission() async {
    state = const AsyncData(LocationPermissionStatus.requesting);
    final repo = ref.read(locationRepositoryProvider);
    final status = await repo.requestPermission();
    state = AsyncData(status);
  }

  /// Open system app-settings so the user can grant permanently-denied permission.
  Future<void> openSettings() async {
    final repo = ref.read(locationRepositoryProvider);
    await repo.openSettings();
    // Re-check after returning from settings.
    final status = await repo.checkPermission();
    state = AsyncData(status);
  }
}

final locationPermissionProvider =
    AsyncNotifierProvider<LocationPermissionNotifier, LocationPermissionStatus>(
  LocationPermissionNotifier.new,
);
