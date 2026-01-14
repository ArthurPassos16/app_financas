import 'package:app_financas/features/transaction/ui/bloc/beneficio_bloc.dart' show BeneficioBloc;
import 'package:app_financas/features/transaction/ui/bloc/beneficio_event.dart';
import 'package:app_financas/features/transaction/ui/bloc/beneficio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficioPage extends StatelessWidget {
  const BeneficioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benefício')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context
                    .read<BeneficioBloc>()
                    .add(ConsultarBeneficio(id: 1));
              },
              child: const Text('Consultar'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<BeneficioBloc, BeneficioState>(
              builder: (context, state) {
                if (state is BeneficioInitial) {
                  return const Text('Nenhuma consulta realizada');
                }

                if (state is BeneficioLoading) {
                  return const CircularProgressIndicator();
                }

                if (state is BeneficioLoaded) {
                  return Text(
                    'Benefício ID: ${state.beneficio.id}',
                  );
                }

                if (state is BeneficioError) {
                  return Text(
                    state.mensagem,
                    style: const TextStyle(color: Colors.red),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}