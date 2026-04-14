import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/location_permission_state.dart';
import 'providers/location_provider.dart';

/// Entry point for location permission flow.
///
/// Flow:
///   1. Screen shown → check current permission state.
///   2. If already granted → navigate to Home automatically.
///   3. Otherwise → show rationale UI.
///   4. User taps "Permitir" → show OS dialog.
///   5. Handle granted / denied / permanentlyDenied with appropriate UI.
class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permState = ref.watch(locationPermissionProvider);

    ref.listen(locationPermissionProvider, (_, next) {
      next.whenData((status) {
        if (status == LocationPermissionStatus.granted) {
          context.go(AppRoutes.home);
        }
      });
    });

    return permState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (status) => _PermissionBody(status: status),
    );
  }
}

class _PermissionBody extends ConsumerWidget {
  final LocationPermissionStatus status;

  const _PermissionBody({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(locationPermissionProvider.notifier);

    return switch (status) {
      LocationPermissionStatus.granted => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      LocationPermissionStatus.permanentlyDenied ||
      LocationPermissionStatus.restricted =>
        _SettingsPromptView(
          isPermanentlyDenied:
              status == LocationPermissionStatus.permanentlyDenied,
          onOpenSettings: notifier.openSettings,
        ),
      LocationPermissionStatus.showingRationale ||
      LocationPermissionStatus.initial =>
        _RationaleView(onAllow: notifier.requestPermission),
      LocationPermissionStatus.requesting => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      LocationPermissionStatus.denied => _DeniedView(
          onRetry: notifier.requestPermission,
          onSkip: () => context.go(AppRoutes.home),
        ),
    };
  }
}

/// Pre-request rationale (Android best practice).
class _RationaleView extends StatelessWidget {
  final VoidCallback onAllow;

  const _RationaleView({required this.onAllow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Tu ubicación, tu carga',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Para mostrarte los cargadores más cercanos y animarte al mapa, Plugoo necesita acceso a tu ubicación.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  key: const Key('location_allow_button'),
                  onPressed: onAllow,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Permitir ubicación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when user denied but can retry.
class _DeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  const _DeniedView({required this.onRetry, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 80, color: AppColors.warning),
              const SizedBox(height: 24),
              Text(
                'Sin ubicación por ahora',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Podés usar la app pero no veremos tu posición en el mapa. ¿Querés intentarlo de nuevo?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onRetry,
                  child: const Text('Intentar de nuevo'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Continuar sin ubicación',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when permission is permanently denied — must open Settings.
class _SettingsPromptView extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback onOpenSettings;

  const _SettingsPromptView({
    required this.isPermanentlyDenied,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings, size: 80, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                isPermanentlyDenied
                    ? 'Permiso bloqueado'
                    : 'Acceso restringido',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanentlyDenied
                    ? 'Bloqueaste el acceso a la ubicación. Para activarlo, andá a Configuración → Plugoo → Permisos → Ubicación.'
                    : 'Tu dispositivo restringe el acceso a la ubicación. Verificá la configuración del dispositivo.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey700,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (isPermanentlyDenied)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('location_settings_button'),
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Ir a Configuración'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
