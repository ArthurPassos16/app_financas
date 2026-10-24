import 'package:app_financas/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parseToCents', () {
    final cases = <String, int?>{
      '12,50': 1250,
      '12,5': 1250,
      '1.234,56': 123456,
      '1234.5': 123450,
      '1234.56': 123456,
      '1.234': 123400,
      '1.234.567': 123456700,
      r'R$ 10': 1000,
      ' 7 ': 700,
      ',99': 99,
      '0': null,
      '0,00': null,
      '': null,
      'abc': null,
      '1,234,5': null,
      '10,999': null,
      '-5': null,
    };

    cases.forEach((input, expected) {
      test('"$input" -> $expected', () {
        expect(Money.parseToCents(input), expected);
      });
    });
  });

  group('Money.toInput', () {
    test('formata centavos para edição', () {
      expect(Money.toInput(123456), '1234,56');
      expect(Money.toInput(5), '0,05');
      expect(Money.toInput(1000), '10,00');
    });

    test('ida e volta preserva o valor', () {
      for (final cents in [1, 99, 100, 123456, 999999]) {
        expect(Money.parseToCents(Money.toInput(cents)), cents);
      }
    });
  });
}
