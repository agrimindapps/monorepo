// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/paddle.dart';

/// Serviço de isolate para cálculos de física do jogo Ping Pong
///
/// Executa cálculos de física em uma thread separada para manter
/// a UI responsiva e melhorar a performance do jogo.


/// Serviço que gerencia os cálculos de física em isolate separado
class PhysicsIsolateService {
  /// Isolate para cálculos de física
  Isolate? _physicsIsolate;

  /// Porta para enviar comandos ao isolate
  SendPort? _physicsCommandPort;

  /// Porta para receber resultados do isolate
  ReceivePort? _physicsResultPort;

  /// Controlador de stream para resultados
  StreamController<PhysicsResult>? _resultController;

  /// Indica se o isolate está ativo
  bool _isActive = false;

  /// Configurações atuais de física
  PhysicsConfig _config = PhysicsConfig();

  /// Stream de resultados de física
  Stream<PhysicsResult> get physicsResults =>
      _resultController?.stream ?? const Stream.empty();

  /// Getter para verificar se está ativo
  bool get isActive => _isActive;

  /// Inicializa o serviço de isolate
  Future<void> initialize() async {
    if (_isActive) return;

    try {
      // Cria a porta para receber resultados
      _physicsResultPort = ReceivePort();
      _resultController = StreamController<PhysicsResult>.broadcast();

      // Inicia o isolate
      _physicsIsolate = await Isolate.spawn(
        _physicsIsolateEntryPoint,
        _physicsResultPort!.sendPort,
        debugName: 'PingPongPhysicsIsolate',
      );

      // Configura listener para resultados
      _physicsResultPort!.listen((dynamic message) {
        if (message is SendPort) {
          // Primeira mensagem: porta de comando
          _physicsCommandPort = message;
          _isActive = true;

          // Envia configuração inicial
          _sendConfiguration();
        } else if (message is PhysicsResult) {
          // Resultado de física
          _resultController?.add(message);
        }
      });
    } catch (e) {
      debugPrint('Erro ao inicializar isolate de física: $e');
      await dispose();
    }
  }

  /// Envia configuração para o isolate
  void _sendConfiguration() {
    if (_physicsCommandPort != null) {
      _physicsCommandPort!.send(PhysicsCommand.configure(_config));
    }
  }

  /// Inicia os cálculos de física
  void startPhysics(PhysicsState initialState) {
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.start(initialState));
  }

  /// Para os cálculos de física
  void stopPhysics() {
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.stop());
  }

  /// Pausa os cálculos de física
  void pausePhysics() {
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.pause());
  }

  /// Retoma os cálculos de física
  void resumePhysics() {
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.resume());
  }

  /// Atualiza o estado de uma raquete
  void updatePaddle(PaddleUpdate update) {
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.updatePaddle(update));
  }

  /// Atualiza configurações de física
  void updateConfiguration(PhysicsConfig config) {
    _config = config;
    if (!_isActive || _physicsCommandPort == null) return;

    _physicsCommandPort!.send(PhysicsCommand.configure(config));
  }

  /// Libera recursos e para o isolate
  Future<void> dispose() async {
    if (_physicsIsolate != null) {
      _physicsCommandPort?.send(PhysicsCommand.stop());
      _physicsIsolate!.kill();
      _physicsIsolate = null;
    }

    _physicsResultPort?.close();
    _physicsResultPort = null;
    _physicsCommandPort = null;

    await _resultController?.close();
    _resultController = null;

    _isActive = false;
  }

  /// Ponto de entrada do isolate de física
  static void _physicsIsolateEntryPoint(SendPort mainSendPort) {
    // Cria porta para receber comandos
    final commandPort = ReceivePort();

    // Envia a porta de comando para o thread principal
    mainSendPort.send(commandPort.sendPort);

    // Inicializa o worker de física
    final worker = PhysicsWorker(mainSendPort);

    // Escuta comandos
    commandPort.listen((dynamic message) {
      if (message is PhysicsCommand) {
        worker.handleCommand(message);
      }
    });
  }
}

/// Worker que executa os cálculos de física no isolate
class PhysicsWorker {
  final SendPort _mainSendPort;

  /// Timer para loop de física
  Timer? _physicsTimer;

  /// Estado atual da física
  PhysicsState? _currentState;

  /// Configuração de física
  PhysicsConfig _config = PhysicsConfig();

  /// Indica se os cálculos estão ativos
  bool _isRunning = false;

  /// Indica se está pausado
  bool _isPaused = false;

  PhysicsWorker(this._mainSendPort);

