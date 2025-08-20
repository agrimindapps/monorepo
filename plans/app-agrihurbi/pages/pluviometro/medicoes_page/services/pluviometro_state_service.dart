// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../controllers/pluviometros_controller.dart';

/// Service responsável por acesso seguro ao estado de pluviômetros
class PluviometroStateService {
  final PluviometrosController _controller;

  PluviometroStateService({PluviometrosController? controller})
      : _controller = controller ?? PluviometrosController();

  /// Obtém ID do pluviômetro selecionado de forma segura
  String? getSelectedPluviometroId() {
    try {
      final id = _controller.selectedPluviometroId;

      // Validação básica
      if (id.isEmpty) {
        return null;
      }

      return id;
    } catch (e) {
      // Log do erro para debugging
      _logError('Erro ao acessar selectedPluviometroId: $e');
      return null;
    }
  }

  /// Obtém ID do pluviômetro selecionado com fallback
  String getSelectedPluviometroIdWithFallback({String fallback = ''}) {
    return getSelectedPluviometroId() ?? fallback;
  }

  /// Verifica se há um pluviômetro selecionado válido
  bool hasValidSelectedPluviometro() {
    final id = getSelectedPluviometroId();
    return id != null && id.isNotEmpty;
  }

  /// Valida se um ID de pluviômetro é válido
  bool isValidPluviometroId(String? id) {
    if (id == null || id.isEmpty) return false;

    // Aqui podem ser adicionadas mais validações específicas
    // Por exemplo, formato UUID, comprimento mínimo, etc.
    return id.length >= 3; // Validação básica
  }

  /// Obtém estado de inicialização do controller
  bool isControllerInitialized() {
    try {
      // Tenta acessar uma propriedade básica para verificar se o controller está inicializado
      _controller.selectedPluviometroId;
      return true;
    } catch (e) {
      _logError('Controller não inicializado: $e');
      return false;
    }
  }

  /// Aguarda inicialização do controller (com timeout)
  Future<bool> waitForInitialization(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final startTime = DateTime.now();

    while (!isControllerInitialized()) {
      if (DateTime.now().difference(startTime) > timeout) {
        _logError('Timeout aguardando inicialização do controller');
        return false;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    return true;
  }

  /// Log de erros (pode ser integrado com sistema de logging mais robusto)
  void _logError(String message) {
    // Por enquanto apenas print, mas pode ser substituído por sistema de logging
    debugPrint('PluviometroStateService: $message');
  }

  /// Debug: obtém informações sobre o estado atual
  Map<String, dynamic> getDebugInfo() {
    return {
      'isControllerInitialized': isControllerInitialized(),
      'selectedPluviometroId': getSelectedPluviometroId(),
      'hasValidSelection': hasValidSelectedPluviometro(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
