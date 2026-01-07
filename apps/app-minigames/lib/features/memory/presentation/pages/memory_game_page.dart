import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import '../providers/memory_game_notifier.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/memory_grid_widget.dart';
import '../widgets/victory_dialog.dart';
import '../../../../widgets/shared/responsive_game_container.dart';

import '../../data/repositories/deck_repository.dart';
import '../../domain/entities/deck_configuration.dart';

class MemoryGamePage extends ConsumerStatefulWidget {
  const MemoryGamePage({super.key});

  @override
  ConsumerState<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends ConsumerState<MemoryGamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider.notifier).startGame(
            GameDifficulty.medium,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryGameProvider);
    final notifier = ref.read(memoryGameProvider.notifier);

    if (gameState.status == GameStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da Memória - ${gameState.difficulty.label}'),
        actions: [
          if (gameState.status == GameStatus.playing ||
              gameState.status == GameStatus.paused)
            IconButton(
              icon: Icon(
                gameState.status == GameStatus.paused
                    ? Icons.play_arrow
                    : Icons.pause,
              ),
              onPressed: () => notifier.togglePause(),
            ),
          IconButton(
            icon: const Icon(Icons.style), // Card deck icon
            tooltip: 'Trocar Baralho',
            onPressed: () => _showDeckSelectionDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.restartGame(),
          ),
          PopupMenuButton<GameDifficulty>(
            icon: const Icon(Icons.settings),
            onSelected: (difficulty) {
              notifier.changeDifficulty(difficulty);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GameDifficulty.easy,
                child: Text('Fácil (4x4)'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.medium,
                child: Text('Médio (6x6)'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.hard,
                child: Text('Difícil (8x8)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveGameContainer(
          maxWidth: 900,
          child: Column(
            children: [
              GameStatsWidget(gameState: gameState),
              const SizedBox(height: 16),
              Expanded(
                child: _buildGameContent(gameState, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(
    GameStateEntity gameState,
    MemoryGameNotifier notifier,
  ) {
    if (gameState.status == GameStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro: ${gameState.errorMessage}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.restartGame(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (gameState.cards.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (gameState.status == GameStatus.paused) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause_circle_outline, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Jogo Pausado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.togglePause(),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    }

    return MemoryGridWidget(
      cards: gameState.cards,
      gridSize: gameState.difficulty.gridSize,
      onCardTap: (cardId) {
        HapticFeedback.lightImpact();
        notifier.flipCard(cardId);
      },
    );
  }

  void _showVictoryDialog(BuildContext context) {
    HapticFeedback.heavyImpact(); // Celebration feedback
    final gameState = ref.read(memoryGameProvider);
    final notifier = ref.read(memoryGameProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        gameState: gameState,
        highScore: notifier.currentHighScore,
        isNewRecord: notifier.isNewRecord,
        onPlayAgain: () {
          Navigator.of(context).pop();
          notifier.restartGame();
        },
        onChangeDifficulty: () {
          Navigator.of(context).pop();
          _showDifficultyDialog(context);
        },
      ),
    );
  }

  void _showDeckSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha o Baralho'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.grid_view, color: Colors.blue),
                title: const Text('Clássico (Ícones)'),
                subtitle: const Text('Padrão do jogo'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(memoryGameProvider.notifier).changeDeck(null);
                },
              ),
              const Divider(),
              ...DeckRepository.availableDecks.map((deck) => ListTile(
                    leading: const Icon(Icons.image, color: Colors.green),
                    title: Text(deck.name),
                    subtitle: Text('${deck.totalSprites} imagens'),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(memoryGameProvider.notifier).changeDeck(deck);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha a Dificuldade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Fácil (4x4)'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(memoryGameProvider.notifier)
                    .changeDifficulty(GameDifficulty.easy);
              },
            ),
            ListTile(
              title: const Text('Médio (6x6)'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(memoryGameProvider.notifier)
                    .changeDifficulty(GameDifficulty.medium);
              },
            ),
            ListTile(
              title: const Text('Difícil (8x8)'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(memoryGameProvider.notifier)
                    .changeDifficulty(GameDifficulty.hard);
              },
            ),
          ],
        ),
      ),
    );
  }
}