  /// Gerencia comandos recebidos
  void handleCommand(PhysicsCommand command) {
    switch (command.type) {
      case PhysicsCommandType.configure:
        _config = command.config!;
        break;
      case PhysicsCommandType.start:
        _start(command.initialState!);
        break;
      case PhysicsCommandType.stop:
        _stop();
        break;
      case PhysicsCommandType.pause:
        _pause();
        break;
      case PhysicsCommandType.resume:
        _resume();
        break;
      case PhysicsCommandType.updatePaddle:
        _updatePaddle(command.paddleUpdate!);
        break;
    }
  }

  /// Inicia os cálculos de física
  void _start(PhysicsState initialState) {
    _currentState = initialState;
    _isRunning = true;
    _isPaused = false;

    _physicsTimer = Timer.periodic(
      const Duration(milliseconds: GameConfig.gameLoopIntervalMs),
      (timer) => _updatePhysics(),
    );
  }

  /// Para os cálculos de física
  void _stop() {
    _physicsTimer?.cancel();
    _physicsTimer = null;
    _isRunning = false;
    _isPaused = false;
    _currentState = null;
  }

  /// Pausa os cálculos
  void _pause() {
    _isPaused = true;
  }

  /// Retoma os cálculos
  void _resume() {
    _isPaused = false;
  }

  /// Atualiza estado da raquete
  void _updatePaddle(PaddleUpdate update) {
    if (_currentState == null) return;

    if (update.paddleType == PaddleType.player) {
      _currentState!.playerPaddleY = update.newY;
      _currentState!.playerPaddleVelocity = update.velocity;
    } else {
      _currentState!.aiPaddleY = update.newY;
      _currentState!.aiPaddleVelocity = update.velocity;
    }
  }

