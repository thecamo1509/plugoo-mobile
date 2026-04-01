import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Infrastructure providers
/// ─────────────────────────────────────────────────────────────────────────────

/// SharedPreferences — initialized in main.dart before runApp.
/// Override in tests with ProviderContainer(overrides: [...]).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences before runApp.');
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

/// ─────────────────────────────────────────────────────────────────────────────
/// HTTP Client
/// ─────────────────────────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // TODO: Replace with Env.apiUrl once envied is configured
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'https://api.plugoo.app'),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    LogInterceptor(requestBody: true, responseBody: true),
    // TODO: Add AuthInterceptor (token injection + refresh)
  ]);

  return dio;
});
