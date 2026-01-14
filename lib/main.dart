import 'package:app_financas/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/injection/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  await di.init(); // Inicializa o "balcão" de serviços
  
  runApp(const TutysFin());
}