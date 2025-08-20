// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// 🚀 ISSUE #5: Helper para implementar debounce na validação de entrada
///
/// Previne múltiplas validações desnecessárias durante digitação rápida,
/// melhorando performance em dispositivos mais lentos.
class DebounceHelper {
  Timer? _timer;
  final Duration delay;

  DebounceHelper({this.delay = const Duration(milliseconds: 300)});

  /// Executa uma ação após o delay especificado
  /// Cancela a execução anterior se uma nova for solicitada
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancela qualquer ação pendente
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Verifica se há uma ação pendente
  bool get isPending => _timer?.isActive ?? false;

  /// Libera recursos
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Estados de validação para feedback visual
enum ValidationState {
  none, // Sem validação
  pending, // Validação em andamento (debounce ativo)
  valid, // Campo válido
  invalid, // Campo inválido
}

/// Resultado da validação com estado e mensagem
class ValidationResult {
  final ValidationState state;
  final String? message;

  const ValidationResult({
    required this.state,
    this.message,
  });

  static const ValidationResult none =
      ValidationResult(state: ValidationState.none);
  static const ValidationResult pending =
      ValidationResult(state: ValidationState.pending);
  static const ValidationResult valid =
      ValidationResult(state: ValidationState.valid);

  static ValidationResult invalid(String message) => ValidationResult(
        state: ValidationState.invalid,
        message: message,
      );

  bool get isValid => state == ValidationState.valid;
  bool get isInvalid => state == ValidationState.invalid;
  bool get isPending => state == ValidationState.pending;
  bool get hasMessage => message != null && message!.isNotEmpty;
}
