import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// String extensions
// ---------------------------------------------------------------------------

extension NormalizedDateTimeParsing on String {
  /// Parse an ISO 8601 string and convert to local time. Returns null on failure.
  DateTime? tryParseIsoLocal() {
    final parsed = DateTime.tryParse(this);
    if (parsed == null) return null;
    return parsed.toLocalSafe();
  }

  /// Parse a date-only string to UTC midnight (+2h offset for CET/CEST).
  /// Returns null on failure.
  DateTime? tryToDateOnlyUtc() {
    final parsed = DateTime.tryParse(this)?.add(const Duration(hours: 2));
    if (parsed == null) return null;
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }
}

// ---------------------------------------------------------------------------
// DateTime extensions
// ---------------------------------------------------------------------------

extension NormalizedDateTimeFormatting on DateTime {
  /// Ensure UTC without double converting.
  DateTime toUtcSafe() => isUtc ? this : toUtc();

  /// Ensure local without double converting.
  DateTime toLocalSafe() => isUtc ? toLocal() : this;

  bool isSameDate(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isBeforeDate(DateTime other) =>
      year == other.year && month == other.month && day < other.day ||
      year == other.year && month < other.month ||
      year < other.year;

  bool isAfterDate(DateTime other) =>
      year == other.year && month == other.month && day > other.day ||
      year == other.year && month > other.month ||
      year > other.year;

  /// "dd.MM.yyyy HH:mm Uhr" in local time.
  String formatDateTime() {
    final d = toLocalSafe();
    return '${DateFormat('dd.MM.yyyy HH:mm').format(d)} Uhr';
  }

  /// "HH:mm" in local time.
  String formatTime() {
    return DateFormat('HH:mm').format(toLocalSafe());
  }

  /// "dd.MM.yyyy" in local time.
  String formatDate() {
    return DateFormat('dd.MM.yyyy').format(toLocalSafe());
  }

  /// "yyyy-MM-dd" for JSON serialization (UTC-normalized).
  String formatDateForJson({bool normalizeUtc = true}) {
    final d = normalizeUtc ? toUtcSafe() : this;
    return DateFormat('yyyy-MM-dd').format(d);
  }

  /// Weekday + date "EEEE, dd.MM.yyyy" in German locale.
  String formatWithWeekday({String locale = 'de_DE'}) {
    return DateFormat('EEEE, dd.MM.yyyy', locale).format(toLocalSafe());
  }

  /// Start of day in local time.
  DateTime startOfDayLocal() {
    final local = toLocalSafe();
    return DateTime(local.year, local.month, local.day);
  }

  /// Start of day in UTC.
  DateTime startOfDayUtc() {
    final utc = toUtcSafe();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  /// Contextual timeline label:
  /// - today → "HH:mm"
  /// - this year → "dd.MM. HH:mm"
  /// - older → "dd.MM.yy HH:mm"
  String formatTimelineLabel() {
    final d = toLocalSafe();
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return DateFormat('HH:mm').format(d);
    }
    if (d.year == now.year) {
      return DateFormat('dd.MM. HH:mm').format(d);
    }
    return DateFormat('dd.MM.yy HH:mm').format(d);
  }
}

// ---------------------------------------------------------------------------
// Nullable DateTime extension
// ---------------------------------------------------------------------------

extension NormalizedNullableDateTimeFormatting on DateTime? {
  /// Returns null if this is null, otherwise delegates to formatTimelineLabel.
  String? formatTimelineLabel() => this?.formatTimelineLabel();
}
