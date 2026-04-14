abstract interface class OnboardingRepository {
  /// Returns true if the user has already completed onboarding.
  Future<bool> isOnboardingCompleted();

  /// Persists the onboarding-completion flag.
  Future<void> completeOnboarding();
}
