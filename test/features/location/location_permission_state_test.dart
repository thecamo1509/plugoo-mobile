import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plugoo/features/location/data/location_repository_impl.dart';
import 'package:plugoo/features/location/domain/location_permission_state.dart';
import 'package:plugoo/features/location/presentation/providers/location_provider.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockLocationRepository extends Mock implements LocationRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer(LocationRepository repo) {
  return ProviderContainer(
    overrides: [locationRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  late MockLocationRepository mockRepo;

  setUp(() {
    mockRepo = MockLocationRepository();
  });

  group('LocationPermissionNotifier — state machine', () {
    test('initial state reads from repository', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.initial);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final status = await container.read(locationPermissionProvider.future);
      expect(status, LocationPermissionStatus.initial);
    });

    test('requestPermission → granted', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.initial);
      when(() => mockRepo.requestPermission())
          .thenAnswer((_) async => LocationPermissionStatus.granted);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(locationPermissionProvider.future);
      await container
          .read(locationPermissionProvider.notifier)
          .requestPermission();

      final status = container.read(locationPermissionProvider).valueOrNull;
      expect(status, LocationPermissionStatus.granted);
    });

    test('requestPermission → denied', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.initial);
      when(() => mockRepo.requestPermission())
          .thenAnswer((_) async => LocationPermissionStatus.denied);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(locationPermissionProvider.future);
      await container
          .read(locationPermissionProvider.notifier)
          .requestPermission();

      final status = container.read(locationPermissionProvider).valueOrNull;
      expect(status, LocationPermissionStatus.denied);
    });

    test('requestPermission → permanentlyDenied', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.initial);
      when(() => mockRepo.requestPermission())
          .thenAnswer((_) async => LocationPermissionStatus.permanentlyDenied);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(locationPermissionProvider.future);
      await container
          .read(locationPermissionProvider.notifier)
          .requestPermission();

      final status = container.read(locationPermissionProvider).valueOrNull;
      expect(status, LocationPermissionStatus.permanentlyDenied);
    });

    test('openSettings re-checks permission afterwards', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.permanentlyDenied);
      when(() => mockRepo.openSettings()).thenAnswer((_) async {});
      // Simulate user granting from settings.
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.granted);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(locationPermissionProvider.future);
      await container.read(locationPermissionProvider.notifier).openSettings();

      final status = container.read(locationPermissionProvider).valueOrNull;
      expect(status, LocationPermissionStatus.granted);
    });

    test('showRationale sets showingRationale state', () async {
      when(() => mockRepo.checkPermission())
          .thenAnswer((_) async => LocationPermissionStatus.initial);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(locationPermissionProvider.future);
      container.read(locationPermissionProvider.notifier).showRationale();

      final status = container.read(locationPermissionProvider).valueOrNull;
      expect(status, LocationPermissionStatus.showingRationale);
    });
  });
}
