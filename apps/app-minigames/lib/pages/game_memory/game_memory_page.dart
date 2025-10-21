// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/services/dialog_manager.dart';
import 'package:app_minigames/services/timer_service.dart';
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'constants/game_config.dart';
import 'models/card_grid_info.dart';
import 'models/game_logic.dart';
import 'utils/card_interaction_manager.dart';
import 'utils/responsive_utils.dart';
import 'widgets/memory_card_widget.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late MemoryGameLogic gameLogic;
  late CardInteractionManager interactionManager;
  late TimerService timerService;

  @override
  void initState() {
    super.initState();
    gameLogic = MemoryGameLogic();
    interactionManager = CardInteractionManager();
    timerService = TimerService();
    gameLogic.initializeGame();
    gameLogic.loadBestScore();
  }

  @override
  void dispose() {
    // Ordem importante: primeiro cancela timers, depois dispose dos services
    timerService.dispose();
    interactionManager.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameLogic.startGame();
    });

    // Inicia o timer para contagem de tempo usando TimerService
    timerService.createPeriodicTimer(
      type: TimerType.gameTimer,
      interval: const Duration(seconds: 1),
      callback: (timer) {
        if (!mounted || gameLogic.isPaused || gameLogic.isGameOver) {
          timerService.cancelTimer(TimerType.gameTimer);
          return;
        }

        setState(() {
          gameLogic.elapsedTimeInSeconds++;
        });
      },
    );
  }

  void _onCardTap(int index) {
    if (!gameLogic.isGameStarted) {
      _startGame();
    }

    // Verifica estados que impedem interação
    if (gameLogic.isPaused || gameLogic.isGameOver) {
      return;
    }

    // Usa o interaction manager thread-safe para controlar cliques
    if (!interactionManager.registerCardTap()) {
      return; // Clique rejeitado (debounce ou processamento em andamento)
    }

    // Processa o clique da carta
    bool validMove = gameLogic.flipCard(index);
    if (validMove) {
      setState(() {});

      // Se duas cartas estiverem viradas, verifica se são iguais
      if (gameLogic.firstCardIndex != null &&
          gameLogic.secondCardIndex != null) {
        // Inicia processamento thread-safe
        interactionManager.startProcessing(() {
          // Espera um tempo antes de virar as cartas de volta ou removê-las
          timerService.createTimer(
            type: TimerType.matchTimer,
            delay: Duration(milliseconds: gameLogic.difficulty.matchTime),
            callback: () {
              if (!mounted) return;

              setState(() {
                gameLogic.resetSelectedCards();
                interactionManager.finishProcessing();
              });

              // Verifica se o jogo terminou após o processamento
              if (gameLogic.isGameOver) {
                _handleGameOver();
              }
            },
          );
        });
      } else {
        // Se não há duas cartas selecionadas, finaliza o processamento
        interactionManager.finishProcessing();
      }

      // Verifica se o jogo terminou imediatamente (sem necessidade de match)
      if (gameLogic.isGameOver && !interactionManager.isProcessing) {
        _handleGameOver();
      }
    } else {
      // Movimento inválido, finaliza o processamento
      interactionManager.finishProcessing();
    }
  }

  void _handleGameOver() {
    // Cancela todos os timers relacionados ao jogo atomicamente
    // para prevenir condições de corrida
    timerService.cancelGameRelatedTimers();
    HapticFeedback.mediumImpact();

    // Salva a pontuação
    gameLogic.saveBestScore().then((_) {
      if (!mounted) return;

      // Mostra diálogo com a pontuação usando DialogManager
      // Delay configurável para permitir que animações sejam completadas
      // e dar ao usuário tempo para processar a vitória
      Future.delayed(MemoryGameConfig.gameOverDelay, () {
        if (!mounted) return; // Verificação adicional de segurança

        DialogManager.showGameOverDialog(
          context: context,
          elapsedTime: gameLogic.elapsedTimeInSeconds,
          moves: gameLogic.moves,
          score: gameLogic.calculateScore(),
          bestScore: gameLogic.bestScore,
          isNewRecord: gameLogic.calculateScore() >= gameLogic.bestScore,
          onPlayAgain: _restartGame,
          onExit: () => Navigator.pop(context),
        );
      });
    });
  }

  void _pauseGame() {
    gameLogic.togglePause();
    interactionManager.disable(); // Desabilita interações durante pausa
    setState(() {});

    DialogManager.showPauseDialog(
      context: context,
      elapsedTime: gameLogic.elapsedTimeInSeconds,
      moves: gameLogic.moves,
      currentDifficulty: gameLogic.difficulty,
      onDifficultyChanged: (newDifficulty) {
        setState(() {
          gameLogic.difficulty = newDifficulty;
        });
      },
      onResume: _resumeGame,
      onRestart: _restartGame,
    );
  }

  void _resumeGame() {
    setState(() {
      gameLogic.togglePause();
      interactionManager.enable(); // Reabilita interações
    });
  }

  void _restartGame() {
    timerService.cancelAllTimers();

    setState(() {
      gameLogic.initializeGame();
      interactionManager.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Jogo da Memória',
              subtitle: 'Encontre os pares de cartas combinando os emojis',
              icon: Icons.memory,
              showBackButton: true,
              actions: [
                // Botão de pausa
                if (gameLogic.isGameStarted && !gameLogic.isGameOver)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: _pauseGame,
                  ),
                // Menu de opções
                PopupMenuButton<GameDifficulty>(
                  tooltip: 'Dificuldade',
                  icon: const Icon(Icons.settings),
                  onSelected: (difficulty) {
                    if (gameLogic.isGameStarted) {
                      DialogManager.showDifficultyChangeDialog(
                        context: context,
                        onConfirm: () {
                          setState(() {
                            gameLogic.difficulty = difficulty;
                            _restartGame();
                          });
                        },
                      );
                    } else {
                      setState(() {
                        gameLogic.difficulty = difficulty;
                        _restartGame();
                      });
                    }
                  },
                  itemBuilder: (context) => GameDifficulty.values
                      .map((difficulty) => PopupMenuItem(
                            value: difficulty,
                            child: Text(difficulty.label),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Informações do jogo
          Padding(
            padding: ResponsiveGameUtils.getScreenPadding(
                MediaQuery.of(context).size),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tempo
                Column(
                  children: [
                    const Text('Tempo',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(DialogManager.formatTime(
                        gameLogic.elapsedTimeInSeconds)),
                  ],
                ),

                // Movimentos
                Column(
                  children: [
                    const Text('Movimentos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${gameLogic.moves}'),
                  ],
                ),

                // Pares encontrados
                Column(
                  children: [
                    const Text('Pares',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${gameLogic.matchedPairs}/${gameLogic.totalPairs}'),
                  ],
                ),
              ],
            ),
          ),

          // Grade de cartas
          Expanded(
            child: gameLogic.cards.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildCardGrid(),
          ),

          // Botão de iniciar (mostrado apenas antes do jogo começar)
          if (!gameLogic.isGameStarted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child:
                    const Text('Iniciar Jogo', style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  /// Calcula o tamanho ideal das cartas com validação responsiva
  /// para evitar quebras de layout em telas pequenas
  CardGridInfo _calculateCardGridInfo() {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final gridSize = gameLogic.difficulty.gridSize;

    return ResponsiveGameUtils.calculateCardGridInfo(
      screenSize: size,
      gridSize: gridSize,
      orientation: orientation,
    );
  }

  Widget _buildCardGrid() {
    final size = MediaQuery.of(context).size;
    final gridInfo = _calculateCardGridInfo();
    final spacing = ResponsiveGameUtils.getGridSpacing(size);

    return Center(
      child: SizedBox(
        width: gridInfo.gridWidth,
        height: gridInfo.gridHeight,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridInfo.gridSize,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: gameLogic.cards.length,
          itemBuilder: (context, index) => MemoryCardWidget(
            card: gameLogic.cards[index],
            onTap: () => _onCardTap(index),
            size: gridInfo.actualCardSize,
          ),
        ),
      ),
    );
  }
}
