import 'package:app_financas/features/transaction/ui/bloc/beneficio_bloc.dart';
import 'package:app_financas/features/transaction/ui/beneficio_page.dart';
import 'package:app_financas/core/injection/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TutysFin extends StatelessWidget {
  const TutysFin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Finanças',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF146BFA),
      ),
      home: BlocProvider(
        create: (_) => sl<BeneficioBloc>(), 
        child: const BeneficioPage(),
      ),
    );
  }
}