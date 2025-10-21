/// Widget canvas principal do jogo Ping Pong
/// 
/// Renderiza os elementos visuais do jogo incluindo bola, raquetes,
/// campo de jogo e efeitos visuais.
library;

// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';

/// Canvas principal onde o jogo é renderizado
class GameCanvas extends StatefulWidget {
  /// Estado do jogo
  final PingPongGameState gameState;
  
  /// Callback para gestos de movimento
  final Function(double deltaY)? onPaddleMove;
  
  /// Configurações visuais
  final GameVisualConfig visualConfig;
  
  /// Indica se deve mostrar informações de debug
  final bool showDebugInfo;
  
  const GameCanvas({
    super.key,
    required this.gameState,
    this.onPaddleMove,
    this.visualConfig = const GameVisualConfig(),
    this.showDebugInfo = false,
  });
  
  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> 
    with TickerProviderStateMixin {
  
  /// Controlador de animação para efeitos
  late AnimationController _effectsController;
  late Animation<double> _effectsAnimation;
  
  /// Controlador para trail da bola
  late AnimationController _trailController;
  
  /// Posições históricas da bola para trail
  final List<BallTrailPoint> _ballTrail = [];
  
  /// Efeitos visuais ativos
  final List<VisualEffect> _activeEffects = [];
  
  @override
  void initState() {
    super.initState();
    
    // Controlador para efeitos gerais
    _effectsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _effectsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _effectsController,
      curve: Curves.easeInOut,
    ));
    
    // Controlador para trail da bola
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
    
