import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// Formats [date] for display: Gregorian for `en`, Jalali (Shamsi) for `fa`.
String formatLocalizedDate(DateTime date, {required bool isFarsi}) {
  if (!isFarsi) {
    return DateFormat.yMMMd().format(date);
  }
  final jalali = Jalali.fromDateTime(date);
  final formatter = jalali.formatter;
  return '${formatter.d} ${formatter.mN} ${formatter.yyyy}';
}

/// Short relative time (e.g. "2h", "3d") localized for both digit scripts;
/// digit localization itself is applied by the caller via [toPersianDigits].
String formatRelativeTime(DateTime date, {required DateTime now}) {
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat.yMMMd().format(date);
}
