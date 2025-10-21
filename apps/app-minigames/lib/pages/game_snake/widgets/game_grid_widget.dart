// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';

/**
 * FIXME (prioridade: MÉDIA): GridView pode ter performance ruim com grids 
 * grandes - considerar ListView.builder customizado
 * 
 * TODO (prioridade: ALTA): Adicionar animações para movimento da cobra e 
 * spawn de comida
 * 
 * TODO (prioridade: MÉDIA): Implementar diferentes visuais para tipos de 
 * comida
 * 
 * TODO (prioridade: MÉDIA): Adicionar efeitos visuais para power-ups
 * 
 * TODO (prioridade: BAIXA): Adicionar tema escuro/claro configurável
 * 
 * REFACTOR (prioridade: MÉDIA): Separar builders de células em métodos 
 * privados ou widgets separados
 * 
 * REFACTOR (prioridade: BAIXA): Usar Theme colors em vez de cores hardcoded
 * 
 * OPTIMIZE (prioridade: ALTA): Usar RepaintBoundary para otimizar repaints
 * 
 * OPTIMIZE (prioridade: MÉDIA): Implementar shouldRepaint personalizado
 * 
 * STYLE (prioridade: MÉDIA): Adicionar sombras e gradientes para melhor 
 * visual
 * 
 * STYLE (prioridade: BAIXA): Implementar diferentes shapes para elementos 
 * do jogo
 * 
 * TEST (prioridade: MÉDIA): Adicionar testes de widget para renderização
 */

class GameGridWidget extends StatefulWidget {
  final SnakeGameLogic gameLogic;
  final Function(Direction)? onSwipe;
  final bool swipeEnabled;

  const GameGridWidget({
    super.key,
    required this.gameLogic,
    this.onSwipe,
    this.swipeEnabled = true,
  });

  @override
  State<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends State<GameGridWidget>
    with TickerProviderStateMixin {
  late AnimationController _foodAnimationController;
  late Animation<double> _foodScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animação de scaling para comida
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _foodScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _foodAnimationController,
      curve: Curves.easeInOut,
    ));

    // Inicia animação de pulso da comida
    _foodAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _foodAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget gridWidget = AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 6,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: RepaintBoundary(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.gameLogic.gridSize,
            ),
            itemCount: widget.gameLogic.gridSize * widget.gameLogic.gridSize,
            itemBuilder: (context, index) {
              final x = index % widget.gameLogic.gridSize;
              final y = index ~/ widget.gameLogic.gridSize;

              // Verifica se é a cabeça da cobra
              if (widget.gameLogic.isSnakeHead(x, y)) {
                return RepaintBoundary(child: _buildHeadCell());
              }

              // Verifica se é parte do corpo da cobra
              if (widget.gameLogic.isSnake(x, y)) {
                return RepaintBoundary(child: _buildBodyCell());
              }

              // Verifica se é comida
              if (widget.gameLogic.isGameStarted && widget.gameLogic.isFood(x, y)) {
                return RepaintBoundary(child: _buildAnimatedFoodCell(widget.gameLogic.currentFoodType));
              }

              // Célula vazia
              return RepaintBoundary(child: _buildEmptyCell());
            },
          ),
        ),
      ),
    );

    // Envolver com GestureDetector se swipe estiver habilitado
    if (widget.swipeEnabled && widget.onSwipe != null) {
      return _SwipeDetector(
        onSwipe: widget.onSwipe!,
        child: gridWidget,
      );
    }

    return gridWidget;
  }

  Widget _buildHeadCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [
            Color(0xFF4CAF50), // Verde mais claro no centro
            GameColors.snakeHead, // Verde original na borda
          ],
          stops: [0.3, 1.0],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: GameColors.snakeHead.withValues(alpha: 0.6),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8BC34A), // Verde mais claro
            GameColors.snakeBody, // Verde original
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        boxShadow: [
          BoxShadow(
            color: GameColors.snakeBody.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8F8F8),
            GameColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
    );
  }
  
  Widget _buildAnimatedFoodCell(FoodType foodType) {
    return AnimatedBuilder(
      animation: _foodScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _foodScaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  foodType.color.withValues(alpha: 0.7), // Cor mais clara no centro
                  foodType.color, // Cor original na borda
                ],
                stops: const [0.4, 1.0],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: foodType.color.withValues(alpha: 0.8),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
                BoxShadow(
                  color: foodType.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                foodType.icon,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget especializado para detectar gestos de swipe nas 4 direções
class _SwipeDetector extends StatefulWidget {
  final Function(Direction) onSwipe;
  final Widget child;

  const _SwipeDetector({
    required this.onSwipe,
    required this.child,
  });

  @override
  State<_SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<_SwipeDetector> {
  static const double _swipeThreshold = 30.0; // Distância mínima para swipe
  static const double _velocityThreshold = 200.0; // Velocidade mínima
  
  Offset? _startPosition;
  DateTime? _startTime;
  bool _hasTriggered = false; // Evita múltiplos triggers no mesmo gesto

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _startTime = DateTime.now();
    _hasTriggered = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_hasTriggered || _startPosition == null || _startTime == null) return;

    final currentPosition = details.localPosition;
    final delta = currentPosition - _startPosition!;
    final distance = delta.distance;

    // Só processa se passou do threshold mínimo
    if (distance < _swipeThreshold) return;

    // Calcula velocidade
    final elapsed = DateTime.now().difference(_startTime!);
    final velocity = distance / elapsed.inMilliseconds * 1000; // pixels/segundo

    // Verifica se a velocidade é suficiente
    if (velocity < _velocityThreshold) return;

    // Determina direção baseada no maior componente do movimento
    Direction? direction;
    
    if (delta.dx.abs() > delta.dy.abs()) {
      // Movimento horizontal predomina
      direction = delta.dx > 0 ? Direction.right : Direction.left;
    } else {
      // Movimento vertical predomina  
      direction = delta.dy > 0 ? Direction.down : Direction.up;
    }

    // Executa callback e marca como triggered
    widget.onSwipe(direction);
    _hasTriggered = true;
  }

  void _onPanEnd(DragEndDetails details) {
    _startPosition = null;
    _startTime = null;
    _hasTriggered = false;
  }
}
