import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cell_data.dart';
import '../providers/campo_minado_game_notifier.dart';

/// Individual cell widget in the minefield
class CellWidget extends ConsumerStatefulWidget {
  final CellData cell;
  final double size;
  final bool isPaused;

  const CellWidget({
    super.key,
    required this.cell,
    required this.size,
    required this.isPaused,
  });

  @override
  ConsumerState<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends ConsumerState<CellWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(campoMinadoGameProvider.notifier);

    return GestureDetector(
      // Single tap: reveal cell
      onTap: widget.isPaused
          ? null
          : () {
              notifier.revealCell(widget.cell.row, widget.cell.col);
            },

      // Long press: toggle flag
      onLongPress: widget.isPaused
          ? null
          : () {
              notifier.toggleFlag(widget.cell.row, widget.cell.col);
            },

      // Double tap: chord click
      onDoubleTap: widget.isPaused
          ? null
          : () {
              notifier.chordClick(widget.cell.row, widget.cell.col);
            },

      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),

      child: Container(
        width: widget.size,
        height: widget.size,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
          boxShadow: widget.cell.isRevealed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.1 : 0.3),
                    offset: Offset(_isPressed ? 1 : 2, _isPressed ? 1 : 2),
                  ),
                ],
        ),
        child: Center(
          child: widget.isPaused && !widget.cell.isRevealed
              ? const Icon(Icons.question_mark, size: 16, color: Colors.grey)
              : _buildCellContent(),
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    final text = widget.cell.displayText;

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if it's an emoji (mine, explosion, flag)
    if (text == '💣' || text == '💥' || text == '🚩' || text == '?') {
      return Text(
        text,
        style: TextStyle(
          fontSize: widget.size * 0.6,
        ),
      );
    }

    // Number
    return Text(
      text,
      style: TextStyle(
        fontSize: widget.size * 0.6,
        fontWeight: FontWeight.bold,
        color: _getNumberColor(widget.cell.colorIndex),
      ),
    );
  }

  Color _getCellColor() {
    if (widget.cell.isExploded) {
      return Colors.red;
    }

    if (widget.cell.isRevealed) {
      return const Color(0xFFE0E0E0);
    }

    if (widget.cell.isFlagged) {
      return Colors.orange[100]!;
    }

    if (widget.cell.isQuestioned) {
      return Colors.yellow[100]!;
    }

    return const Color(0xFFBDBDBD);
  }

  Color _getBorderColor() {
    if (widget.cell.isRevealed) {
      return Colors.grey[400]!;
    }
    return Colors.grey[600]!;
  }

  Color _getNumberColor(int count) {
    const colors = [
      Colors.transparent, // 0
      Color(0xFF1976D2), // 1 - blue
      Color(0xFF388E3C), // 2 - green
      Color(0xFFD32F2F), // 3 - red
      Color(0xFF7B1FA2), // 4 - purple
      Color(0xFF795548), // 5 - brown
      Color(0xFF00796B), // 6 - teal
      Color(0xFF424242), // 7 - grey
      Color(0xFF000000), // 8 - black
    ];

    if (count >= 0 && count < colors.length) {
      return colors[count];
    }
    return Colors.black;
  }
}
