# Plugoo Mobile

> Collaborative economy platform — mobile client built with Flutter.

[![CI](https://github.com/plugoo/plugoo-mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/plugoo/plugoo-mobile/actions/workflows/ci.yml)

---

## Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.22+ (Dart 3.3+) |
| Architecture | Clean Architecture (Data / Domain / Presentation) |
| State Management | Riverpod 2 (code-gen flavour) |
| Navigation | GoRouter |
| HTTP | Dio + Retrofit |
| Local Storage | SharedPreferences + FlutterSecureStorage |
| DI | Riverpod Providers |
| i18n | Flutter ARB (ES / EN) |
| Linting | flutter_lints + custom_lint + riverpod_lint |
| CI/CD | GitHub Actions |

---

## Prerequisites

- Flutter SDK `>=3.22.0` ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK `>=3.3.0` (bundled with Flutter)
- Xcode 15+ (for iOS builds)
- Android Studio / Android SDK (for Android builds)

Verify your setup:

```bash
flutter doctor
```

---

## Local Setup

### 1. Clone

```bash
git clone https://github.com/plugoo/plugoo-mobile.git
cd plugoo-mobile
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment

```bash
cp .env.example .env
# Edit .env and fill in your API keys and URLs
```

> **Never commit `.env` files.** Use `.env.example` as the template only.

### 4. Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# All connected devices
flutter run
```

---

## Project Structure

```
lib/
├── core/
│   ├── di/           # Riverpod infrastructure providers (Dio, SharedPreferences, etc.)
│   ├── error/        # Failures (domain) + Exceptions (data layer)
│   ├── network/      # GoRouter configuration
│   ├── theme/        # AppColors, AppTypography, AppTheme (design system)
│   └── utils/        # Shared typedefs, extensions, helpers
├── features/
│   └── {feature}/
│       ├── data/
│       │   ├── datasources/    # Remote & local data sources
│       │   ├── models/         # Data models (Freezed + JSON serializable)
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Pure domain entities
│       │   ├── repositories/   # Repository interfaces (abstractions)
│       │   └── usecases/       # Single-responsibility use cases
│       └── presentation/
│           ├── pages/          # Full-screen widgets
│           ├── providers/      # Riverpod providers for this feature
│           └── widgets/        # Feature-specific composable widgets
├── l10n/             # ARB translation files (app_en.arb, app_es.arb)
├── shared/
│   ├── widgets/      # Reusable UI components (design system primitives)
│   └── extensions/   # Dart extension methods
└── main.dart         # App entrypoint
```

---

## Architecture

Plugoo follows **Clean Architecture** with a strict dependency rule:

```
Presentation → Domain ← Data
```

- **Domain layer** has zero Flutter/framework dependencies. It contains entities, repository interfaces, and use cases.
- **Data layer** implements domain interfaces. It talks to APIs and local storage.
- **Presentation layer** uses Riverpod providers to interact with use cases. It knows nothing about how data is fetched.

All use cases return `Either<Failure, T>` (via `dartz`) — never throw exceptions to the UI.

---

## Design System

The design system lives in `lib/core/theme/`:

| File | Purpose |
|---|---|
| `app_colors.dart` | Single source of truth for all colors |
| `app_typography.dart` | Poppins type scale (Material 3) |
| `app_theme.dart` | Light and dark ThemeData, button/input styles |

**Rule:** Never use `Color(0xFF...)` literals in widgets. Always reference `AppColors`.

---

## i18n

Translations live in `lib/l10n/` as ARB files:

- `app_en.arb` — English (template)
- `app_es.arb` — Spanish

To add a new string:
1. Add the key + value to `app_en.arb`
2. Add the translated value to `app_es.arb`
3. Run `flutter gen-l10n` (or `flutter pub get` which triggers it via `l10n.yaml`)
4. Use it: `AppLocalizations.of(context).yourKey`

---

## Dependency Injection

Providers are defined in `lib/core/di/providers.dart`. Feature-level providers live in `lib/features/{feature}/presentation/providers/`.

Override providers in tests:

```dart
final container = ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(mockDio),
  ],
);
```

---

## CI/CD

Every PR triggers:

1. `flutter analyze` — static analysis with fatal infos
2. `dart format` — formatting check
3. `flutter test --coverage` — unit + widget tests
4. Coverage upload to Codecov

Merges to `main` also build a debug APK and iOS (no-codesign) to catch compile-time regressions early.

---

## Google Maps API Key Setup

The `GOOGLE_MAPS_API_KEY` is **never** stored in source code. It is injected at build time.

### Local development

1. Create (or open) `android/local.properties` — this file is gitignored:

```properties
flutter.sdk=/path/to/flutter
GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
```

2. The key is read in `android/app/build.gradle` and inserted into `AndroidManifest.xml`
   via the `${GOOGLE_MAPS_API_KEY}` manifest placeholder.

### CI (GitHub Actions / Codemagic)

Set `GOOGLE_MAPS_API_KEY` as a **repository secret** or **environment secret**.
The Gradle build reads `System.getenv('GOOGLE_MAPS_API_KEY')` when `local.properties` is absent.

### How to obtain a key

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**.
3. Create an API key and restrict it to your app's SHA-1 fingerprint.
4. Add the key to `local.properties` (local) or CI secrets (CI).

> **Never commit the key.** The `.gitignore` excludes `android/local.properties`.

---

## Android — Edge-to-Edge & Back Gesture

- **Edge-to-edge**: `main.dart` calls `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`.
  Flutter draws behind the status bar and gesture navigation bar. Use `MediaQuery.of(context).padding`
  or `SafeArea` in your widgets to avoid overlap.
- **Predictive Back Gesture (Android 13+)**: `android:enableOnBackInvokedCallback="true"` is set in
  `AndroidManifest.xml`. GoRouter handles the back stack natively — no additional config needed.
- **Minimum SDK**: 24 (Android 7.0). Target SDK: 34 (Android 14).

---

## Contributing

1. Branch from `develop`: `git checkout -b feat/your-feature develop`
2. Follow conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`
3. Write tests for domain and use case layers
4. Open a PR targeting `develop`
5. At least 1 reviewer approval required before merge to `main`

---

## License

Proprietary — © Plugoo. All rights reserved.
