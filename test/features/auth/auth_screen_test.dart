import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:plugoo/core/theme/app_theme.dart';
import 'package:plugoo/features/auth/domain/entities/auth_user.dart';
import 'package:plugoo/features/auth/domain/repositories/auth_repository.dart';
import 'package:plugoo/features/auth/presentation/auth_screen.dart';
import 'package:plugoo/features/auth/presentation/providers/auth_provider.dart';
import 'package:plugoo/core/utils/typedefs.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildHarness(AuthRepository repo) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const AuthScreen(),
    ),
  );
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('AuthScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_buildHarness(mockRepo));
      await tester.pump();

      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_field')), findsOneWidget);
    });

    testWidgets('Google Sign-In button is present', (tester) async {
      await tester.pumpWidget(_buildHarness(mockRepo));
      await tester.pump();

      expect(find.byKey(const Key('auth_google_button')), findsOneWidget);
    });

    testWidgets('shows validation error when email is empty', (tester) async {
      await tester.pumpWidget(_buildHarness(mockRepo));
      await tester.pump();

      // Tap submit without filling in anything.
      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá tu email.'), findsOneWidget);
    });

    testWidgets('shows validation error when email is invalid', (tester) async {
      await tester.pumpWidget(_buildHarness(mockRepo));
      await tester.pump();

      await tester.enterText(
          find.byKey(const Key('auth_email_field')), 'not-an-email');
      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email inválido.'), findsOneWidget);
    });

    testWidgets('shows validation error when password is too short',
        (tester) async {
      await tester.pumpWidget(_buildHarness(mockRepo));
      await tester.pump();

      await tester.enterText(
          find.byKey(const Key('auth_email_field')), 'user@plugoo.app');
      await tester.enterText(
          find.byKey(const Key('auth_password_field')), '12');
      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres.'), findsOneWidget);
    });
  });
}
