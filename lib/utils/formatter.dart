import 'package:intl/intl.dart';

String formatRupiah(num number) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(number);
}