    // Escuta mudanças no estado do jogo
    widget.gameState.addListener(_onGameStateChanged);
  }
  
  @override
  void dispose() {
    _effectsController.dispose();
    _trailController.dispose();
    widget.gameState.removeListener(_onGameStateChanged);
    super.dispose();
  }
  
  /// Callback quando estado do jogo muda
  void _onGameStateChanged() {
    if (mounted) {
      setState(() {
        _updateBallTrail();
        _updateVisualEffects();
      });
    }
  }
  
  /// Atualiza trail da bola
  void _updateBallTrail() {
    if (!widget.visualConfig.showBallTrail) return;
    
    final ball = widget.gameState.ball;
    
    // Adiciona ponto atual
    _ballTrail.add(BallTrailPoint(
      x: ball.x,
      y: ball.y,
      timestamp: DateTime.now(),
      speed: ball.currentSpeed,
    ));
    
    // Remove pontos antigos
    final cutoff = DateTime.now().subtract(const Duration(milliseconds: 500));
    _ballTrail.removeWhere((point) => point.timestamp.isBefore(cutoff));
    
    // Limita tamanho
    if (_ballTrail.length > 20) {
      _ballTrail.removeAt(0);
    }
  }
  
  /// Atualiza efeitos visuais
  void _updateVisualEffects() {
    final now = DateTime.now();
    
    // Remove efeitos expirados
    _activeEffects.removeWhere((effect) => 
        now.difference(effect.startTime) >= effect.duration);
  }
  
  /// Adiciona efeito visual
  void _addVisualEffect(VisualEffect effect) {
    _activeEffects.add(effect);
    _effectsController.forward().then((_) {
      _effectsController.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.onPaddleMove != null ? (details) {
        widget.onPaddleMove!(details.delta.dy);
      } : null,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: widget.visualConfig.backgroundColor,
        child: CustomPaint(
          painter: PingPongPainter(
            gameState: widget.gameState,
            visualConfig: widget.visualConfig,
            ballTrail: _ballTrail,
            activeEffects: _activeEffects,
            effectsAnimation: _effectsAnimation.value,
            showDebugInfo: widget.showDebugInfo,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Painter customizado para renderizar o jogo
class PingPongPainter extends CustomPainter {
  final PingPongGameState gameState;
  final GameVisualConfig visualConfig;
  final List<BallTrailPoint> ballTrail;
  final List<VisualEffect> activeEffects;
  final double effectsAnimation;
  final bool showDebugInfo;
  
  const PingPongPainter({
    required this.gameState,
    required this.visualConfig,
    required this.ballTrail,
    required this.activeEffects,
    required this.effectsAnimation,
    required this.showDebugInfo,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Pinta fundo com gradiente se habilitado
    if (visualConfig.showBackgroundGradient) {
      _paintBackground(canvas, size);
    }
    
    // Pinta linhas do campo
    _paintFieldLines(canvas, size, centerX, centerY);
    
    // Pinta trail da bola
    if (visualConfig.showBallTrail && ballTrail.isNotEmpty) {
      _paintBallTrail(canvas, centerX, centerY);
    }
    
    // Pinta bola
    _paintBall(canvas, centerX, centerY);
    
    // Pinta raquetes
    _paintPaddles(canvas, size, centerX, centerY);
    
    // Pinta efeitos visuais
    _paintVisualEffects(canvas, centerX, centerY);
    
    // Pinta informações de debug
    if (showDebugInfo) {
      _paintDebugInfo(canvas, size);
    }
  }
  
  /// Pinta fundo com gradiente
  void _paintBackground(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        visualConfig.backgroundColor,
        visualConfig.backgroundColor.withValues(alpha: 0.8),
        visualConfig.backgroundColor.withValues(alpha: 0.9),
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    
    canvas.drawRect(rect, paint);
  }
  
  /// Pinta linhas do campo
  void _paintFieldLines(Canvas canvas, Size size, double centerX, double centerY) {
    final linePaint = Paint()
      ..color = visualConfig.fieldLineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Linha central
    if (visualConfig.showCenterLine) {
      _paintDashedLine(
        canvas,
        Offset(centerX, 0),
        Offset(centerX, size.height),
        linePaint,
        dashLength: 10.0,
        dashSpace: 5.0,
      );
    }
    
    // Bordas do campo
    if (visualConfig.showFieldBorders) {
      final borderPaint = Paint()
        ..color = visualConfig.fieldLineColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        borderPaint,
      );
    }
  }
  
  /// Pinta linha tracejada
  void _paintDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    {required double dashLength, required double dashSpace}
  ) {
    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashLength + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startRatio = (i * (dashLength + dashSpace)) / totalDistance;
      final endRatio = ((i * (dashLength + dashSpace)) + dashLength) / totalDistance;
      
      final dashStart = Offset.lerp(start, end, startRatio)!;
      final dashEnd = Offset.lerp(start, end, endRatio)!;
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }
  
  /// Pinta trail da bola
  void _paintBallTrail(Canvas canvas, double centerX, double centerY) {
    if (ballTrail.length < 2) return;
    
    final path = Path();
    bool first = true;
    
    for (int i = 0; i < ballTrail.length; i++) {
      final point = ballTrail[i];
      final screenPos = Offset(
        centerX + point.x,
        centerY + point.y,
      );
      
      if (first) {
        path.moveTo(screenPos.dx, screenPos.dy);
        first = false;
      } else {
        path.lineTo(screenPos.dx, screenPos.dy);
      }
    }
    
    final trailPaint = Paint()
      ..color = visualConfig.ballTrailColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, trailPaint);
    
    // Pinta pontos do trail com opacidade decrescente
    for (int i = 0; i < ballTrail.length; i++) {
      final point = ballTrail[i];
      final opacity = (i / ballTrail.length);
      final size = 2.0 + (point.speed / 5.0);
      
      final pointPaint = Paint()
        ..color = visualConfig.ballTrailColor.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX + point.x, centerY + point.y),
        size,
        pointPaint,
      );
    }
  }
  
  /// Pinta a bola
  void _paintBall(Canvas canvas, double centerX, double centerY) {
    final ball = gameState.ball;
    final ballCenter = Offset(centerX + ball.x, centerY + ball.y);
    
    // Efeito de brilho baseado na velocidade
    final glowIntensity = (ball.currentSpeed / 10.0).clamp(0.0, 1.0);
    
    if (visualConfig.showBallGlow && glowIntensity > 0.3) {
      final glowPaint = Paint()
        ..color = visualConfig.ballColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      
      canvas.drawCircle(
        ballCenter,
        GameConfig.ballRadius * (1.0 + glowIntensity * 0.5),
        glowPaint,
      );
    }
    
    // Bola principal
    final ballPaint = Paint()
      ..color = visualConfig.ballColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(ballCenter, GameConfig.ballRadius, ballPaint);
    
    // Highlight na bola
    if (visualConfig.showBallHighlight) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        ballCenter + const Offset(-3, -3),
        GameConfig.ballRadius * 0.3,
        highlightPaint,
      );
    }
  }
  
  /// Pinta as raquetes
  void _paintPaddles(Canvas canvas, Size size, double centerX, double centerY) {
    _paintPaddle(canvas, gameState.playerPaddle, centerX, centerY, true);
    _paintPaddle(canvas, gameState.aiPaddle, centerX, centerY, false);
  }
  
  /// Pinta uma raquete específica
  void _paintPaddle(
    Canvas canvas,
    Paddle paddle,
    double centerX,
    double centerY,
    bool isPlayer,
  ) {
    final paddleCenter = Offset(
      centerX + paddle.x,
      centerY + paddle.y,
    );
    
    // Cor da raquete
    Color paddleColor = isPlayer ? 
        visualConfig.playerPaddleColor : 
        visualConfig.aiPaddleColor;
    
    // Efeito de movimento
    if (visualConfig.showPaddleMotion && paddle.velocity.abs() > 2.0) {
      final motionIntensity = (paddle.velocity.abs() / 10.0).clamp(0.0, 1.0);
      paddleColor = Color.lerp(
        paddleColor,
        Colors.white,
        motionIntensity * 0.3,
      )!;
    }
    
    final paddlePaint = Paint()
      ..color = paddleColor
      ..style = PaintingStyle.fill;
    
    // Raquete principal
    final paddleRect = Rect.fromCenter(
      center: paddleCenter,
      width: paddle.width,
      height: paddle.height,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(paddleRect, const Radius.circular(8.0)),
      paddlePaint,
    );
    
    // Destaque na raquete
    if (visualConfig.showPaddleHighlight) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      
      final highlightRect = Rect.fromCenter(
        center: paddleCenter + const Offset(2, 0),
        width: paddle.width * 0.3,
        height: paddle.height * 0.8,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(highlightRect, const Radius.circular(4.0)),
        highlightPaint,
      );
    }
  }
  
  /// Pinta efeitos visuais ativos
  void _paintVisualEffects(Canvas canvas, double centerX, double centerY) {
    for (final effect in activeEffects) {
      _paintVisualEffect(canvas, effect, centerX, centerY);
    }
  }
  
  /// Pinta um efeito visual específico
  void _paintVisualEffect(
    Canvas canvas,
    VisualEffect effect,
    double centerX,
    double centerY,
  ) {
    final elapsed = DateTime.now().difference(effect.startTime);
    final progress = (elapsed.inMilliseconds / effect.duration.inMilliseconds)
        .clamp(0.0, 1.0);
    
    switch (effect.type) {
      case EffectType.impact:
        _paintImpactEffect(canvas, effect, centerX, centerY, progress);
        break;
      case EffectType.score:
        _paintScoreEffect(canvas, effect, centerX, centerY, progress);
        break;
      case EffectType.powerUp:
        _paintPowerUpEffect(canvas, effect, centerX, centerY, progress);
        break;
    }
  }
  
  /// Pinta efeito de impacto
  void _paintImpactEffect(
    Canvas canvas,
    VisualEffect effect,
    double centerX,
    double centerY,
    double progress,
  ) {
    final center = Offset(centerX + effect.x, centerY + effect.y);
    final radius = 10.0 + (progress * 30.0);
    final opacity = 1.0 - progress;
    
    final impactPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawCircle(center, radius, impactPaint);
  }
  
  /// Pinta efeito de pontuação
  void _paintScoreEffect(
    Canvas canvas,
    VisualEffect effect,
    double centerX,
    double centerY,
    double progress,
  ) {
    final center = Offset(centerX + effect.x, centerY + effect.y);
    final scale = 1.0 + (progress * 2.0);
    final opacity = 1.0 - progress;
    
    final scorePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    
    // Estrela simples
    final starPath = _createStarPath(center, 15.0 * scale, 5);
    canvas.drawPath(starPath, scorePaint);
  }
  
  /// Pinta efeito de power-up
  void _paintPowerUpEffect(
    Canvas canvas,
    VisualEffect effect,
    double centerX,
    double centerY,
    double progress,
  ) {
    final center = Offset(centerX + effect.x, centerY + effect.y);
    final rotation = progress * 2 * math.pi;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    final powerUpPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Hexágono rotativo
    final hexPath = _createHexagonPath(20.0);
    canvas.drawPath(hexPath, powerUpPaint);
    
    canvas.restore();
  }
  
  /// Cria path de estrela
  Path _createStarPath(Offset center, double radius, int points) {
    final path = Path();
    final angleStep = (2 * math.pi) / points;
    final innerRadius = radius * 0.5;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = i * angleStep / 2;
      final currentRadius = i.isEven ? radius : innerRadius;
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }
  
  /// Cria path de hexágono
  Path _createHexagonPath(double radius) {
    final path = Path();
    
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }
  
  /// Pinta informações de debug
  void _paintDebugInfo(Canvas canvas, Size size) {
    final debugPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final ball = gameState.ball;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Informações da bola
    textPainter.text = TextSpan(
      text: 'Ball: (${ball.x.toStringAsFixed(1)}, ${ball.y.toStringAsFixed(1)}) '
            'Speed: ${ball.currentSpeed.toStringAsFixed(1)}',
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
    
    // Caixas de colisão
    final ballRect = Rect.fromCenter(
      center: Offset(size.width / 2 + ball.x, size.height / 2 + ball.y),
      width: GameConfig.ballSize,
      height: GameConfig.ballSize,
    );
    canvas.drawRect(ballRect, debugPaint);
  }
  
  @override
  bool shouldRepaint(covariant PingPongPainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
           oldDelegate.effectsAnimation != effectsAnimation ||
           oldDelegate.ballTrail.length != ballTrail.length ||
           oldDelegate.activeEffects.length != activeEffects.length;
  }
}

