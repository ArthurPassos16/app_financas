abstract class BeneficioEvent {}

class ConsultarBeneficio extends BeneficioEvent {
  final int id;
  ConsultarBeneficio({required this.id});
}