// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_config.dart';

/// Estados possíveis para interação com cartas
enum CardInteractionState {
  idle, // Pronto para aceitar cliques
  processing, // Processando match entre duas cartas
  debouncing, // Em período de debounce após um clique
  disabled, // Interações desabilitadas (jogo pausado/terminado)
}

/// Manager thread-safe para controlar interações com cartas
///
/// Esta classe garante que apenas uma operação de carta seja processada
/// por vez, evitando condições de corrida e cliques simultâneos.
class CardInteractionManager {
  CardInteractionState _state = CardInteractionState.idle;
  Timer? _debounceTimer;
  Timer? _processingTimer;
  DateTime? _lastTapTime;

  /// Estado atual das interações
  CardInteractionState get state => _state;

  /// Verifica se pode aceitar um novo clique
  bool get canAcceptTap => _state == CardInteractionState.idle;

  /// Verifica se está processando um match
  bool get isProcessing => _state == CardInteractionState.processing;

  /// Verifica se está em debounce
  bool get isDebouncing => _state == CardInteractionState.debouncing;

  /// Registra um clique em carta de forma thread-safe
  ///
  /// Retorna true se o clique foi aceito, false se foi rejeitado
  bool registerCardTap() {
    final now = DateTime.now();

    // Verifica debounce temporal básico
    if (_lastTapTime != null) {
      final timeSinceLastTap = now.difference(_lastTapTime!);
      if (timeSinceLastTap < MemoryGameConfig.cardTapDebounce) {
        return false; // Rejeita clique muito rápido
      }
    }

    // Só aceita cliques no estado idle
    if (_state != CardInteractionState.idle) {
      return false;
    }

    _lastTapTime = now;
    _startDebounce();
    return true;
  }

  /// Inicia o processamento de match entre cartas
  void startProcessing(VoidCallback onComplete) {
    if (_state != CardInteractionState.debouncing) {
      return; // Só pode processar após um clique válido
    }

    _cancelDebounce();
    _state = CardInteractionState.processing;

    // Timer de segurança para evitar travamentos
    _processingTimer = Timer(MemoryGameConfig.matchProcessingTimeout, () {
      // Força finalização se demorar muito
      finishProcessing();
    });

    // Simula processamento assíncrono
    Timer(const Duration(milliseconds: 50), () {
      onComplete();
    });
  }

  /// Finaliza o processamento de match
  void finishProcessing() {
    _cancelProcessing();
    _state = CardInteractionState.idle;
  }

  /// Desabilita todas as interações
  void disable() {
    _cancelAllTimers();
    _state = CardInteractionState.disabled;
  }

  /// Habilita interações novamente
  void enable() {
    _cancelAllTimers();
    _state = CardInteractionState.idle;
  }

  /// Reset completo do manager
  void reset() {
    _cancelAllTimers();
    _state = CardInteractionState.idle;
    _lastTapTime = null;
  }

  /// Inicia período de debounce
  void _startDebounce() {
    _cancelDebounce();
    _state = CardInteractionState.debouncing;

    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_state == CardInteractionState.debouncing) {
        _state = CardInteractionState.idle;
      }
    });
  }

  /// Cancela o timer de debounce
  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Cancela o timer de processamento
  void _cancelProcessing() {
    _processingTimer?.cancel();
    _processingTimer = null;
  }

  /// Cancela todos os timers
  void _cancelAllTimers() {
    _cancelDebounce();
    _cancelProcessing();
  }

  /// Libera recursos
  void dispose() {
    _cancelAllTimers();
  }

  /// Informações de debug
  @override
  String toString() {
    return 'CardInteractionManager(state: $_state, '
        'lastTap: $_lastTapTime, '
        'canAccept: $canAcceptTap)';
  }
}
