/// Controlador de entrada do usuário para o jogo Ping Pong
/// 
/// Gerencia todos os tipos de entrada do usuário incluindo gestos,
/// teclado e controles de acessibilidade.
library;

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';
import 'game_controller.dart';

/// Controlador responsável por gerenciar as entradas do usuário
class InputController {
  /// Controlador principal do jogo
  GameController? _gameController;
  
  /// Estado atual do jogo
  PingPongGameState? _gameState;
  
  /// Configurações de sensibilidade
  double _touchSensitivity = 1.0;
  double _keyboardSensitivity = 5.0;
  
  /// Estados de entrada
  bool _isKeyboardEnabled = true;
  bool _isTouchEnabled = true;
  bool _isAccessibilityEnabled = false;
  
  /// Posição inicial do toque
  double _initialTouchY = 0.0;
  
  /// Posição anterior da raquete para calcular delta
  double _previousPaddleY = 0.0;
  
  /// Velocidade de movimento por teclado
  double _keyboardMoveSpeed = 8.0;
  
  /// Teclas pressionadas atualmente
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  
  /// Inicializa o controlador de entrada
  void initialize(GameController gameController) {
    _gameController = gameController;
    _gameState = gameController.gameState;
    _previousPaddleY = _gameState?.playerPaddle.y ?? 0.0;
  }
  
  /// Gerencia início de toque na tela
  void handleTouchStart(double touchY) {
    if (!_isTouchEnabled || !_canProcessInput()) return;
    
    _initialTouchY = touchY;
    _previousPaddleY = _gameState?.playerPaddle.y ?? 0.0;
    
    // Feedback tátil leve
    _provideLightHapticFeedback();
  }
  
  /// Gerencia movimento de toque na tela
  void handleTouchMove(double touchY, double deltaY) {
    if (!_isTouchEnabled || !_canProcessInput()) return;
    
    // Aplica sensibilidade ao movimento
    final adjustedDelta = deltaY * _touchSensitivity;
    
    // Move a raquete do jogador
    _gameController?.movePlayerPaddle(adjustedDelta);
    
    // Feedback tátil baseado na velocidade do movimento
    _provideMovementHapticFeedback(adjustedDelta);
  }
  
  /// Gerencia fim de toque na tela
  void handleTouchEnd() {
    if (!_isTouchEnabled) return;
    
    // Reset das variáveis de toque
    _initialTouchY = 0.0;
    _previousPaddleY = _gameState?.playerPaddle.y ?? 0.0;
  }
  
  /// Gerencia entrada do teclado
  void handleKeyboardInput(KeyEvent event) {
    if (!_isKeyboardEnabled || !_canProcessInput()) return;
    
    final key = event.logicalKey;
    
    if (event is KeyDownEvent) {
      _pressedKeys.add(key);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(key);
    }
    
    // Processa teclas pressionadas
    _processKeyboardMovement();
  }
  
  /// Processa movimento via teclado
  void _processKeyboardMovement() {
    double movement = 0.0;
    
    // Teclas de movimento para cima
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      movement -= _keyboardMoveSpeed;
    }
    