/// Configurações visuais do jogo
class GameVisualConfig {
  final Color backgroundColor;
  final Color ballColor;
  final Color playerPaddleColor;
  final Color aiPaddleColor;
  final Color fieldLineColor;
  final Color ballTrailColor;
  
  final bool showCenterLine;
  final bool showFieldBorders;
  final bool showBallTrail;
  final bool showBallGlow;
  final bool showBallHighlight;
  final bool showPaddleHighlight;
  final bool showPaddleMotion;
  final bool showBackgroundGradient;
  
  const GameVisualConfig({
    this.backgroundColor = Colors.black,
    this.ballColor = Colors.white,
    this.playerPaddleColor = Colors.white,
    this.aiPaddleColor = Colors.white,
    this.fieldLineColor = Colors.white,
    this.ballTrailColor = Colors.cyan,
    this.showCenterLine = true,
    this.showFieldBorders = false,
    this.showBallTrail = true,
    this.showBallGlow = true,
    this.showBallHighlight = true,
    this.showPaddleHighlight = true,
    this.showPaddleMotion = true,
    this.showBackgroundGradient = false,
  });
}

/// Ponto do trail da bola
class BallTrailPoint {
  final double x;
  final double y;
  final DateTime timestamp;
  final double speed;
  
  BallTrailPoint({
    required this.x,
    required this.y,
    required this.timestamp,
    required this.speed,
  });
}

/// Efeito visual
class VisualEffect {
  final EffectType type;
  final double x;
  final double y;
  final DateTime startTime;
  final Duration duration;
  final Map<String, dynamic> properties;
  
  VisualEffect({
    required this.type,
    required this.x,
    required this.y,
    required this.startTime,
    required this.duration,
    this.properties = const {},
  });
}

/// Tipos de efeito visual
enum EffectType {
  impact,
  score,
  powerUp,
}
