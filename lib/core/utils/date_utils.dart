import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
