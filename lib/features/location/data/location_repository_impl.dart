import 'package:permission_handler/permission_handler.dart';

import '../domain/location_permission_state.dart';

/// Wraps [permission_handler] behind a domain interface so it can be mocked in tests.
abstract interface class LocationRepository {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<void> openSettings();
}

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return _map(status);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return _map(status);
  }

  @override
  Future<void> openSettings() => openAppSettings();

  LocationPermissionStatus _map(PermissionStatus status) => switch (status) {
        PermissionStatus.granted => LocationPermissionStatus.granted,
        PermissionStatus.denied => LocationPermissionStatus.denied,
        PermissionStatus.permanentlyDenied =>
          LocationPermissionStatus.permanentlyDenied,
        PermissionStatus.restricted => LocationPermissionStatus.restricted,
        _ => LocationPermissionStatus.denied,
      };
}
