// Dart imports:
import 'dart:async';

/// Utility class for debouncing function calls
class Debounce {
  final int milliseconds;
  Timer? _timer;

  Debounce({required this.milliseconds});

  /// Execute the function after the debounce delay
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debounce timer
  void dispose() {
    _timer?.cancel();
  }
}

/// Utility function for creating debounced callbacks
Debounce createDebounce(int milliseconds) {
  return Debounce(milliseconds: milliseconds);
}
