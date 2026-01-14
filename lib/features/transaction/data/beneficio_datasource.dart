import 'package:app_financas/core/network/api_client.dart';
import 'package:app_financas/features/transaction/data/beneficio_dto.dart';

class BeneficioApi {
  final ApiClient client;

  BeneficioApi(this.client);

  Future<BeneficioDto> consultar(int id) async {
    final response = await client.get('/todos/$id');
    return BeneficioDto.fromJson(response.data);
  }
}