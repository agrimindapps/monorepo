import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
import '../../domain/entities/enums.dart';
import '../providers/caca_palavra_game_notifier.dart';
import '../widgets/word_grid_widget.dart';
import '../widgets/word_list_widget.dart';
import '../widgets/victory_dialog.dart';

/// Main page for Caça Palavras (Word Search) game
class CacaPalavraPage extends ConsumerStatefulWidget {
  const CacaPalavraPage({super.key});

  @override
  ConsumerState<CacaPalavraPage> createState() => _CacaPalavraPageState();
}

class _CacaPalavraPageState extends ConsumerState<CacaPalavraPage> {
  bool _hasShownVictoryDialog = false;

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(cacaPalavraGameProvider);

    return GamePageLayout(
      title: 'Caça-Palavras',
      accentColor: const Color(0xFF4CAF50),
      instructions: 'Toque em letras adjacentes para formar palavras.\n\n'
          '📝 Palavras podem estar em qualquer direção\n'
          '🔍 Horizontal, vertical ou diagonal\n'
          '✨ Toque na lista para destacar no grid\n'
          '🏆 Encontre todas para vencer!',
      maxGameWidth: 900,
      actions: [
        PopupMenuButton<GameDifficulty>(
          icon: const Icon(Icons.tune, color: Colors.white),
          tooltip: 'Dificuldade',
          onSelected: (difficulty) => _changeDifficulty(difficulty),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: GameDifficulty.easy,
              child: Text('Fácil (8x8)'),
            ),
            const PopupMenuItem(
              value: GameDifficulty.medium,
              child: Text('Médio (10x10)'),
            ),
            const PopupMenuItem(
              value: GameDifficulty.hard,
              child: Text('Difícil (12x12)'),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Novo Jogo',
          onPressed: () {
            _hasShownVictoryDialog = false;
            ref.read(cacaPalavraGameProvider.notifier).restartGame();
          },
        ),
      ],
      child: gameStateAsync.when(
        data: (gameState) {
          // Show victory dialog when game completes
          if (gameState.isCompleted && !_hasShownVictoryDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVictoryDialog(context, gameState);
            });
          }

          return _buildGameContent(context, gameState);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro: ${error.toString()}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(cacaPalavraGameProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, dynamic gameState) {
    return EscKeyboardWrapper(
      onEscPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Pausado'),
            content: const Text('Pressione ESC para continuar ou Reiniciar'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(cacaPalavraGameProvider.notifier).restartGame();
                },
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          // Progress indicator
          Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.track_changes, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: gameState.progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${gameState.foundWordsCount}/${gameState.words.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Grid
        Expanded(
          flex: 3,
          child: WordGridWidget(
            gameState: gameState,
            onCellTap: (row, col) {
              ref.read(cacaPalavraGameProvider.notifier).handleCellTap(row, col);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Word list
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: WordListWidget(
              words: gameState.words,
              onWordTap: (index) {
                ref.read(cacaPalavraGameProvider.notifier).handleWordTap(index);
              },
            ),
          ),
        ),
      ],
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, dynamic gameState) {
    _hasShownVictoryDialog = true;

    final notifier = ref.read(cacaPalavraGameProvider.notifier);
    final completionTime = notifier.getCompletionTime();
    final bestTime = notifier.highScore.getFastest(gameState.difficulty);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        difficulty: gameState.difficulty,
        wordsFound: gameState.words.length,
        completionTime: completionTime,
        bestTime: bestTime,
        onPlayAgain: () {
          Navigator.pop(context);
          _hasShownVictoryDialog = false;
          notifier.restartGame();
        },
        onExit: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Exit game
        },
      ),
    );
  }

  void _changeDifficulty(GameDifficulty difficulty) {
    final currentState = ref.read(cacaPalavraGameProvider).value;

    if (currentState != null && currentState.foundWordsCount > 0) {
      // Show confirmation dialog if game in progress
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mudar Dificuldade?'),
          content: const Text(
            'Isso irá reiniciar o jogo atual. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _hasShownVictoryDialog = false;
                ref
                    .read(cacaPalavraGameProvider.notifier)
                    .changeDifficulty(difficulty);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
    } else {
      _hasShownVictoryDialog = false;
      ref
          .read(cacaPalavraGameProvider.notifier)
          .changeDifficulty(difficulty);
    }
  }
}
