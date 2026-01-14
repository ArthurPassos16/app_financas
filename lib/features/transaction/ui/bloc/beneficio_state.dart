import 'package:app_financas/features/transaction/domain/beneficio.dart';

abstract class BeneficioState {}

class BeneficioInitial extends BeneficioState {}

class BeneficioLoading extends BeneficioState {}

class BeneficioLoaded extends BeneficioState {
  final Beneficio beneficio;
  BeneficioLoaded(this.beneficio);
}

class BeneficioNaoElegivel extends BeneficioState {
  final String motivo;
  BeneficioNaoElegivel(this.motivo);
}

class BeneficioError extends BeneficioState {
  final String mensagem;
  BeneficioError(this.mensagem);
}