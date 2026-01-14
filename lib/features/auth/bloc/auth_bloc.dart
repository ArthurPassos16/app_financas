import 'package:app_financas/features/auth/bloc/auth_event.dart';
import 'package:app_financas/features/auth/bloc/auth_state.dart';
import 'package:app_financas/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()){
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {

      final usuario = await repo.login(event.email, event.senha,);

      emit(AuthAuthenticated(usuario));
    } catch (_) {
      emit(AuthError('Falha no login'));
    }
  }
  
  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await repo.logout();
    emit(AuthUnauthenticated());
  }

  }