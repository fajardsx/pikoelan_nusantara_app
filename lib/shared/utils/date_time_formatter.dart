const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Formats a [DateTime] as `HH:mm` (24-hour), e.g. `10:15`.
String formatTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

/// Formats a [DateTime] as `d MMM yyyy`, e.g. `10 Okt 2026`.
String formatDate(DateTime value) {
  final local = value;
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Formats a [DateTime] as `d MMM yyyy, HH:mm`, e.g. `21 Sep 2026, 10:15`.
String formatDateTime(DateTime value) {
  final local = value;
  return '${local.day} ${_months[local.month - 1]} ${local.year}, ${formatTime(local)}';
}
