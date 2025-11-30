import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers for app-gasometer tests
class TestHelpers {
  /// Creates a ProviderContainer with optional overrides
  static ProviderContainer createContainer({
    List<Override> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: overrides,
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Verifies an Either contains a Right value
  static T expectRight<L, T>(Either<L, T> either) {
    expect(either.isRight(), true, reason: 'Expected Right but got Left');
    return either.fold(
      (left) => throw Exception('Expected Right but got Left: $left'),
      (right) => right,
    );
  }

  /// Verifies an Either contains a Left value
  static L expectLeft<L, T>(Either<L, T> either) {
    expect(either.isLeft(), true, reason: 'Expected Left but got Right');
    return either.fold(
      (left) => left,
      (right) => throw Exception('Expected Left but got Right: $right'),
    );
  }

  /// Waits for async operations with timeout
  static Future<void> waitForAsync({
    int milliseconds = 100,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  /// Creates a DateTime for testing (fixed date)
  static DateTime testDate({
    int year = 2024,
    int month = 1,
    int day = 1,
    int hour = 12,
  }) {
    return DateTime(year, month, day, hour);
  }

  /// Creates a DateTime range for testing
  static DateTimeRange testDateRange({
    DateTime? start,
    DateTime? end,
  }) {
    return DateTimeRange(
      start: start ?? testDate(year: 2024, month: 1, day: 1),
      end: end ?? testDate(year: 2024, month: 12, day: 31),
    );
  }
}

/// Extension for Either testing
extension EitherTestExtension<L, R> on Either<L, R> {
  /// Asserts this Either is a Right value
  R expectRight() {
    expect(isRight(), true);
    return fold(
        (l) => throw Exception('Expected Right but got Left: $l'), (r) => r);
  }

  /// Asserts this Either is a Left value
  L expectLeft() {
    expect(isLeft(), true);
    return fold(
        (l) => l, (r) => throw Exception('Expected Left but got Right: $r'));
  }
}

class DateTimeRange {

  DateTimeRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}
