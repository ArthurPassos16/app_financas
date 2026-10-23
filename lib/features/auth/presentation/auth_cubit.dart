import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.error,
    this.info,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? error;
  final String? info;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? isSubmitting,
    String? error,
    String? info,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      // Mensagens valem só para o próximo estado.
      error: error,
      info: info,
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, error, info];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges().listen((user) {
      emit(
        user == null
            ? state.copyWith(
                status: AuthStatus.unauthenticated,
                clearUser: true,
              )
            : state.copyWith(status: AuthStatus.authenticated, user: user),
      );
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  Future<void> signIn(String email, String password) =>
      _submit(() => _repository.signIn(email: email, password: password));

  Future<void> signUp(String email, String password) =>
      _submit(() => _repository.signUp(email: email, password: password));

  Future<void> sendPasswordReset(String email) => _submit(
    () => _repository.sendPasswordReset(email),
    successInfo: 'Enviamos um link de redefinição para $email.',
  );

  Future<void> signOut() => _repository.signOut();

  Future<void> _submit(
    Future<void> Function() action, {
    String? successInfo,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await action();
      emit(state.copyWith(isSubmitting: false, info: successInfo));
    } on AuthFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Erro inesperado. Tente novamente.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
