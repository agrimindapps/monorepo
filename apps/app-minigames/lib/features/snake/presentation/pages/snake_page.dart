// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Presentation imports:
import '../providers/snake_game_notifier.dart';

// Domain imports:
import '../../domain/entities/enums.dart';

/// Snake game page
class SnakePage extends ConsumerWidget {
  const SnakePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(snakeGameNotifierProvider);
    final notifier = ref.read(snakeGameNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.restartGame(),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => notifier.togglePause(),
          ),
        ],
      ),
      body: gameState.when(
        data: (state) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Score: ${state.score}'),
                    Text('High Score: ${notifier.highScore}'),
                    Text('Length: ${state.length}'),
                  ],
                ),
              ),

              // Game board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.black,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: state.gridSize,
                        ),
                        itemCount: state.gridSize * state.gridSize,
                        itemBuilder: (context, index) {
                          final x = index % state.gridSize;
                          final y = index ~/ state.gridSize;

                          Color cellColor = Colors.grey[900]!;

                          if (state.isSnakeHead(x, y)) {
                            cellColor = Colors.green[700]!;
                          } else if (state.isSnake(x, y)) {
                            cellColor = Colors.green;
                          } else if (state.isFood(x, y)) {
                            cellColor = Colors.red;
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Instructions or game over
              if (state.gameStatus.isNotStarted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => notifier.startGame(),
                    child: const Text('Iniciar Jogo'),
                  ),
                ),

              if (state.gameStatus.isGameOver)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Game Over!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.restartGame(),
                        child: const Text('Jogar Novamente'),
                      ),
                    ],
                  ),
                ),

              if (state.gameStatus.isPaused)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'PAUSADO',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Up
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 48),
                      onPressed: () => notifier.changeDirection(Direction.up),
                    ),
                    // Left and Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 48),
                          onPressed: () => notifier.changeDirection(Direction.left),
                        ),
                        const SizedBox(width: 100),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 48),
                          onPressed: () => notifier.changeDirection(Direction.right),
                        ),
                      ],
                    ),
                    // Down
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 48),
                      onPressed: () => notifier.changeDirection(Direction.down),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
