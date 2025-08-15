import 'package:intl/intl.dart';

class DateMGM
{

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

}