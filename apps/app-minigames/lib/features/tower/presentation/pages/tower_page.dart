import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tower_game_notifier.dart';
import '../widgets/game_board_widget.dart';

/// Main page for Tower Stack game
class TowerPage extends ConsumerStatefulWidget {
  const TowerPage({super.key});

  @override
  ConsumerState<TowerPage> createState() => _TowerPageState();
}

class _TowerPageState extends ConsumerState<TowerPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gameStateAsync = ref.watch(towerGameProvider(screenWidth));

    return Scaffold(
      body: gameStateAsync.when(
        data: (gameState) {
          final notifier =
              ref.read(towerGameProvider(screenWidth).notifier);

          return GameBoardWidget(
            gameState: gameState,
            highScore: notifier.highScore,
            onDrop: () => notifier.dropBlock(),
            onPause: () => notifier.togglePause(),
            onRestart: () => notifier.restartGame(),
            onDifficultyChanged: (difficulty) =>
                notifier.changeDifficulty(difficulty),
            onExit: () => Navigator.of(context).pop(),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
