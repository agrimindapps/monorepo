import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../providers/soletrando_game_notifier.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/letter_keyboard_widget.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/word_display_widget.dart';

/// Main page for Soletrando spelling game
class SoletrandoPage extends ConsumerStatefulWidget {
  const SoletrandoPage({super.key});

  @override
  ConsumerState<SoletrandoPage> createState() => _SoletrandoPageState();
}

class _SoletrandoPageState extends ConsumerState<SoletrandoPage> {
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;
  WordCategory _selectedCategory = WordCategory.fruits;

  @override
  void initState() {
    super.initState();
    // Start game after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewGame();
    });
  }

  void _startNewGame() {
    ref.read(soletrandoGameProvider.notifier).startGame(
          difficulty: _selectedDifficulty,
          category: _selectedCategory,
        );
  }

  void _onLetterPressed(String letter) {
    ref.read(soletrandoGameProvider.notifier).checkLetter(letter);
  }

  void _useHint() {
    ref.read(soletrandoGameProvider.notifier).useHint();
  }

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final gameState = ref.read(soletrandoGameProvider);

        return VictoryDialog(
          gameState: gameState,
          onPlayAgain: () {
            Navigator.pop(context);
            _startNewGame();
          },
          onMainMenu: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Difficulty selection
            DropdownButtonFormField<GameDifficulty>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Dificuldade'),
              items: GameDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Category selection
            DropdownButtonFormField<WordCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: WordCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text('${category.icon} ${category.name}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(soletrandoGameProvider);

    // Show dialog on game end
    ref.listen(soletrandoGameProvider, (previous, next) {
      if (next.status == GameStatus.wordCompleted ||
          next.status == GameStatus.gameOver ||
          next.status == GameStatus.timeUp) {
        Future.microtask(() => _showGameEndDialog());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soletrando'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: gameState.status == GameStatus.initial
          ? const Center(child: CircularProgressIndicator())
          : gameState.status == GameStatus.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar jogo'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startNewGame,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Game stats
                      GameStatsWidget(gameState: gameState),
                      const SizedBox(height: 24),

                      // Word display
                      WordDisplayWidget(gameState: gameState),
                      const SizedBox(height: 24),

                      // Hint button
                      ElevatedButton.icon(
                        onPressed: gameState.canUseHint ? _useHint : null,
                        icon: const Icon(Icons.lightbulb),
                        label: Text(
                          'Dica (${gameState.hintsRemaining})',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Letter keyboard
                      LetterKeyboardWidget(
                        guessedLetters: gameState.guessedLetters,
                        onLetterPressed: _onLetterPressed,
                        enabled: gameState.isActive,
                      ),
                    ],
                  ),
                ),
    );
  }
}
