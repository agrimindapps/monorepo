import 'package:flutter/material.dart';
import '../../../../widgets/appbar_widget.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import 'block_widget.dart';
import 'clouds_background_widget.dart';
import 'game_over_dialog.dart';
import 'pause_dialog.dart';

/// Main game board widget containing all game UI elements
class GameBoardWidget extends StatefulWidget {
  final GameState gameState;
  final int highScore;
  final VoidCallback onDrop;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  final Function(GameDifficulty) onDifficultyChanged;
  final VoidCallback onExit;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.highScore,
    required this.onDrop,
    required this.onPause,
    required this.onRestart,
    required this.onDifficultyChanged,
    required this.onExit,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _comboAnimController;
  Animation<double>? _comboAnimation;

  @override
  void initState() {
    super.initState();
    _comboAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _comboAnimation = CurvedAnimation(
      parent: _comboAnimController!,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _comboAnimController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GameBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger combo animation when perfect placement occurs
    if (widget.gameState.isPerfectPlacement &&
        !oldWidget.gameState.isPerfectPlacement) {
      _comboAnimController?.reset();
      _comboAnimController?.forward();
      _showPerfectSnackBar();
    }

    // Show game over dialog
    if (widget.gameState.isGameOver && !oldWidget.gameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }
  }

  void _showPerfectSnackBar() {
    final message = widget.gameState.combo > 1
        ? 'Perfeito! Combo x${widget.gameState.combo}'
        : 'Perfeito!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            widget.gameState.combo > 2 ? Colors.purple : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        score: widget.gameState.score,
        highScore: widget.highScore,
        combo: widget.gameState.combo,
        onRestart: () {
          Navigator.pop(context);
          widget.onRestart();
        },
        onExit: () {
          Navigator.pop(context);
          widget.onExit();
        },
      ),
    );
  }

  void _showPauseDialog() {
    widget.onPause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PauseDialog(
        score: widget.gameState.score,
        combo: widget.gameState.combo,
        currentDifficulty: widget.gameState.difficulty,
        onResume: () {
          Navigator.pop(context);
          widget.onPause(); // Unpause
        },
        onRestart: () {
          Navigator.pop(context);
          widget.onRestart();
        },
        onDifficultyChanged: widget.onDifficultyChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PageHeaderWidget(
            title: 'Tower Stack',
            subtitle: 'Pontuação: ${widget.gameState.score}',
            icon: Icons.architecture,
            showBackButton: true,
            actions: [
              // Show combo if exists
              if (widget.gameState.combo > 1)
                Center(
                  child: AnimatedBuilder(
                    animation: _comboAnimation!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_comboAnimation!.value * 0.3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Combo x${widget.gameState.combo}',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  16 + (widget.gameState.combo > 3 ? 2 : 0),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _showPauseDialog,
              ),
            ],
          ),
        ),

        // Game area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue[200]!, Colors.blue[800]!],
              ),
            ),
            child: Stack(
              children: [
                // Background with clouds
                const Positioned.fill(
                  child: CloudsBackgroundWidget(),
                ),

                // Difficulty indicator
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Dificuldade: ${widget.gameState.difficulty.label}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Stacked blocks
                ..._buildBlocks(),

                // Moving block
                Positioned(
                  left: widget.gameState.currentBlockPosX,
                  bottom: widget.gameState.blocks.length *
                      GameState.blockHeight,
                  child: GestureDetector(
                    onTap: widget.onDrop,
                    child: BlockWidget(
                      width: widget.gameState.currentBlockWidth,
                      height: GameState.blockHeight,
                      color: widget.gameState.nextBlockColor,
                      isMoving: true,
                    ),
                  ),
                ),

                // Full screen tap area
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onDrop,
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds positioned widgets for all stacked blocks
  List<Widget> _buildBlocks() {
    return List.generate(widget.gameState.blocks.length, (index) {
      final block = widget.gameState.blocks[index];
      return Positioned(
        left: block.posX,
        bottom: index * block.height,
        child: BlockWidget(
          width: block.width,
          height: block.height,
          color: block.color,
        ),
      );
    });
  }
}
