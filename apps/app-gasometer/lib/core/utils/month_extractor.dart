import '../../../core/utils/date_utils.dart' as local_date_utils;

/// Helper class for extracting months from different entity types
/// 
/// Provides a unified way to generate month ranges from various record types,
/// ensuring that the current month is always included even when no records exist.
class MonthExtractor {
  static final _dateUtils = local_date_utils.DateUtils();

  /// Extracts months from a list of records with a date field
  /// 
  /// [records] List of records
  /// [dateExtractor] Function to extract DateTime from each record
  /// 
  /// Returns a list of DateTime objects representing months (newest first),
  /// always including the current month if no records exist.
  static List<DateTime> extractMonths<T>(
    List<T> records,
    DateTime Function(T) dateExtractor,
  ) {
    if (records.isEmpty) {
      final now = DateTime.now();
      return [DateTime(now.year, now.month)];
    }

    final dates = records.map(dateExtractor).toList();
    return _dateUtils.generateMonthRange(dates);
  }
}
