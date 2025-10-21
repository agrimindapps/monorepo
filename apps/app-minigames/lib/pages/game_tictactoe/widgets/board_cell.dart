// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_theme.dart';

class BoardCell extends StatefulWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool isWinningCell;
  final int row;
  final int col;

  const BoardCell({
    super.key,
    required this.player,
    this.onTap,
    this.isWinningCell = false,
    required this.row,
    required this.col,
  });
  
  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> 
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;
  
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _getCellLabel(),
      hint: _getCellHint(),
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovering = true);
          if (widget.onTap != null) {
            _scaleController.forward();
          }
        },
        onExit: (_) {
          setState(() => _isHovering = false);
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _getCellColor(),
                    border: Border.all(
                      color: _getBorderColor(),
                      width: _isHovering && widget.onTap != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: RotationTransition(
                            turns: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _buildCellContent(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Color _getCellColor() {
    if (widget.isWinningCell) {
      return widget.player.color.withValues(alpha: 0.3);
    } else if (_isHovering && widget.onTap != null) {
      return Colors.blue.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }
  
  Color _getBorderColor() {
    if (_isHovering && widget.onTap != null) {
      return Colors.blue.withValues(alpha: 0.5);
    }
    return Colors.grey;
  }

  Widget _buildCellContent() {
    if (widget.player == Player.none) {
      return const SizedBox();
    }

    return Container(
      key: ValueKey(widget.player),
      decoration: widget.isWinningCell
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          )
        : null,
      child: Center(
        child: Text(
          widget.player.symbol,
          style: TextStyle(
            fontSize: GameTheme.getFontSize(context, 40),
            fontWeight: FontWeight.bold,
            color: widget.isWinningCell 
              ? Colors.white
              : widget.player.color,
          ),
        ),
      ),
    );
  }
  
  String _getCellLabel() {
    final position = _getPositionDescription();
    
    switch (widget.player) {
      case Player.x:
        return 'X em $position';
      case Player.o:
        return 'O em $position';
      case Player.none:
        return 'Célula vazia em $position';
    }
  }

  String _getPositionDescription() {
    final rowNames = ['primeira linha', 'segunda linha', 'terceira linha'];
    final colNames = ['primeira coluna', 'segunda coluna', 'terceira coluna'];
    return '${rowNames[widget.row]}, ${colNames[widget.col]}';
  }

  String _getCellHint() {
    if (widget.onTap != null && widget.player == Player.none) {
      return 'Toque duplo para jogar nesta posição';
    } else if (widget.isWinningCell) {
      return 'Posição vencedora';
    }
    return '';
  }
}
