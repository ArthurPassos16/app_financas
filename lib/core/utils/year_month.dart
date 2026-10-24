import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Representa um mês do calendário (ex.: outubro de 2026).
class YearMonth extends Equatable implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month) : assert(month >= 1 && month <= 12);

  factory YearMonth.fromDate(DateTime date) => YearMonth(date.year, date.month);

  final int year;
  final int month;

  /// Primeiro instante do mês.
  DateTime get start => DateTime(year, month);

  /// Primeiro instante do mês seguinte (limite exclusivo).
  DateTime get end => DateTime(year, month + 1);

  YearMonth addMonths(int n) => YearMonth.fromDate(DateTime(year, month + n));

  bool contains(DateTime date) => date.year == year && date.month == month;

  /// "Outubro de 2026"
  String get label {
    final text = DateFormat.yMMMM('pt_BR').format(start);
    return text[0].toUpperCase() + text.substring(1);
  }

  /// "out"
  String get shortLabel =>
      DateFormat.MMM('pt_BR').format(start).replaceAll('.', '');

  @override
  int compareTo(YearMonth other) => year != other.year
      ? year.compareTo(other.year)
      : month.compareTo(other.month);

  @override
  List<Object?> get props => [year, month];

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}
