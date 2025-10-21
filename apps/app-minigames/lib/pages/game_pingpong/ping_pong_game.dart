// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PingPongGame extends StatefulWidget {
  const PingPongGame({super.key});

  @override
  State<PingPongGame> createState() => _PingPongGameState();
}

class _PingPongGameState extends State<PingPongGame> {
  // Dimensões do jogo
  static const double paddleWidth = 16.0;
  static const double paddleHeight = 100.0;
  static const double ballSize = 20.0;

  // Posições iniciais
  double _ballX = 0.0;
  double _ballY = 0.0;
  double _playerPaddleY = 0.0;
  double _aiPaddleY = 0.0;

  // Velocidade da bola
  double _ballSpeedX = 4.0;
  double _ballSpeedY = 4.0;
  final double _maxBallSpeed = 10.0;

  // Dimensões da tela
  late double _screenWidth;
  late double _screenHeight;

  // Pontuação
  int _playerScore = 0;
  int _aiScore = 0;

  // Dificuldade
  final double _aiReactionSpeed = 0.08; // Ajuste para alterar a dificuldade

  // Estado do jogo
  bool _isPlaying = false;
  bool _isPaused = false;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _resetBall();

    // Configura o jogo para tela cheia
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();

    // Restaura a orientação da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _resetBall() {
    setState(() {
      _ballX = 0.0;
      _ballY = 0.0;

      // Direção aleatória da bola
      _ballSpeedX = Random().nextBool() ? 4.0 : -4.0;
      _ballSpeedY = Random().nextDouble() * 8.0 - 4.0;
    });
  }

  void _startGame() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _playerScore = 0;
      _aiScore = 0;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isPaused) return;
      _updateGame();
    });
  }

  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopGame() {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _resetBall();
    });
  }

  void _updateGame() {
    // Atualiza a posição da bola
    _ballX += _ballSpeedX;
    _ballY += _ballSpeedY;

    // Movimenta a IA
    _moveAI();

    // Verifica colisão com as bordas superior e inferior
    if (_ballY <= -_screenHeight / 2 + ballSize / 2 ||
        _ballY >= _screenHeight / 2 - ballSize / 2) {
      _ballSpeedY = -_ballSpeedY;
    }

    // Verifica colisão com as raquetes - CORRIGIDO
    // Raquete do jogador (lado esquerdo)
    if (_ballSpeedX < 0 && // Bola indo para a esquerda
        _ballX - ballSize / 2 <= -_screenWidth / 2 + paddleWidth &&
        _ballX + ballSize / 2 >= -_screenWidth / 2 &&
        _ballY + ballSize / 2 >= _playerPaddleY - paddleHeight / 2 &&
        _ballY - ballSize / 2 <= _playerPaddleY + paddleHeight / 2) {
      // Colisão com a raquete do jogador
      _ballSpeedX = _ballSpeedX.abs() * 1.05; // Inverte e aumenta velocidade
      _ballX = -_screenWidth / 2 + paddleWidth + ballSize / 2; // Reposiciona a bola

      // Ajusta o ângulo baseado em onde a bola atingiu a raquete
      double relativeIntersectY =
          (_ballY - _playerPaddleY) / (paddleHeight / 2);
      _ballSpeedY += relativeIntersectY * 3.0; // Reduzido de 5.0 para 3.0

      // Limita a velocidade máxima
      _capBallSpeed();
    } 
    // Raquete da IA (lado direito)
    else if (_ballSpeedX > 0 && // Bola indo para a direita
        _ballX + ballSize / 2 >= _screenWidth / 2 - paddleWidth &&
        _ballX - ballSize / 2 <= _screenWidth / 2 &&
        _ballY + ballSize / 2 >= _aiPaddleY - paddleHeight / 2 &&
        _ballY - ballSize / 2 <= _aiPaddleY + paddleHeight / 2) {
      // Colisão com a raquete da IA
      _ballSpeedX = -_ballSpeedX.abs() * 1.05; // Inverte e aumenta velocidade
      _ballX = _screenWidth / 2 - paddleWidth - ballSize / 2; // Reposiciona a bola

      // Ajusta o ângulo baseado em onde a bola atingiu a raquete
      double relativeIntersectY = (_ballY - _aiPaddleY) / (paddleHeight / 2);
      _ballSpeedY += relativeIntersectY * 3.0; // Reduzido de 5.0 para 3.0

      // Limita a velocidade máxima
      _capBallSpeed();
    }

    // Verifica se a bola saiu pelos lados
    if (_ballX < -_screenWidth / 2 - ballSize) {
      // IA marcou ponto
      _aiScore++;
      _resetBall();
      _checkWinner();
    } else if (_ballX > _screenWidth / 2 + ballSize) {
      // Jogador marcou ponto
      _playerScore++;
      _resetBall();
      _checkWinner();
    }

    setState(() {});
  }

  void _moveAI() {
    // IA segue a bola com um atraso para ser mais humano
    if (_ballSpeedX > 0) {
      // Só move se a bola estiver indo em direção à IA
      double targetY = _ballY;
      _aiPaddleY += (targetY - _aiPaddleY) * _aiReactionSpeed;

      // Limita o movimento da IA dentro da tela
      _aiPaddleY = _aiPaddleY.clamp(-_screenHeight / 2 + paddleHeight / 2,
          _screenHeight / 2 - paddleHeight / 2);
    }
  }

  void _capBallSpeed() {
    // Limita a velocidade máxima da bola
    if (_ballSpeedX.abs() > _maxBallSpeed) {
      _ballSpeedX = _maxBallSpeed * (_ballSpeedX > 0 ? 1 : -1);
    }
    if (_ballSpeedY.abs() > _maxBallSpeed) {
      _ballSpeedY = _maxBallSpeed * (_ballSpeedY > 0 ? 1 : -1);
    }
  }

  void _checkWinner() {
    if (_playerScore >= 10 || _aiScore >= 10) {
      _stopGame();
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fim de Jogo'),
          content: Text(
            _playerScore > _aiScore
                ? 'Você venceu! $_playerScore x $_aiScore'
                : 'Você perdeu! $_playerScore x $_aiScore',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('Jogar Novamente'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _screenWidth = constraints.maxWidth;
          _screenHeight = constraints.maxHeight;

          return GestureDetector(
            onVerticalDragUpdate: (details) {
              if (!_isPlaying || _isPaused) return;

              setState(() {
                _playerPaddleY += details.delta.dy;
                // Limita o movimento do jogador dentro da tela
                _playerPaddleY = _playerPaddleY.clamp(
                    -_screenHeight / 2 + paddleHeight / 2,
                    _screenHeight / 2 - paddleHeight / 2);
              });
            },
            child: Stack(
              children: [
                // Área do jogo
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: CustomPaint(
                    painter: PingPongPainter(
                      ballX: _ballX,
                      ballY: _ballY,
                      playerPaddleY: _playerPaddleY,
                      aiPaddleY: _aiPaddleY,
                      screenWidth: _screenWidth,
                      screenHeight: _screenHeight,
                    ),
                  ),
                ),

                // Barra central tracejada
                Center(
                  child: Container(
                    width: 2,
                    height: _screenHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),

                // Pontuação
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_playerScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                      Text(
                        '$_aiScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botões de controle
                if (!_isPlaying)
                  Center(
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Iniciar Jogo',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                // Botões na tela durante o jogo
                if (_isPlaying)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Row(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          onPressed: _pauseGame,
                          child:
                              Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          mini: true,
                          onPressed: _stopGame,
                          child: const Icon(Icons.stop),
                        ),
                      ],
                    ),
                  ),

                // Overlay de pausa
                if (_isPaused && _isPlaying)
                  Container(
                    color: Colors.black54,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: Text(
                        'PAUSADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PingPongPainter extends CustomPainter {
  final double ballX;
  final double ballY;
  final double playerPaddleY;
  final double aiPaddleY;
  final double screenWidth;
  final double screenHeight;

  const PingPongPainter({
    required this.ballX,
    required this.ballY,
    required this.playerPaddleY,
    required this.aiPaddleY,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Converte coordenadas para o sistema de coordenadas centralizado
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // Pinta a bola
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(centerX + ballX, centerY + ballY),
      10,
      ballPaint,
    );

    // Pinta a raquete do jogador
    final paddlePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          centerX - screenWidth / 2 + 16, // Posição X da raquete do jogador
          centerY + playerPaddleY,
        ),
        width: 16,
        height: 100,
      ),
      paddlePaint,
    );

    // Pinta a raquete da IA
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          centerX + screenWidth / 2 - 16, // Posição X da raquete da IA
          centerY + aiPaddleY,
        ),
        width: 16,
        height: 100,
      ),
      paddlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PingPongPainter oldDelegate) {
    return oldDelegate.ballX != ballX ||
        oldDelegate.ballY != ballY ||
        oldDelegate.playerPaddleY != playerPaddleY ||
        oldDelegate.aiPaddleY != aiPaddleY;
  }
}
