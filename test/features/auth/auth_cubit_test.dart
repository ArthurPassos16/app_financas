import 'dart:async';

import 'package:app_financas/features/auth/domain/app_user.dart';
import 'package:app_financas/features/auth/domain/auth_repository.dart';
import 'package:app_financas/features/auth/presentation/auth_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late StreamController<AppUser?> authChanges;

  const user = AppUser(uid: 'u1', email: 'tutu@email.com');

  setUp(() {
    repository = _MockAuthRepository();
    authChanges = StreamController<AppUser?>();
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => authChanges.stream);
  });

  tearDown(() => authChanges.close());

  blocTest<AuthCubit, AuthState>(
    'reflete o usuário vindo do Firebase',
    build: () => AuthCubit(repository),
    act: (_) {
      authChanges
        ..add(user)
        ..add(null);
    },
    expect: () => const [
      AuthState(status: AuthStatus.authenticated, user: user),
      AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'mostra a mensagem quando o login falha',
    setUp: () => when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthFailure('E-mail ou senha incorretos.')),
    build: () => AuthCubit(repository),
    act: (cubit) => cubit.signIn('tutu@email.com', '123456'),
    expect: () => const [
      AuthState(isSubmitting: true),
      AuthState(error: 'E-mail ou senha incorretos.'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'informa quando o e-mail de redefinição é enviado',
    setUp: () => when(
      () => repository.sendPasswordReset(any()),
    ).thenAnswer((_) async {}),
    build: () => AuthCubit(repository),
    act: (cubit) => cubit.sendPasswordReset('tutu@email.com'),
    expect: () => const [
      AuthState(isSubmitting: true),
      AuthState(info: 'Enviamos um link de redefinição para tutu@email.com.'),
    ],
  );
}
