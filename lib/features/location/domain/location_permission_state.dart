/// Represents every possible state of location permission.
///
/// State machine transitions:
///   initial → requesting → granted / denied / permanentlyDenied / restricted
///   denied  → requesting (user retries)
///   permanentlyDenied → (only "open settings" resolves it; no in-app retry)
enum LocationPermissionStatus {
  /// Initial — haven't asked yet.
  initial,

  /// Rationale screen is showing (Android best-practice pre-ask).
  showingRationale,

  /// Waiting for system dialog.
  requesting,

  /// User granted fine location access.
  granted,

  /// User denied but can be asked again.
  denied,

  /// User selected "Never ask again". Must direct to Settings.
  permanentlyDenied,

  /// Device restriction (parental controls etc.) — cannot prompt.
  restricted,
}
