import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const _kOnboardingDone = 'onboarding_completed';

  final SharedPreferences _prefs;

  const OnboardingRepositoryImpl(this._prefs);

  @override
  Future<bool> isOnboardingCompleted() async =>
      _prefs.getBool(_kOnboardingDone) ?? false;

  @override
  Future<void> completeOnboarding() async =>
      _prefs.setBool(_kOnboardingDone, true);
}
