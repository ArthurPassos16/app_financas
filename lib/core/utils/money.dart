import 'package:intl/intl.dart';

/// Valores monetários são guardados em centavos (int) para evitar
/// erros de arredondamento de ponto flutuante.
abstract final class Money {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  static String format(int cents) => _currency.format(cents / 100);

  /// Converte texto digitado pelo usuário em centavos.
  ///
  /// Aceita "12,50", "1.234,56", "1234.5", "R$ 10". Retorna `null`
  /// para entradas inválidas ou valores menores ou iguais a zero.
  static int? parseToCents(String input) {
    final s = input.replaceAll(RegExp(r'[R$\s]'), '');
    if (s.isEmpty) return null;

    var intPart = s;
    var decPart = '';

    if (s.contains(',')) {
      final parts = s.split(',');
      if (parts.length != 2) return null;
      intPart = parts[0].replaceAll('.', '');
      decPart = parts[1];
    } else if (s.contains('.')) {
      final last = s.lastIndexOf('.');
      final after = s.substring(last + 1);
      final singleDot = s.indexOf('.') == last;
      if (singleDot && after.length <= 2) {
        intPart = s.substring(0, last);
        decPart = after;
      } else {
        intPart = s.replaceAll('.', '');
      }
    }

    if (intPart.isEmpty) intPart = '0';
    final digits = RegExp(r'^\d+$');
    if (!digits.hasMatch(intPart)) return null;
    if (decPart.isNotEmpty && !digits.hasMatch(decPart)) return null;
    if (decPart.length > 2) return null;

    final cents =
        int.parse(intPart) * 100 +
        (decPart.isEmpty ? 0 : int.parse(decPart.padRight(2, '0')));
    return cents > 0 ? cents : null;
  }

  /// Texto para preencher o campo de valor ao editar ("1234,50").
  static String toInput(int cents) {
    final reais = cents ~/ 100;
    final centavos = (cents % 100).toString().padLeft(2, '0');
    return '$reais,$centavos';
  }
}
