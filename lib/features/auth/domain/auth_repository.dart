import 'app_user.dart';

/// Erro de autenticação com mensagem pronta para exibir ao usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
