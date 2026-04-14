import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static DateTime? parseDate(String date) {
    try {
      return _dateFormat.parse(date);
    } catch (_) {
      return null;
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static bool isOverdue(DateTime returnDate) {
    return DateTime.now().isAfter(returnDate);
  }

  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }
}
