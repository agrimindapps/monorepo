/// Nova página do jogo da memória refatorada com arquitetura MVC
/// 
/// Implementa separação clara de responsabilidades usando Provider
/// para gerenciamento de estado e controlador para coordenação.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/services/dialog_manager.dart';
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'constants/game_config.dart';
import 'controllers/memory_game_controller.dart';
import 'models/card_grid_info.dart';
import 'providers/memory_game_provider.dart';
import 'services/memory_storage_service.dart';
import 'utils/responsive_utils.dart';
import 'widgets/memory_card_widget.dart';

/// Widget principal do jogo da memória
class MemoryGamePage extends StatelessWidget {
  const MemoryGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MemoryGameProvider(),
      child: const _MemoryGameView(),
    );
  }
}

/// View principal do jogo
class _MemoryGameView extends StatefulWidget {
  const _MemoryGameView();

  @override
  State<_MemoryGameView> createState() => _MemoryGameViewState();
}

class _MemoryGameViewState extends State<_MemoryGameView> with WidgetsBindingObserver {
  /// Controlador do jogo
  late MemoryGameController _controller;
  
  /// Serviço de armazenamento
  late MemoryStorageService _storageService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// Inicializa o controlador
  void _initializeController() {
    _storageService = MemoryStorageService();
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    _controller = MemoryGameController(provider, _storageService);
    
    // Inicializa de forma assíncrona
    _controller.initialize().then((_) {
      _controller.loadGameConfig();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    
    // Pausa automaticamente quando app perde foco
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (provider.isGameStarted && !provider.isGameOver && !provider.isPaused) {
        _controller.togglePause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MemoryGameProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header da página
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PageHeaderWidget(
                  title: 'Jogo da Memória',
                  subtitle: 'Encontre os pares de cartas combinando os emojis',
                  icon: Icons.memory,
                  showBackButton: true,
                  actions: _buildHeaderActions(provider),
                ),
              ),
              // Informações do jogo
              _buildGameInfo(provider),
              
              // Grade de cartas
              Expanded(
                child: provider.cards.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCardGrid(provider),
              ),
              
              // Botão de iniciar (mostrado apenas antes do jogo começar)
              if (!provider.isGameStarted)
                _buildStartButton(),
            ],
          );
        },
      ),
    );
  }

  /// Constrói as ações do header
  List<Widget> _buildHeaderActions(MemoryGameProvider provider) {
    return [
      // Botão de pausa
      if (provider.isGameStarted && !provider.isGameOver)
        IconButton(
          icon: Icon(provider.isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: _handlePause,
          tooltip: provider.isPaused ? 'Retomar' : 'Pausar',
        ),
      
      // Menu de configurações
      _buildSettingsMenu(),
    ];
  }

  /// Constrói menu de configurações
  Widget _buildSettingsMenu() {
    return Consumer<MemoryGameProvider>(
      builder: (context, provider, child) {
        return PopupMenuButton<String>(
          tooltip: 'Configurações',
          icon: const Icon(Icons.settings),
          onSelected: (value) => _handleMenuAction(value, provider),
          itemBuilder: (context) => [
            // Opções de dificuldade
            const PopupMenuItem(
              enabled: false,
              child: Text(
                'Dificuldade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...GameDifficulty.values.map((difficulty) => 
              PopupMenuItem(
                value: 'difficulty_${difficulty.name}',
                child: Row(
                  children: [
                    Icon(
                      provider.difficulty == difficulty 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(difficulty.label),
                  ],
                ),
              ),
            ),
            
            const PopupMenuDivider(),
            
            // Outras opções
            const PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Reiniciar'),
                ],
              ),
            ),
            
            const PopupMenuItem(
              value: 'statistics',
              child: Row(
                children: [
                  Icon(Icons.bar_chart),
                  SizedBox(width: 8),
                  Text('Estatísticas'),
                ],
              ),
            ),
            
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 8),
                  Text('Ajuda'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Constrói informações do jogo
  Widget _buildGameInfo(MemoryGameProvider provider) {
    return Padding(
      padding: ResponsiveGameUtils.getScreenPadding(
        MediaQuery.of(context).size,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tempo
          _buildInfoColumn(
            'Tempo',
            DialogManager.formatTime(provider.elapsedTimeInSeconds),
            Icons.timer,
          ),
          
          // Movimentos
          _buildInfoColumn(
            'Movimentos',
            '${provider.moves}',
            Icons.touch_app,
          ),
          
          // Pares encontrados
          _buildInfoColumn(
            'Pares',
            '${provider.matchedPairs}/${provider.totalPairs}',
            Icons.favorite,
          ),
          
          // Pontuação (se jogo iniciado)
          if (provider.isGameStarted)
            _buildInfoColumn(
              'Pontos',
              '${provider.calculateCurrentScore()}',
              Icons.star,
            ),
        ],
      ),
    );
  }

  /// Constrói coluna de informação
  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  /// Constrói grade de cartas
  Widget _buildCardGrid(MemoryGameProvider provider) {
    final gridInfo = _calculateCardGridInfo(provider);
    final spacing = ResponsiveGameUtils.getGridSpacing(
      MediaQuery.of(context).size,
    );

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
          itemCount: provider.cards.length,
          itemBuilder: (context, index) => MemoryCardWidget(
            card: provider.cards[index],
            onTap: provider.canInteract 
                ? () => _handleCardTap(index)
                : () {},
            size: gridInfo.actualCardSize,
          ),
        ),
      ),
    );
  }

  /// Calcula informações da grade de cartas
  CardGridInfo _calculateCardGridInfo(MemoryGameProvider provider) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final gridSize = provider.difficulty.gridSize;

    return ResponsiveGameUtils.calculateCardGridInfo(
      screenSize: size,
      gridSize: gridSize,
      orientation: orientation,
    );
  }

  /// Constrói botão de iniciar
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _handleStartGame,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Iniciar Jogo'),
      ),
    );
  }

  /// Manipula clique em carta
  Future<void> _handleCardTap(int index) async {
    await _controller.handleCardTap(index);
    
    // Verifica se o jogo terminou
    if (mounted) {
      final provider = Provider.of<MemoryGameProvider>(context, listen: false);
      if (provider.isGameOver) {
        await _handleGameOver();
      }
    }
  }

  /// Manipula início do jogo
  Future<void> _handleStartGame() async {
    await _controller.startNewGame();
  }

  /// Manipula pausa
  void _handlePause() {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    
    _controller.togglePause();
    
    if (provider.isPaused) {
      _showPauseDialog();
    }
  }

  /// Mostra diálogo de pausa
  void _showPauseDialog() {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    
    DialogManager.showPauseDialog(
      context: context,
      elapsedTime: provider.elapsedTimeInSeconds,
      moves: provider.moves,
      currentDifficulty: provider.difficulty,
      onDifficultyChanged: (newDifficulty) {
        _controller.changeDifficulty(newDifficulty);
      },
      onResume: () {
        _controller.togglePause();
      },
      onRestart: () {
        _controller.restartGame();
      },
    );
  }

  /// Manipula fim do jogo
  Future<void> _handleGameOver() async {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    
    // Atualiza estatísticas
    await _controller.updateGameStatistics();
    
    // Aguarda um pouco para permitir animações
    await Future.delayed(MemoryGameConfig.gameOverDelay);
    
    if (!mounted) return;
    
    // Mostra diálogo de fim do jogo
    DialogManager.showGameOverDialog(
      context: context,
      elapsedTime: provider.elapsedTimeInSeconds,
      moves: provider.moves,
      score: provider.calculateCurrentScore(),
      bestScore: provider.bestScore,
      isNewRecord: provider.isNewRecord(),
      onPlayAgain: () {
        _controller.restartGame();
      },
      onExit: () {
        Navigator.pop(context);
      },
    );
  }

  /// Manipula ações do menu
  void _handleMenuAction(String action, MemoryGameProvider provider) {
    if (action.startsWith('difficulty_')) {
      final difficultyName = action.substring(11);
      final difficulty = GameDifficulty.values
          .where((d) => d.name == difficultyName)
          .firstOrNull;
      
      if (difficulty != null) {
        _changeDifficulty(difficulty, provider);
      }
    } else {
      switch (action) {
        case 'restart':
          _handleRestart(provider);
          break;
        case 'statistics':
          _showStatistics();
          break;
        case 'help':
          _showHelp();
          break;
      }
    }
  }

  /// Muda dificuldade
  void _changeDifficulty(GameDifficulty newDifficulty, MemoryGameProvider provider) {
    if (provider.isGameStarted) {
      // Confirma mudança se jogo iniciado
      DialogManager.showDifficultyChangeDialog(
        context: context,
        onConfirm: () {
          _controller.changeDifficulty(newDifficulty);
        },
      );
    } else {
      _controller.changeDifficulty(newDifficulty);
    }
  }

  /// Manipula reiniciar
  void _handleRestart(MemoryGameProvider provider) {
    if (provider.isGameStarted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reiniciar Jogo'),
          content: const Text('Tem certeza que deseja reiniciar o jogo atual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.restartGame();
              },
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      );
    } else {
      _controller.restartGame();
    }
  }

  /// Mostra estatísticas
  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Map<String, int>>(
        future: _controller.getPlayerStatistics(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {};
          
          return AlertDialog(
            title: const Text('Estatísticas do Jogador'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jogos: ${stats['totalGames'] ?? 0}'),
                Text('Vitórias: ${stats['totalWins'] ?? 0}'),
                Text('Movimentos: ${stats['totalMoves'] ?? 0}'),
                Text('Tempo total: ${_formatTime(stats['totalTime'] ?? 0)}'),
                Text('Jogos perfeitos: ${stats['perfectGames'] ?? 0}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Mostra ajuda
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como Jogar'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Objetivo: Encontre todos os pares de cartas iguais.'),
            SizedBox(height: 8),
            Text('📱 Como jogar:'),
            Text('• Toque em uma carta para virá-la'),
            Text('• Toque em outra carta para formar um par'),
            Text('• Se as cartas forem iguais, elas permanecerão viradas'),
            Text('• Se forem diferentes, voltarão a ficar viradas para baixo'),
            SizedBox(height: 8),
            Text('🏆 Pontuação: Baseada no tempo, movimentos e dificuldade.'),
          ],
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

  /// Formata tempo em segundos para mm:ss
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