  /// Atualiza física a cada frame
  void _updatePhysics() {
    if (!_isRunning || _isPaused || _currentState == null) return;

    final state = _currentState!;

    // Atualiza posição da bola
    state.ballX += state.ballSpeedX;
    state.ballY += state.ballSpeedY;

    // Verifica colisões com paredes
    _checkWallCollisions(state);

    // Verifica colisões com raquetes
    _checkPaddleCollisions(state);

    // Verifica se saiu pelas laterais
    final scoreResult = _checkScoreCollisions(state);

    // Envia resultado para o thread principal
    _mainSendPort.send(PhysicsResult(
      ballX: state.ballX,
      ballY: state.ballY,
      ballSpeedX: state.ballSpeedX,
      ballSpeedY: state.ballSpeedY,
      playerPaddleY: state.playerPaddleY,
      aiPaddleY: state.aiPaddleY,
      scoreResult: scoreResult,
      collisionType: state.lastCollisionType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Reset do tipo de colisão
    state.lastCollisionType = null;
  }

  /// Verifica colisões com paredes
  void _checkWallCollisions(PhysicsState state) {
    final halfHeight = state.screenHeight / 2;
    const ballRadius = GameConfig.ballRadius;

    if (state.ballY <= -halfHeight + ballRadius ||
        state.ballY >= halfHeight - ballRadius) {
      state.ballSpeedY = -state.ballSpeedY;
      state.lastCollisionType = CollisionType.wall;
    }
  }

  /// Verifica colisões com raquetes
  void _checkPaddleCollisions(PhysicsState state) {
    const ballRadius = GameConfig.ballRadius;
    const paddleWidth = GameConfig.paddleWidth;
    const paddleHeight = GameConfig.paddleHeight;

    // Colisão com raquete do jogador
    if (state.ballX <= -state.screenWidth / 2 + paddleWidth * 2 &&
        state.ballX >= -state.screenWidth / 2 + paddleWidth &&
        state.ballY >= state.playerPaddleY - paddleHeight / 2 &&
        state.ballY <= state.playerPaddleY + paddleHeight / 2) {
      _handlePaddleCollision(state, PaddleType.player);
    }

    // Colisão com raquete da IA
    if (state.ballX >= state.screenWidth / 2 - paddleWidth * 2 &&
        state.ballX <= state.screenWidth / 2 - paddleWidth &&
        state.ballY >= state.aiPaddleY - paddleHeight / 2 &&
        state.ballY <= state.aiPaddleY + paddleHeight / 2) {
      _handlePaddleCollision(state, PaddleType.ai);
    }
  }

  /// Gerencia colisão com raquete
  void _handlePaddleCollision(PhysicsState state, PaddleType paddleType) {
    // Inverte velocidade horizontal
    state.ballSpeedX = -state.ballSpeedX;

    // Calcula ângulo baseado na posição de impacto
    final paddleY =
        paddleType == PaddleType.player ? state.playerPaddleY : state.aiPaddleY;
    final paddleVelocity = paddleType == PaddleType.player
        ? state.playerPaddleVelocity
        : state.aiPaddleVelocity;

    final relativeImpact =
        (state.ballY - paddleY) / (GameConfig.paddleHeight / 2);
    state.ballSpeedY = relativeImpact * GameConfig.maxAngleEffect;

    // Adiciona efeito da velocidade da raquete
    state.ballSpeedY += paddleVelocity * 0.1;

    // Aumenta velocidade ligeiramente
    state.ballSpeedX *= GameConfig.ballSpeedIncrease;
    state.ballSpeedY *= GameConfig.ballSpeedIncrease;

    // Limita velocidade máxima
    _capBallSpeed(state);

    state.lastCollisionType = CollisionType.paddle;
  }

  /// Verifica se a bola saiu pelas laterais
  ScoreResult? _checkScoreCollisions(PhysicsState state) {
    const ballRadius = GameConfig.ballRadius;

    if (state.ballX < -state.screenWidth / 2 - ballRadius) {
      return ScoreResult.aiScored;
    } else if (state.ballX > state.screenWidth / 2 + ballRadius) {
      return ScoreResult.playerScored;
    }

    return null;
  }

  /// Limita velocidade da bola
  void _capBallSpeed(PhysicsState state) {
    if (state.ballSpeedX.abs() > GameConfig.maxBallSpeed) {
      state.ballSpeedX =
          GameConfig.maxBallSpeed * (state.ballSpeedX > 0 ? 1 : -1);
    }
    if (state.ballSpeedY.abs() > GameConfig.maxBallSpeed) {
      state.ballSpeedY =
          GameConfig.maxBallSpeed * (state.ballSpeedY > 0 ? 1 : -1);
    }
  }
}

/// Configuração de física para o isolate
class PhysicsConfig {
  final double gravity;
  final double friction;
  final double bounceFactor;
  final double paddleReflection;
  final bool enableAdvancedPhysics;

  PhysicsConfig({
    this.gravity = 0.0,
    this.friction = 0.99,
    this.bounceFactor = 1.0,
    this.paddleReflection = 1.0,
    this.enableAdvancedPhysics = true,
  });
}

/// Estado da física do jogo
class PhysicsState {
  double ballX;
  double ballY;
  double ballSpeedX;
  double ballSpeedY;
  double playerPaddleY;
  double aiPaddleY;
  double playerPaddleVelocity;
  double aiPaddleVelocity;
  double screenWidth;
  double screenHeight;
  CollisionType? lastCollisionType;

  PhysicsState({
    required this.ballX,
    required this.ballY,
    required this.ballSpeedX,
    required this.ballSpeedY,
    required this.playerPaddleY,
    required this.aiPaddleY,
    this.playerPaddleVelocity = 0.0,
    this.aiPaddleVelocity = 0.0,
    required this.screenWidth,
    required this.screenHeight,
    this.lastCollisionType,
  });
}

/// Resultado dos cálculos de física
class PhysicsResult {
  final double ballX;
  final double ballY;
  final double ballSpeedX;
  final double ballSpeedY;
  final double playerPaddleY;
  final double aiPaddleY;
  final ScoreResult? scoreResult;
  final CollisionType? collisionType;
  final int timestamp;

  PhysicsResult({
    required this.ballX,
    required this.ballY,
    required this.ballSpeedX,
    required this.ballSpeedY,
    required this.playerPaddleY,
    required this.aiPaddleY,
    this.scoreResult,
    this.collisionType,
    required this.timestamp,
  });
}

/// Comando para o isolate de física
class PhysicsCommand {
  final PhysicsCommandType type;
  final PhysicsConfig? config;
  final PhysicsState? initialState;
  final PaddleUpdate? paddleUpdate;

  PhysicsCommand.configure(this.config)
      : type = PhysicsCommandType.configure,
        initialState = null,
        paddleUpdate = null;

  PhysicsCommand.start(this.initialState)
      : type = PhysicsCommandType.start,
        config = null,
        paddleUpdate = null;

  PhysicsCommand.stop()
      : type = PhysicsCommandType.stop,
        config = null,
        initialState = null,
        paddleUpdate = null;

  PhysicsCommand.pause()
      : type = PhysicsCommandType.pause,
        config = null,
        initialState = null,
        paddleUpdate = null;

  PhysicsCommand.resume()
      : type = PhysicsCommandType.resume,
        config = null,
        initialState = null,
        paddleUpdate = null;

  PhysicsCommand.updatePaddle(this.paddleUpdate)
      : type = PhysicsCommandType.updatePaddle,
        config = null,
        initialState = null;
}

/// Tipos de comando para física
enum PhysicsCommandType { configure, start, stop, pause, resume, updatePaddle }

/// Atualização de raquete
class PaddleUpdate {
  final PaddleType paddleType;
  final double newY;
  final double velocity;

  PaddleUpdate({
    required this.paddleType,
    required this.newY,
    this.velocity = 0.0,
  });
}

/// Tipos de colisão
enum CollisionType { wall, paddle, score }

/// Resultado de pontuação
enum ScoreResult { playerScored, aiScored }
