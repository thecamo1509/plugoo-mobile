import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/typedefs.dart';
import '../domain/entities/auth_user.dart';
import '../domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// In this MVP the backend call is mocked for email/password; Google Sign-In
/// uses the real SDK flow. Replace the mock with a real Dio/Retrofit call once
/// the backend (PLU-10) is live.
class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  @override
  ResultFuture<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with real API call once PLU-10 backend is live.
      // For now, simulate a successful login for any non-empty credentials.
      if (email.isEmpty || password.isEmpty) {
        return Left(
          const ValidationFailure(message: 'Email y contraseña son requeridos.'),
        );
      }
      await Future.delayed(const Duration(milliseconds: 800));
      return Right(AuthUser(id: 'mock-${email.hashCode}', email: email));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<AuthUser> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the flow.
        return const Left(
          ServerFailure(message: 'Inicio de sesión cancelado.'),
        );
      }
      return Right(
        AuthUser(
          id: account.id,
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async => null; // MVP: no session persistence yet
}
