import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
import '../../domain/entities/tetromino.dart';
import '../providers/tetris_controller.dart';
import 'tetris_high_scores_page.dart';
import 'tetris_settings_page.dart';

class TetrisPage extends ConsumerStatefulWidget {
  const TetrisPage({super.key});

  @override
  ConsumerState<TetrisPage> createState() => _TetrisPageState();
}

class _TetrisPageState extends ConsumerState<TetrisPage> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tetrisControllerProvider.notifier).startGame();
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    
    final controller = ref.read(tetrisControllerProvider.notifier);
    
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        controller.moveLeft();
        break;
      case LogicalKeyboardKey.arrowRight:
        controller.moveRight();
        break;
      case LogicalKeyboardKey.arrowDown:
        controller.softDrop();
        break;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyX:
        controller.rotate();
        break;
      case LogicalKeyboardKey.space:
        controller.hardDrop();
        break;
      case LogicalKeyboardKey.keyP:
        controller.togglePause();
        break;
      case LogicalKeyboardKey.keyR:
        controller.restart();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tetrisControllerProvider);


    return EscKeyboardWrapper(
      onEscPressed: () {
        ref.read(tetrisControllerProvider.notifier).togglePause();
      },
      child: GamePageLayout(
        title: 'Tetris',
        accentColor: const Color(0xFF9C27B0),
        instructions: 'Use as setas ou botões para controlar.\n\n'
            '⬅️➡️ Mover\n'
            '⬆️ Rotacionar\n'
            '⬇️ Descer rápido\n'
            '⏬ Hard drop',
        maxGameWidth: 450,
        actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events, color: Colors.amber),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TetrisHighScoresPage(),
              ),
            );
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TetrisSettingsPage(),
              ),
            );
          },
          tooltip: 'Configurações',
        ),
        IconButton(
          icon: Icon(
            state.isPaused ? Icons.play_arrow : Icons.pause,
            color: Colors.white,
          ),
          onPressed: () => ref.read(tetrisControllerProvider.notifier).togglePause(),
          tooltip: state.isPaused ? 'Retomar' : 'Pausar',
        ),
      ],
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score and info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard('Score', state.score.toString()),
                  _buildInfoCard('Lines', state.lines.toString()),
                  _buildInfoCard('Level', state.level.toString()),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Game area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game board
                  _buildGameBoard(state),
                  
                  const SizedBox(width: 16),
                  
                  // Next piece
                  Column(
                    children: [
                      const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNextPiece(state.nextPiece),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Controls
              _buildControls(),
            ],
          ),
        ),
      ),
      ),
    );
  }
  
  Widget _buildInfoCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameBoard(TetrisState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = 18.0;
        
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Board grid
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(TetrisState.boardHeight, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(TetrisState.boardWidth, (col) {
                      Color? cellColor = state.board[row][col];
                      
                      // Draw current piece
                      if (state.currentPiece != null && cellColor == null) {
                        final piece = state.currentPiece!;
                        final pieceRow = row - piece.y;
                        final pieceCol = col - piece.x;
                        
                        if (pieceRow >= 0 && pieceRow < piece.shape.length &&
                            pieceCol >= 0 && pieceCol < piece.shape[pieceRow].length &&
                            piece.shape[pieceRow][pieceCol] == 1) {
                          cellColor = piece.color;
                        }
                      }
                      
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: cellColor ?? const Color(0xFF1A1A2E),
                          border: Border.all(
                            color: cellColor != null 
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                            width: 0.5,
                          ),
                        ),
                        child: cellColor != null
                            ? Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      cellColor.withValues(alpha: 0.8),
                                      cellColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            : null,
                      );
                    }),
                  );
                }),
              ),
              
              // Game over overlay
              if (state.isGameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.read(tetrisControllerProvider.notifier).restart(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                          ),
                          child: const Text('Jogar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Pause overlay
              if (state.isPaused && !state.isGameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        'PAUSADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildNextPiece(Tetromino? piece) {
    if (piece == null) return const SizedBox(width: 70, height: 70);
    
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: piece.shape.map((row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: row.map((cell) {
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: cell == 1 ? piece.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildControls() {
    final controller = ref.read(tetrisControllerProvider.notifier);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(Icons.arrow_left, controller.moveLeft),
        _buildControlButton(Icons.rotate_right, controller.rotate),
        _buildControlButton(Icons.arrow_drop_down, controller.softDrop),
        _buildControlButton(Icons.vertical_align_bottom, controller.hardDrop, color: Colors.orange),
        _buildControlButton(Icons.arrow_right, controller.moveRight),
      ],
    );
  }
  
  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