    // Teclas de movimento para baixo
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      movement += _keyboardMoveSpeed;
    }
    
    // Aplica sensibilidade
    movement *= _keyboardSensitivity;
    
    // Move a raquete se houver movimento
    if (movement != 0) {
      _gameController?.movePlayerPaddle(movement);
      _provideMovementHapticFeedback(movement);
    }
  }
  
  /// Gerencia controles de acessibilidade
  void handleAccessibilityInput(AccessibilityInputType type, double value) {
    if (!_isAccessibilityEnabled || !_canProcessInput()) return;
    
    switch (type) {
      case AccessibilityInputType.moveUp:
        _gameController?.movePlayerPaddle(-value);
        break;
      case AccessibilityInputType.moveDown:
        _gameController?.movePlayerPaddle(value);
        break;
      case AccessibilityInputType.moveToPosition:
        final currentY = _gameState?.playerPaddle.y ?? 0.0;
        final delta = value - currentY;
        _gameController?.movePlayerPaddle(delta);
        break;
    }
    
    _provideAccessibilityHapticFeedback();
  }
  
  /// Gerencia ações de jogo (pausa, reinício, etc.)
  void handleGameAction(GameAction action) {
    switch (action) {
      case GameAction.pause:
        _gameController?.togglePause();
        _provideMediumHapticFeedback();
        break;
      case GameAction.start:
        _gameController?.startGame();
        _provideMediumHapticFeedback();
        break;
      case GameAction.stop:
        _gameController?.stopGame();
        _provideMediumHapticFeedback();
        break;
      case GameAction.restart:
        _gameController?.restartGame();
        _provideMediumHapticFeedback();
        break;
    }
  }
  
  /// Verifica se pode processar entrada
  bool _canProcessInput() {
    return _gameState?.isPlaying ?? false;
  }
  
  /// Fornece feedback tátil leve
  void _provideLightHapticFeedback() {
    if (_gameState?.gameMode == GameMode.practice) return;
    
    HapticFeedback.lightImpact();
  }
  
  /// Fornece feedback tátil médio
  void _provideMediumHapticFeedback() {
    HapticFeedback.mediumImpact();
  }
  
  /// Fornece feedback tátil baseado no movimento
  void _provideMovementHapticFeedback(double movement) {
    // Feedback apenas para movimentos rápidos
    if (movement.abs() > 10.0) {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Fornece feedback tátil para acessibilidade
  void _provideAccessibilityHapticFeedback() {
    HapticFeedback.selectionClick();
  }
  
  /// Configura sensibilidade do toque
  void setTouchSensitivity(double sensitivity) {
    _touchSensitivity = sensitivity.clamp(0.1, 3.0);
  }
  
  /// Configura sensibilidade do teclado
  void setKeyboardSensitivity(double sensitivity) {
    _keyboardSensitivity = sensitivity.clamp(0.1, 3.0);
  }
  
  /// Configura velocidade de movimento do teclado
  void setKeyboardMoveSpeed(double speed) {
    _keyboardMoveSpeed = speed.clamp(1.0, 20.0);
  }
  
  /// Habilita ou desabilita entrada por toque
  void setTouchEnabled(bool enabled) {
    _isTouchEnabled = enabled;
  }
  
  /// Habilita ou desabilita entrada por teclado
  void setKeyboardEnabled(bool enabled) {
    _isKeyboardEnabled = enabled;
    if (!enabled) {
      _pressedKeys.clear();
    }
  }
  
  /// Habilita ou desabilita controles de acessibilidade
  void setAccessibilityEnabled(bool enabled) {
    _isAccessibilityEnabled = enabled;
  }
  
  /// Obtém configurações atuais de entrada
  Map<String, dynamic> getInputSettings() {
    return {
      'touchSensitivity': _touchSensitivity,
      'keyboardSensitivity': _keyboardSensitivity,
      'keyboardMoveSpeed': _keyboardMoveSpeed,
      'touchEnabled': _isTouchEnabled,
      'keyboardEnabled': _isKeyboardEnabled,
      'accessibilityEnabled': _isAccessibilityEnabled,
    };
  }
  
  /// Carrega configurações de entrada
  void loadInputSettings(Map<String, dynamic> settings) {
    _touchSensitivity = settings['touchSensitivity']?.toDouble() ?? 1.0;
    _keyboardSensitivity = settings['keyboardSensitivity']?.toDouble() ?? 5.0;
    _keyboardMoveSpeed = settings['keyboardMoveSpeed']?.toDouble() ?? 8.0;
    _isTouchEnabled = settings['touchEnabled'] ?? true;
    _isKeyboardEnabled = settings['keyboardEnabled'] ?? true;
    _isAccessibilityEnabled = settings['accessibilityEnabled'] ?? false;
  }
  
  /// Reseta todas as configurações para padrão
  void resetToDefaults() {
    _touchSensitivity = 1.0;
    _keyboardSensitivity = 5.0;
    _keyboardMoveSpeed = 8.0;
    _isTouchEnabled = true;
    _isKeyboardEnabled = true;
    _isAccessibilityEnabled = false;
    _pressedKeys.clear();
  }
  
  /// Obtém teclas atualmente pressionadas
  Set<LogicalKeyboardKey> get pressedKeys => Set.from(_pressedKeys);
  
  /// Verifica se uma tecla específica está pressionada
  bool isKeyPressed(LogicalKeyboardKey key) {
    return _pressedKeys.contains(key);
  }
  
  /// Obtém estatísticas de entrada
  Map<String, dynamic> getInputStatistics() {
    return {
      'touchEnabled': _isTouchEnabled,
      'keyboardEnabled': _isKeyboardEnabled,
      'accessibilityEnabled': _isAccessibilityEnabled,
      'pressedKeysCount': _pressedKeys.length,
      'currentSettings': getInputSettings(),
    };
  }
  
  /// Libera recursos
  void dispose() {
    _gameController = null;
    _gameState = null;
    _pressedKeys.clear();
  }
}

/// Tipos de entrada de acessibilidade
enum AccessibilityInputType {
  moveUp,
  moveDown,
  moveToPosition
}

/// Ações de jogo
enum GameAction {
  pause,
  start,
  stop,
  restart
}
