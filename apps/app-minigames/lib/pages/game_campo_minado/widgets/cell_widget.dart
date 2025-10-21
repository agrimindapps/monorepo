// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart' as constants;
import 'package:app_minigames/models/cell.dart';

/// Widget representing a single cell in the minesweeper grid
class CellWidget extends StatefulWidget {
  final Cell cell;
  final bool isGameOver;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const CellWidget({
    super.key,
    required this.cell,
    this.isGameOver = false,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: constants.Timing.cellRevealAnimationDuration),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: constants.Animation.cellPressScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: constants.Animation.mineExplosionRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when cell is revealed
    if (!oldWidget.cell.isRevealed && widget.cell.isRevealed) {
      _animationController.forward();
    }
    
    // Animate explosion for mines
    if (widget.cell.isMine && widget.cell.isExploded && widget.isGameOver) {
      _animationController.forward();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isGameOver && !widget.cell.isRevealed) {
      setState(() {
        _isPressed = true;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTap() {
    if (!widget.isGameOver) {
      widget.onTap?.call();
      HapticFeedback.selectionClick();
    }
  }

  void _handleLongPress() {
    if (!widget.isGameOver) {
      widget.onLongPress?.call();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleDoubleTap() {
    if (!widget.isGameOver && widget.cell.isRevealed) {
      widget.onDoubleTap?.call();
      HapticFeedback.lightImpact();
    }
  }

  Color _getCellBackgroundColor() {
    if (widget.cell.isRevealed) {
      if (widget.cell.isMine) {
        return widget.cell.isExploded ? GameColors.cellMine : GameColors.cellRevealed;
      }
      return GameColors.cellRevealed;
    }
    
    if (widget.cell.isFlagged) {
      return GameColors.cellFlag.withValues(alpha: 0.3);
    }
    
    if (widget.cell.isQuestioned) {
      return GameColors.cellQuestion.withValues(alpha: 0.3);
    }
    
    return _isPressed ? GameColors.cellRevealed : GameColors.cellHidden;
  }

  Color _getTextColor() {
    if (widget.cell.isFlagged) return GameColors.cellFlag;
    if (widget.cell.isQuestioned) return GameColors.cellQuestion;
    if (widget.cell.isMine && widget.cell.isRevealed) return Colors.black;
    
    return GameColors.getNumberColor(widget.cell.colorIndex);
  }

  Widget _buildCellContent() {
    final text = widget.cell.displayText;
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: TextStyle(
        fontSize: GameSizes.cellFontSize,
        fontWeight: FontWeight.bold,
        color: _getTextColor(),
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onDoubleTap: _handleDoubleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? constants.Animation.cellPressScale : _scaleAnimation.value,
            child: Transform.rotate(
              angle: widget.cell.isMine && widget.cell.isExploded 
                  ? _rotationAnimation.value 
                  : 0.0,
              child: Container(
                width: GameSizes.cellSize,
                height: GameSizes.cellSize,
                margin: const EdgeInsets.all(GameSizes.cellPadding),
                decoration: BoxDecoration(
                  color: _getCellBackgroundColor(),
                  borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
                  border: Border.all(
                    color: widget.cell.isRevealed 
                        ? Colors.grey[400]! 
                        : Colors.grey[600]!,
                    width: constants.Layout.cellBorderWidth,
                  ),
                  boxShadow: [
                    if (!widget.cell.isRevealed || widget.cell.isMine)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: constants.VisualFeedback.shadowOpacity),
                        blurRadius: constants.VisualFeedback.cellShadowBlur,
                        offset: const Offset(
                          constants.VisualFeedback.cellShadowOffsetX,
                          constants.VisualFeedback.cellShadowOffsetY,
                        ),
                      ),
                  ],
                ),
                child: Center(
                  child: RepaintBoundary(
                    child: _buildCellContent(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
