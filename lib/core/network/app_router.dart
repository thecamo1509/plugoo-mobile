import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// App Router — GoRouter configuration
///
/// Route names are defined as constants to avoid magic strings.
/// Auth redirect logic lives here, driven by an auth state provider.
/// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const _PlaceholderPage(title: 'Splash'),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderPage(title: 'Login'),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const _PlaceholderPage(title: 'Register'),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const _PlaceholderPage(title: 'Home'),
    ),
  ],
);

/// Temporary placeholder — replace each route with the real page widget.
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}
