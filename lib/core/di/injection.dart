import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/finance/data/firestore_finance_repository.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(FirebaseAuth.instance),
    )
    ..registerLazySingleton<FinanceRepository>(
      () => FirestoreFinanceRepository(FirebaseFirestore.instance),
    );
}
