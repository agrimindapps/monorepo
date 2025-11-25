import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/appbar_widget.dart';
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
    final highScoreAsync = ref.watch(cacaPalavraHighScoreProvider);

    return Scaffold(
      body: SafeArea(
        child: gameStateAsync.when(
          data: (gameState) {
            // Show victory dialog when game completes
            if (gameState.isCompleted && !_hasShownVictoryDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showVictoryDialog(context, gameState);
              });
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;

                if (isLandscape) {
                  return _buildLandscapeLayout(
                    context,
                    gameState,
                    highScoreAsync,
                  );
                } else {
                  return _buildPortraitLayout(
                    context,
                    gameState,
                    highScoreAsync,
                  );
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(cacaPalavraGameProvider);
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    gameState,
    highScoreAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: PageHeaderWidget(
            title: 'Caça-Palavras',
            subtitle: 'Encontre palavras escondidas na grade',
            icon: Icons.search,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showInstructionsDialog(context),
                tooltip: 'Instruções',
              ),
              PopupMenuButton<GameDifficulty>(
                icon: const Icon(Icons.settings),
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
            ],
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Progresso:'),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: gameState.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${gameState.foundWordsCount}/${gameState.words.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Grid
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WordGridWidget(
              gameState: gameState,
              onCellTap: (row, col) {
                ref
                    .read(cacaPalavraGameProvider.notifier)
                    .handleCellTap(row, col);
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Word list
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WordListWidget(
              words: gameState.words,
              onWordTap: (index) {
                ref
                    .read(cacaPalavraGameProvider.notifier)
                    .handleWordTap(index);
              },
            ),
          ),
        ),

        // New game button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              _hasShownVictoryDialog = false;
              ref
                  .read(cacaPalavraGameProvider.notifier)
                  .restartGame();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Novo Jogo'),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    gameState,
    highScoreAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header (compact)
        Padding(
          padding: const EdgeInsets.all(12),
          child: PageHeaderWidget(
            title: 'Caça-Palavras',
            subtitle: 'Encontre palavras escondidas',
            icon: Icons.search,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showInstructionsDialog(context),
                tooltip: 'Instruções',
              ),
              PopupMenuButton<GameDifficulty>(
                icon: const Icon(Icons.settings),
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
            ],
          ),
        ),

        // Progress indicator (compact)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text('Progresso:'),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: gameState.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${gameState.foundWordsCount}/${gameState.words.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Main content row
        Expanded(
          child: Row(
            children: [
              // Grid (left)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
                  child: WordGridWidget(
                    gameState: gameState,
                    onCellTap: (row, col) {
                      ref
                          .read(cacaPalavraGameProvider.notifier)
                          .handleCellTap(row, col);
                    },
                  ),
                ),
              ),

              // Word list and button (right)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, bottom: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: WordListWidget(
                          words: gameState.words,
                          onWordTap: (index) {
                            ref
                                .read(cacaPalavraGameProvider.notifier)
                                .handleWordTap(index);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _hasShownVictoryDialog = false;
                            ref
                                .read(cacaPalavraGameProvider.notifier)
                                .restartGame();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Novo Jogo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVictoryDialog(BuildContext context, gameState) {
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

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como Jogar'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Toque em letras adjacentes para formar uma palavra',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '2. As palavras podem estar em qualquer direção: horizontal, vertical ou diagonal',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '3. Encontre todas as palavras da lista para completar o jogo',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '4. Toque em uma palavra da lista para destacá-la no grid',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
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
