// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'constants/layout.dart';
import 'constants/strings.dart';
import 'providers/game_provider.dart';
import 'services/game_dialog_service.dart';
import 'widgets/word_grid.dart';
import 'widgets/word_list.dart';

class CacaPalavrasGame extends StatelessWidget {
  const CacaPalavrasGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const _CacaPalavrasGameView(),
    );
  }
}

class _CacaPalavrasGameView extends StatelessWidget {
  const _CacaPalavrasGameView();

  // Mostra diálogo de vitória usando o serviço e GameProvider
  void _showVictoryDialog(BuildContext context, GameProvider gameProvider) {
    // Marca que o diálogo será exibido
    gameProvider.markVictoryDialogShown();

    GameDialogService.showVictoryDialog(
      context: context,
      difficulty: gameProvider.difficulty,
      wordsFound: gameProvider.words.length,
      onPlayAgain: () {
        GameDialogService.resetFlags(); // Reset das flags dos diálogos
        gameProvider.restartGame();
      },
      onExit: () {
        Navigator.pop(context);
      },
    );
  }

  // Mostra diálogo de instruções usando o serviço
  void _showInstructionsDialog(BuildContext context) {
    GameDialogService.showInstructionsDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Verifica se o jogo terminou para mostrar o diálogo de vitória
        if (gameProvider.shouldShowVictoryDialog) {
          // Agenda a exibição do diálogo para o próximo frame de forma segura
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVictoryDialog(context, gameProvider);
          });
        }

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final orientation = MediaQuery.of(context).orientation;
                
                // Determina se deve usar layout em landscape
                final isLandscape = orientation == Orientation.landscape;
                
                if (isLandscape) {
                  return _buildLandscapeLayout(context, gameProvider, screenWidth, screenHeight);
                } else {
                  return _buildPortraitLayout(context, gameProvider, screenWidth, screenHeight);
                }
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPortraitLayout(BuildContext context, GameProvider gameProvider, double screenWidth, double screenHeight) {
    final responsivePadding = GameLayout.getResponsivePadding(screenWidth);
    final orientation = MediaQuery.of(context).orientation;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header da página
        Padding(
          padding: responsivePadding,
          child: PageHeaderWidget(
            title: GameStrings.gameTitle,
            subtitle: 'Encontre palavras escondidas na grade',
            icon: Icons.search,
            showBackButton: true,
            actions: [
              // Botão de instruções
              IconButton(
                onPressed: () => _showInstructionsDialog(context),
                icon: const Icon(Icons.help_outline),
                tooltip: GameStrings.instructionsTooltip,
              ),
              // Menu de dificuldade
              PopupMenuButton<GameDifficulty>(
                tooltip: GameStrings.difficultyTooltip,
                icon: const Icon(Icons.settings),
                onSelected: (difficulty) {
                  if (gameProvider.foundWords > 0) {
                    GameDialogService.showConfirmDifficultyChangeDialog(
                      context: context,
                      newDifficulty: difficulty,
                      onConfirm: () {
                        GameDialogService.resetFlags();
                        gameProvider.restartGame(newDifficulty: difficulty);
                      },
                    );
                  } else {
                    gameProvider.restartGame(newDifficulty: difficulty);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: GameDifficulty.easy,
                    child: Text(GameStrings.difficultyEasy),
                  ),
                  PopupMenuItem(
                    value: GameDifficulty.medium,
                    child: Text(GameStrings.difficultyMedium),
                  ),
                  PopupMenuItem(
                    value: GameDifficulty.hard,
                    child: Text(GameStrings.difficultyHard),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Indicador de progresso
        Padding(
          padding: GameLayout.paddingSymmetric,
          child: Row(
            children: [
              const Text(GameStrings.progressLabel),
              GameLayout.horizontalSpacingMedium,
              Expanded(
                child: LinearProgressIndicator(
                  value: gameProvider.foundWords / gameProvider.words.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              GameLayout.horizontalSpacingMedium,
              Text(
                GameStrings.formatProgress(
                  gameProvider.foundWords,
                  gameProvider.words.length,
                ),
                style: GameLayout.progressTextStyle,
              ),
            ],
          ),
        ),

        // Grid de letras
        Expanded(
          flex: GameLayout.getResponsiveGridFlex(orientation),
          child: Padding(
            padding: GameLayout.paddingDefault,
            child: WordGridWidget(
              gameLogic: gameProvider.gameLogic,
              onCellTap: (row, col) {
                gameProvider.handleCellTap(row, col);
              },
            ),
          ),
        ),

        // Lista de palavras
        Expanded(
          flex: GameLayout.getResponsiveWordListFlex(orientation),
          child: Padding(
            padding: GameLayout.paddingDefault,
            child: WordListWidget(
              words: gameProvider.words,
              onWordTap: (index) {
                gameProvider.handleWordTap(index);
              },
            ),
          ),
        ),

        // Botão de novo jogo
        Padding(
          padding: GameLayout.paddingDefault,
          child: ElevatedButton.icon(
            onPressed: () {
              GameDialogService.resetFlags(); // Reset das flags dos diálogos
              gameProvider.restartGame();
            },
            icon: const Icon(Icons.refresh),
            label: const Text(GameStrings.newGameButton),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLandscapeLayout(BuildContext context, GameProvider gameProvider, double screenWidth, double screenHeight) {
    final responsivePadding = GameLayout.getResponsivePadding(screenWidth);
    final orientation = MediaQuery.of(context).orientation;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header da página (mais compacto em landscape)
        Padding(
          padding: const EdgeInsets.all(GameLayout.spacingMedium),
          child: PageHeaderWidget(
            title: GameStrings.gameTitle,
            subtitle: 'Encontre palavras escondidas na grade',
            icon: Icons.search,
            showBackButton: true,
            actions: [
              // Botão de instruções
              IconButton(
                onPressed: () => _showInstructionsDialog(context),
                icon: const Icon(Icons.help_outline),
                tooltip: GameStrings.instructionsTooltip,
              ),
              // Menu de dificuldade
              PopupMenuButton<GameDifficulty>(
                tooltip: GameStrings.difficultyTooltip,
                icon: const Icon(Icons.settings),
                onSelected: (difficulty) {
                  if (gameProvider.foundWords > 0) {
                    GameDialogService.showConfirmDifficultyChangeDialog(
                      context: context,
                      newDifficulty: difficulty,
                      onConfirm: () {
                        GameDialogService.resetFlags();
                        gameProvider.restartGame(newDifficulty: difficulty);
                      },
                    );
                  } else {
                    gameProvider.restartGame(newDifficulty: difficulty);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: GameDifficulty.easy,
                    child: Text(GameStrings.difficultyEasy),
                  ),
                  PopupMenuItem(
                    value: GameDifficulty.medium,
                    child: Text(GameStrings.difficultyMedium),
                  ),
                  PopupMenuItem(
                    value: GameDifficulty.hard,
                    child: Text(GameStrings.difficultyHard),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Indicador de progresso compacto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GameLayout.spacingDefault, vertical: GameLayout.spacingSmall),
          child: Row(
            children: [
              const Text(GameStrings.progressLabel),
              GameLayout.horizontalSpacingMedium,
              Expanded(
                child: LinearProgressIndicator(
                  value: gameProvider.foundWords / gameProvider.words.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              GameLayout.horizontalSpacingMedium,
              Text(
                GameStrings.formatProgress(
                  gameProvider.foundWords,
                  gameProvider.words.length,
                ),
                style: GameLayout.progressTextStyle,
              ),
            ],
          ),
        ),

        // Layout principal em linha para landscape
        Expanded(
          child: Row(
            children: [
              // Grid de letras (lado esquerdo)
              Expanded(
                flex: GameLayout.getResponsiveGridFlex(orientation),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: GameLayout.spacingDefault,
                    right: GameLayout.spacingMedium,
                    bottom: GameLayout.spacingDefault,
                  ),
                  child: WordGridWidget(
                    gameLogic: gameProvider.gameLogic,
                    onCellTap: (row, col) {
                      gameProvider.handleCellTap(row, col);
                    },
                  ),
                ),
              ),

              // Lista de palavras e botão (lado direito)
              Expanded(
                flex: GameLayout.getResponsiveWordListFlex(orientation),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: GameLayout.spacingMedium,
                    right: GameLayout.spacingDefault,
                    bottom: GameLayout.spacingDefault,
                  ),
                  child: Column(
                    children: [
                      // Lista de palavras
                      Expanded(
                        child: WordListWidget(
                          words: gameProvider.words,
                          onWordTap: (index) {
                            gameProvider.handleWordTap(index);
                          },
                        ),
                      ),
                      
                      GameLayout.verticalSpacingMedium,
                      
                      // Botão de novo jogo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            GameDialogService.resetFlags();
                            gameProvider.restartGame();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text(GameStrings.newGameButton),
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
}
