import 'package:app_financas/features/auth/data/auth_datasource.dart';
import 'package:app_financas/features/auth/domain/usuario.dart';

class AuthRepository {
  final FirebaseAuthDataSource datasource;

  AuthRepository(this.datasource);

  Future<Usuario> login(String email, String senha) async {
    final cred = await datasource.login(email, senha);
    return Usuario.fromFirebase(cred.user!);
  }

  Future<void> logout() {
  return datasource.logout();
}
}