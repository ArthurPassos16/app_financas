import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth auth;

  FirebaseAuthDataSource(this.auth);

  Future<UserCredential> login(String email, String senha) {
    return auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> logout() {
    return auth.signOut();
  }
}
