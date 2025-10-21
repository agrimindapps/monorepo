// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'constants/game_theme.dart';
import 'controllers/tictactoe_controller.dart';
import 'widgets/game_board_widget.dart';
import 'widgets/statistics_dialog.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late TicTacToeController controller;
  
  @override
  void initState() {
    super.initState();
    controller = TicTacToeController();
    controller.addListener(_onGameStateChanged);
  }
  
  void _onGameStateChanged() {
    if (controller.gameBoard.result != GameResult.inProgress) {
      // Mostra resultado após um breve delay para permitir a animação
      Future.delayed(const Duration(milliseconds: 500), _showGameResult);
    }
  }
  
  @override
  void dispose() {
    controller.removeListener(_onGameStateChanged);
    controller.dispose();
    super.dispose();
  }

  void onCellTap(int row, int col) {
    // Vibração de feedback
    HapticFeedback.selectionClick();
    
    controller.makeMove(row, col);
  }


  void _showGameResult() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(controller.gameBoard.result.message),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text('Partidas:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatistic('X', controller.xWins),
                _buildStatistic('O', controller.oWins),
                _buildStatistic('Empates', controller.draws),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.restartGame();
            },
            child: const Text('Nova Partida'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context, TicTacToeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reset'),
        content: const Text('Deseja resetar todas as estatísticas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.resetAllStats();
              Navigator.pop(context);
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('$value'),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<TicTacToeController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: GameTheme.getBackgroundColor(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Jogo da Velha',
              subtitle: 'Desafie-se no clássico jogo de X e O',
              icon: Icons.grid_3x3,
              showBackButton: true,
              actions: [
                // Botão para mudar dificuldade (apenas no modo vs Computador)
                if (controller.gameBoard.gameMode == GameMode.vsComputer)
                  PopupMenuButton<Difficulty>(
                    tooltip: 'Dificuldade',
                    icon: const Icon(Icons.settings),
                    onSelected: controller.changeDifficulty,
                    itemBuilder: (context) => Difficulty.values
                        .map((difficulty) => PopupMenuItem(
                              value: difficulty,
                              child: Text(difficulty.label),
                            ))
                        .toList(),
                  ),
                // Menu de opções
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'reset') {
                      _showResetDialog(context, controller);
                    } else if (value == 'stats') {
                      _showStatisticsDialog(context, controller);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'stats',
                      child: Text('Estatísticas Detalhadas'),
                    ),
                    const PopupMenuItem(
                      value: 'reset',
                      child: Text('Resetar Estatísticas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Placar e vez atual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('X',
                        style: TextStyle(
                            fontSize: GameTheme.getFontSize(context, 24),
                            color: GameTheme.xPlayerColors[0],
                            fontWeight: FontWeight.bold)),
                    Text('${controller.xWins}',
                        style: TextStyle(
                            fontSize: GameTheme.getFontSize(context, 16))),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      controller.gameBoard.result == GameResult.inProgress
                          ? 'Vez: ${controller.gameBoard.currentPlayer.symbol}'
                          : controller.gameBoard.result.message,
                      style: TextStyle(
                        fontSize: GameTheme.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: controller.gameBoard.result == GameResult.inProgress
                            ? controller.gameBoard.currentPlayer.color
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(controller.gameBoard.gameMode == GameMode.vsComputer
                        ? 'Dificuldade: ${controller.gameBoard.difficulty.label}'
                        : ''),
                  ],
                ),
                Column(
                  children: [
                    Text('O',
                        style: TextStyle(
                            fontSize: GameTheme.getFontSize(context, 24),
                            color: GameTheme.oPlayerColors[0],
                            fontWeight: FontWeight.bold)),
                    Text('${controller.oWins}',
                        style: TextStyle(
                            fontSize: GameTheme.getFontSize(context, 16))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tabuleiro do jogo
          GameBoardWidget(
            gameBoard: controller.gameBoard,
            onCellTap: onCellTap,
          ),

          const SizedBox(height: 20),

          // Botões de controle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botão para reiniciar o jogo
              ElevatedButton.icon(
                onPressed: controller.restartGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Nova Partida'),
              ),

              // Botão para alternar entre modo de um ou dois jogadores
              ElevatedButton.icon(
                onPressed: () => controller.changeGameMode(
                    controller.gameBoard.gameMode == GameMode.vsPlayer
                        ? GameMode.vsComputer
                        : GameMode.vsPlayer),
                icon: Icon(controller.gameBoard.gameMode == GameMode.vsPlayer
                    ? Icons.computer
                    : Icons.people),
                label: Text(controller.gameBoard.gameMode == GameMode.vsPlayer
                    ? 'Vs Computador'
                    : 'Dois Jogadores'),
              ),
            ],
          ),
        ],
      ),
    );
        },
      ),
    );
  }
  
  void _showStatisticsDialog(BuildContext context, TicTacToeController controller) {
    showDialog(
      context: context,
      builder: (context) => StatisticsDialog(controller: controller),
    );
  }
}
