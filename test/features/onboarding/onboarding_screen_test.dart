import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plugoo/core/di/providers.dart';
import 'package:plugoo/core/theme/app_theme.dart';
import 'package:plugoo/features/onboarding/presentation/onboarding_screen.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildHarness(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const OnboardingScreen(),
    ),
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('OnboardingScreen', () {
    testWidgets('renders 2 pages via PageView', (tester) async {
      await tester.pumpWidget(_buildHarness(prefs));
      await tester.pumpAndSettle();

      // Page 1 is visible by default.
      expect(find.text('Cargá tu auto\ndonde quieras'), findsOneWidget);

      // Swipe to page 2.
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Economía\ncolaborativa'), findsOneWidget);
    });

    testWidgets('skip button is present', (tester) async {
      await tester.pumpWidget(_buildHarness(prefs));
      await tester.pump();

      expect(find.byKey(const Key('onboarding_skip')), findsOneWidget);
    });

    testWidgets('Siguiente button advances to page 2', (tester) async {
      await tester.pumpWidget(_buildHarness(prefs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_next')), findsOneWidget);
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();

      // Page 2 content shown.
      expect(find.text('Economía\ncolaborativa'), findsOneWidget);
      // CTA now shows "Empezar".
      expect(find.byKey(const Key('onboarding_start')), findsOneWidget);
    });

    testWidgets('Empezar button on last page persists completion flag',
        (tester) async {
      await tester.pumpWidget(_buildHarness(prefs));
      await tester.pumpAndSettle();

      // Go to page 2.
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();

      // Tap Empezar (this will navigate away — pump once to trigger the write).
      await tester.tap(find.byKey(const Key('onboarding_start')));
      await tester.pump(); // Let async complete.

      expect(prefs.getBool('onboarding_completed'), isTrue);
    });
  });
}
