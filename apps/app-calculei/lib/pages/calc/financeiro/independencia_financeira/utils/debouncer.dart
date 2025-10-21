// Dart imports:
import 'dart:async';

class Debouncer {
  final Duration duration;
  Timer? _timer;
  void Function()? _pendingAction;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  void run(void Function() action) {
    _timer?.cancel();
    _pendingAction = action;
    _timer = Timer(duration, () {
      _pendingAction?.call();
      _pendingAction = null;
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  void dispose() {
    cancel();
  }

  bool get isRunning => _timer?.isActive ?? false;
  
  /// Executa a ação pendente imediatamente se houver uma
  void flush() {
    if (_pendingAction != null) {
      cancel();
      _pendingAction!.call();
      _pendingAction = null;
    }
  }
}
