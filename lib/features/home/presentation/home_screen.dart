import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../location/domain/location_permission_state.dart';
import '../../location/presentation/providers/location_provider.dart';

/// Initial camera position — Buenos Aires downtown.
const _kBuenosAires = CameraPosition(
  target: LatLng(-34.6037, -58.3816),
  zoom: 13.0,
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  bool _animatedToUser = false;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _tryAnimateToUser();
  }

  Future<void> _tryAnimateToUser() async {
    if (_animatedToUser) return;

    final permState = ref.read(locationPermissionProvider).valueOrNull;
    if (permState != LocationPermissionStatus.granted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
      _animatedToUser = true;
    } catch (_) {
      // Location unavailable — stay on Buenos Aires default.
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If permission becomes granted while on this screen, animate to user.
    ref.listen(locationPermissionProvider, (_, next) {
      next.whenData((status) {
        if (status == LocationPermissionStatus.granted) {
          _tryAnimateToUser();
        }
      });
    });

    final permState = ref.watch(locationPermissionProvider).valueOrNull;
    final hasLocation = permState == LocationPermissionStatus.granted;

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ─────────────────────────────────────────────────────
          GoogleMap(
            key: const Key('home_google_map'),
            initialCameraPosition: _kBuenosAires,
            onMapCreated: _onMapCreated,
            myLocationEnabled: hasLocation,
            myLocationButtonEnabled: false, // We provide a custom FAB.
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            compassEnabled: true,
            // Edge-to-edge: padding accounts for Android gesture navigation bar.
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
          ),

          // ── Location permission banner ─────────────────────────────────────
          if (!hasLocation) const _LocationPermissionBanner(),

          // ── App bar overlay ────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _MapSearchBar(),
          ),

          // ── FAB — my location ──────────────────────────────────────────────
          if (hasLocation)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 100,
              child: FloatingActionButton.small(
                heroTag: 'my_location_fab',
                onPressed: _tryAnimateToUser,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {}, // TODO: open search/filter sheet
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.grey500),
              const SizedBox(width: 12),
              Text(
                'Buscar cargadores…',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner shown when location permission is not granted.
class _LocationPermissionBanner extends ConsumerWidget {
  const _LocationPermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Material(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.location_off, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Activá la ubicación para ver cargadores cercanos.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey900,
                      ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(locationPermissionProvider.notifier).requestPermission(),
                child: const Text('Activar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
