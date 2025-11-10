import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String format(
    DateTime date, {
    String pattern = 'dd MMM yyyy, hh:mm a',
  }) {
    return DateFormat(pattern).format(date);
  }

  static String today() {
    final now = DateTime.now();
    return DateFormat('dd MMM yyyy').format(now);
  }

  static bool isExpired(String? dateString) {
    if (dateString == null) return true;
    final date = DateTime.tryParse(dateString);
    if (date == null) return true;
    return date.isBefore(DateTime.now());
  }
}
