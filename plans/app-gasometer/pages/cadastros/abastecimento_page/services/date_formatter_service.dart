// Package imports:
import 'package:intl/intl.dart';

class DateFormatterService {
  String formatDateHeader(DateTime date) {
    return DateFormat('MMM yy', 'pt_BR').format(date);
  }

  String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(date);
  }

  String formatDay(DateTime date) {
    return DateFormat('dd').format(date);
  }

  String formatWeekday(DateTime date) {
    return DateFormat('EEE', 'pt_BR').format(date).toUpperCase();
  }
}
