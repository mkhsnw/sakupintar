import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(date);
  }
}
