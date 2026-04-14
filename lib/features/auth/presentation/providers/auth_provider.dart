import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

// ── Auth state ────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async => const AuthInitial();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthLoading());
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AsyncData(AuthError(failure.message)),
      (user) => state = AsyncData(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncData(AuthLoading());
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();
    result.fold(
      (failure) => state = AsyncData(AuthError(failure.message)),
      (user) => state = AsyncData(AuthAuthenticated(user)),
    );
  }

  void clearError() {
    state = const AsyncData(AuthInitial());
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
