import 'package:intl/intl.dart';

/// Formats a numeric amount into an Indonesian Rupiah string.
/// Uses intl NumberFormat for reliable locale‑aware formatting on all platforms.
/// Example: `formatRupiah(62700)` => `Rp 62.700`.
String formatRupiah(num amount, {bool withPrefix = true}) {
  final formatter = NumberFormat.currency(
    locale: 'id',
    symbol: withPrefix ? 'Rp ' : '',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}
