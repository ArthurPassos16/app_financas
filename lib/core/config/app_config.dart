import 'package:app_financas/core/config/env.dart';


class AppConfig {
  final Environment env;

  AppConfig(this.env);

  String get baseUrl {
    switch (env) {
      case Environment.dev:
        return 'https://jsonplaceholder.typicode.com';
      case Environment.homolog:
        return 'https://api-homolog.prefeitura.gov.br';
      case Environment.prod:
        return 'https://api.prefeitura.gov.br';
    }
  }
}