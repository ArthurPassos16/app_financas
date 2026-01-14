import 'package:app_financas/features/auth/domain/usuario.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Usuario usuario;

  AuthAuthenticated(this.usuario);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String mensagem;

  AuthError(this.mensagem);
}