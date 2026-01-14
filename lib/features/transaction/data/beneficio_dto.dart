import 'package:app_financas/features/transaction/domain/beneficio.dart';

class BeneficioDto {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  BeneficioDto({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory BeneficioDto.fromJson(Map<String, dynamic> json) {
    return BeneficioDto(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  Beneficio toEntity() {
  return Beneficio(
    id: id,
  );
}
}