import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper that captures ESC key for Flutter/Riverpod games
///
/// Usage:
/// ```dart
/// EscKeyboardWrapper(
///   onEscPressed: () => ref.read(gameProvider.notifier).togglePause(),
///   child: GameContent(),
/// )
/// ```
class EscKeyboardWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onEscPressed;

  const EscKeyboardWrapper({
    required this.child,
    required this.onEscPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      canRequestFocus: true,
      descendantsAreFocusable: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onEscPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
