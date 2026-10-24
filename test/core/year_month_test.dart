import 'package:app_financas/core/utils/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('addMonths atravessa a virada do ano', () {
    expect(const YearMonth(2026, 11).addMonths(2), const YearMonth(2027, 1));
    expect(const YearMonth(2026, 2).addMonths(-3), const YearMonth(2025, 11));
  });

  test('start e end delimitam o mês', () {
    const m = YearMonth(2026, 12);
    expect(m.start, DateTime(2026, 12));
    expect(m.end, DateTime(2027, 1));
  });

  test('contains', () {
    const m = YearMonth(2026, 10);
    expect(m.contains(DateTime(2026, 10, 31, 23, 59)), isTrue);
    expect(m.contains(DateTime(2026, 11, 1)), isFalse);
  });

  test('label em português com inicial maiúscula', () {
    expect(const YearMonth(2026, 10).label, 'Outubro de 2026');
  });
}
