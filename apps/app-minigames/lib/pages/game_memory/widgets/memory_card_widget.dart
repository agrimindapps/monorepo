// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/memory_card.dart';

class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final double size;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.size,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start animation when card state changes
    if (oldWidget.card.state != widget.card.state) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final value = _animation.value;
          final isFlipped = value < -0.25; // Ponto médio da animação
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(value * 3.14);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(4),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: isFlipped ? _getCardColor() : Colors.blue,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isFlipped
                  ? (_isCardHidden() ? null : _buildCardContent())
                  : const Center(
                      child: Icon(
                        Icons.question_mark,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  // Verifica se o cartão está virado para baixo
  bool _isCardHidden() {
    return widget.card.state == CardState.hidden;
  }

  // Método para obter a cor do cartão com base no estado
  Color _getCardColor() {
    switch (widget.card.state) {
      case CardState.hidden:
        return Colors.blue;
      case CardState.revealed:
        return widget.card.color;
      case CardState.matched:
        return widget.card.color.withValues(alpha: 0.7);
    }
  }

  // Método para construir o conteúdo do cartão com base no estado
  Widget _buildCardContent() {
    switch (widget.card.state) {
      case CardState.hidden:
        return const Center(
          child: Icon(
            Icons.question_mark,
            color: Colors.white,
            size: 30,
          ),
        );
      case CardState.revealed:
      case CardState.matched:
        return Center(
          child: Icon(
            widget.card.icon,
            color: Colors.white,
            size: 30,
          ),
        );
    }
  }
}
