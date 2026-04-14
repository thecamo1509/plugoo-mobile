import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/providers.dart';
import '../../data/onboarding_repository_impl.dart';
import '../../domain/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.read(sharedPreferencesProvider));
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(onboardingRepositoryProvider);
  return repo.isOnboardingCompleted();
});

/// Notifier that holds the current onboarding page index.
class OnboardingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void nextPage() => state = state + 1;
  void goToPage(int page) => state = page;
}

final onboardingPageProvider =
    NotifierProvider<OnboardingNotifier, int>(OnboardingNotifier.new);
