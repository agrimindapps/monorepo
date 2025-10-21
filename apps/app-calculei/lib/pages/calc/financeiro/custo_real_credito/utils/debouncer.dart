// Dart imports:
import 'dart:async';

/// A class that helps to debounce repetitive actions by waiting a specified duration
/// before executing the latest callback.
class Debouncer {
  final Duration delay;
  final void Function() onValue;
  Timer? _timer;

  Debouncer({
    required this.delay,
    required this.onValue,
  });

  set value(bool value) {
    if (value) {
      if (_timer?.isActive ?? false) _timer!.cancel();
      _timer = Timer(delay, onValue);
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
