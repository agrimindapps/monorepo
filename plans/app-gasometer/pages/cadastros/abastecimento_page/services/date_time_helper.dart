class DateTimeHelper {
  static DateTime fromMillisecondsSinceEpoch(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static int toMillisecondsSinceEpoch(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }
}
