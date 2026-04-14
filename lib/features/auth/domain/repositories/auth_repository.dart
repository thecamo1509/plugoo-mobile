import '../../../../core/utils/typedefs.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  ResultFuture<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  ResultFuture<AuthUser> signInWithGoogle();

  ResultFuture<void> signOut();

  Future<AuthUser?> getCurrentUser();
}
