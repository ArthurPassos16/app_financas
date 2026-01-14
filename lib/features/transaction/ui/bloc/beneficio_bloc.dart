import 'package:app_financas/features/transaction/ui/bloc/beneficio_event.dart';
import 'package:app_financas/features/transaction/ui/bloc/beneficio_state.dart';
import 'package:app_financas/features/transaction/data/beneficio_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficioBloc extends Bloc<BeneficioEvent, BeneficioState> {
  final BeneficioApi api;

  BeneficioBloc(this.api) : super(BeneficioInitial()) {
    on<ConsultarBeneficio>(_onConsultar);
  }

  Future<void> _onConsultar(
    ConsultarBeneficio event,
    Emitter<BeneficioState> emit,
  ) async {
    emit(BeneficioLoading());

    try {
      final dto = await api.consultar(event.id);

      emit(BeneficioLoaded(dto.toEntity()));
    } catch (_) {
      emit(BeneficioError('Erro ao consultar benefício'));
    }
  }
}