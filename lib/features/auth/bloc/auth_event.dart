abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String senha;

  LoginRequested(this.email, this.senha);
}

class LogoutRequested extends AuthEvent {}
