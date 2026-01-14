import 'package:app_financas/core/config/app_config.dart';
import 'package:app_financas/core/config/env.dart';
import 'package:app_financas/core/network/api_client.dart';
import 'package:app_financas/features/auth/bloc/auth_bloc.dart';
import 'package:app_financas/features/auth/data/auth_repository.dart';
import 'package:app_financas/features/transaction/data/beneficio_datasource.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // --- EXTERNAL (Firebase, ApiClient) ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  
  const environment = Environment.dev;
  sl.registerLazySingleton(() => AppConfig(environment));
  
  // Registra o ApiClient dependendo do AppConfig já registrado
  sl.registerLazySingleton(() => ApiClient(sl<AppConfig>().baseUrl));

  // --- DATA SOURCES ---
  sl.registerLazySingleton(() => BeneficioApi(sl<ApiClient>()));

  // --- BLOCS ---
  // Use registerFactory para Blocs, pois eles devem ter instâncias novas ao fechar/abrir telas
  sl.registerFactory(() => AuthBloc(sl<AuthRepository>()));
}