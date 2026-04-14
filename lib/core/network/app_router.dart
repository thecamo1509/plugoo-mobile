import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/location/presentation/location_permission_screen.dart';
import '../../features/onboarding/data/onboarding_repository_impl.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Named route paths — single source of truth.
/// ─────────────────────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String locationPermission = '/location-permission';
  static const String home = '/home';
}

/// ─────────────────────────────────────────────────────────────────────────────
/// GoRouter factory — inject [SharedPreferences] for the onboarding guard.
/// Call [createRouter] from [main.dart] after SharedPreferences is ready.
/// ─────────────────────────────────────────────────────────────────────────────
GoRouter createRouter(SharedPreferences prefs) {
  final onboardingRepo = OnboardingRepositoryImpl(prefs);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,

    // ── Onboarding redirect guard ─────────────────────────────────────────────
    // If the user has already completed onboarding and tries to go to /onboarding,
    // send them straight to /auth.
    redirect: (context, state) async {
      final isOnboardingDone = await onboardingRepo.isOnboardingCompleted();
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (isOnboardingDone && goingToOnboarding) {
        return AppRoutes.auth;
      }
      return null; // No redirect needed.
    },

    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        name: 'locationPermission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],

    // ── Predictive Back Gesture (Android 13+) ─────────────────────────────────
    // GoRouter respects the platform's back gesture natively.
    // Setting navigatorKey ensures proper state restoration on back.
    navigatorKey: _rootNavigatorKey,
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider so the app can access the router after initialization.
/// Initialized lazily once SharedPreferences is ready.
GoRouter? _routerInstance;

GoRouter get appRouter {
  assert(_routerInstance != null, 'Call initRouter() before accessing appRouter.');
  return _routerInstance!;
}

/// Call this from main() after SharedPreferences is initialized.
void initRouter(SharedPreferences prefs) {
  _routerInstance = createRouter(prefs);
}
