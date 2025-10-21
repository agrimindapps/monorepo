// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'models/game_logic.dart';
import 'pages/settings_page.dart';
import 'widgets/dialogs/game_over_dialog.dart';
import 'widgets/dialogs/pause_dialog.dart';
import 'widgets/game_grid_widget.dart';

// Intents para controle por teclado
class MoveUpIntent extends Intent {}
class MoveDownIntent extends Intent {}
class MoveLeftIntent extends Intent {}
class MoveRightIntent extends Intent {}
class PauseGameIntent extends Intent {}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  late SnakeGameLogic gameLogic;
  Timer? gameTimer;
  final bool _swipeEnabled = true; // Configuração para habilitar/desabilitar swipe
  
  // Mapa de teclas para controle
  late Map<LogicalKeySet, Intent> _shortcuts;
  late Map<Type, Action<Intent>> _actions;

  @override
  void initState() {
    super.initState();
    gameLogic = SnakeGameLogic();
    gameLogic.initializeGame();
    gameLogic.loadHighScore();
    gameLogic.loadStatistics();
    gameLogic.loadUserSettings(); // Carrega configurações salvas
    _initializeKeyboardControls();
    
    // Configura callback para atualização de velocidade
    gameLogic.onGameSpeedChanged = _updateGameSpeed;
  }
  
  void _initializeKeyboardControls() {
    // Configuração dos atalhos de teclado
    _shortcuts = {
      // Setas do teclado
      LogicalKeySet(LogicalKeyboardKey.arrowUp): MoveUpIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowDown): MoveDownIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): MoveLeftIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): MoveRightIntent(),
      
      // WASD (alternativa popular para jogos)
      LogicalKeySet(LogicalKeyboardKey.keyW): MoveUpIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyS): MoveDownIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyA): MoveLeftIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyD): MoveRightIntent(),
      
      // Teclas de pausa
      LogicalKeySet(LogicalKeyboardKey.space): PauseGameIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyP): PauseGameIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): PauseGameIntent(),
    };
    
    // Configuração das ações
    _actions = {
      MoveUpIntent: CallbackAction<MoveUpIntent>(
        onInvoke: (_) => _handleKeyboardDirection(Direction.up),
      ),
      MoveDownIntent: CallbackAction<MoveDownIntent>(
        onInvoke: (_) => _handleKeyboardDirection(Direction.down),
      ),
      MoveLeftIntent: CallbackAction<MoveLeftIntent>(
        onInvoke: (_) => _handleKeyboardDirection(Direction.left),
      ),
      MoveRightIntent: CallbackAction<MoveRightIntent>(
        onInvoke: (_) => _handleKeyboardDirection(Direction.right),
      ),
      PauseGameIntent: CallbackAction<PauseGameIntent>(
        onInvoke: (_) => _handleKeyboardPause(),
      ),
    };
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    gameLogic.dispose();
    super.dispose();
  }

  void _startGame() {
    // Cancela o timer existente se houver
    gameTimer?.cancel();

    // Inicia um novo timer usando método extraído
    _startGameTimer();

    setState(() {
      gameLogic.startGame();
    });
  }

  void _handleGameOver() {
    gameTimer?.cancel();
    HapticFeedback.heavyImpact();
    gameLogic.saveHighScore();
    gameLogic.saveGameStatistics();

    // Mostra diálogo de fim de jogo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameOverDialog(
          score: gameLogic.score,
          highScore: gameLogic.highScore,
          onPlayAgain: () {
            Navigator.pop(context);
            _restartGame();
          },
          onExit: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void _pauseGame() {
    gameTimer?.cancel();

    setState(() {
      gameLogic.togglePause();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PauseDialog(
        score: gameLogic.score,
        difficulty: gameLogic.difficulty,
        onResume: () {
          Navigator.pop(context);
          _resumeGame();
        },
        onRestart: () {
          Navigator.pop(context);
          _restartGame();
        },
        onDifficultyChanged: (newDifficulty) {
          setState(() {
            gameLogic.updateDifficulty(newDifficulty);
          });
        },
      ),
    );
  }

  void _resumeGame() {
    setState(() {
      gameLogic.togglePause();

      if (gameLogic.isGameStarted && !gameLogic.isPaused) {
        _startGameTimer(); // Usa método extraído que respeita dificuldade atual
      }
    });
  }

  void _restartGame() {
    gameTimer?.cancel();
    setState(() {
      gameLogic.restartGame();
    });
  }

  void _changeDirection(Direction direction) {
    if (!gameLogic.isGameStarted) {
      _startGame();
    }

    setState(() {
      gameLogic.changeDirection(direction);
    });
  }
  
  // Handlers para controle por teclado
  void _handleKeyboardDirection(Direction direction) {
    // Só processa se o jogo está ativo ou pode ser iniciado
    if (gameLogic.isGameOver) return;
    
    _changeDirection(direction);
  }
  
  void _handleKeyboardPause() {
    // Só permite pausar se o jogo está rodando
    if (gameLogic.isGameStarted && !gameLogic.isGameOver) {
      _pauseGame();
    }
  }
  
  // Handler para controle por swipe
  void _handleSwipeDirection(Direction direction) {
    // Só processa se o jogo está ativo ou pode ser iniciado
    if (gameLogic.isGameOver) return;
    
    _changeDirection(direction);
  }
  
  // Atualiza velocidade do jogo quando dificuldade muda
  void _updateGameSpeed() {
    // Se o jogo está rodando, reinicia o timer com nova velocidade
    if (gameLogic.gameState.isPlayable && gameTimer != null) {
      gameTimer?.cancel();
      _startGameTimer();
    }
  }
  
  // Extrai lógica do timer para reutilização
  void _startGameTimer() {
    gameTimer = Timer.periodic(gameLogic.currentGameSpeed, (timer) {
      if (!mounted) return;
      setState(() {
        gameLogic.moveSnake();

        // Verifica se o jogo acabou
        if (gameLogic.isGameOver) {
          _handleGameOver();
        }
      });
    });
  }

  Future<bool> _onWillPop() async {
    // Se o jogo está rodando, pausa em vez de sair
    if (gameLogic.isGameStarted && !gameLogic.isGameOver && !gameLogic.isPaused) {
      _pauseGame();
      return false; // Não sai do app
    }
    
    // Se já está pausado ou não iniciado, confirma saída
    if (gameLogic.isPaused || !gameLogic.isGameStarted) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sair do Jogo'),
          content: const Text('Deseja realmente sair do jogo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    
    return true; // Permite sair normalmente
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            navigator.pop();
          }
        }
      },
      child: Shortcuts(
        shortcuts: _shortcuts,
        child: Actions(
          actions: _actions,
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    // Header da página
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PageHeaderWidget(
                        title: 'Snake',
                        subtitle: 'Pontuação: ${gameLogic.score}',
                        icon: Icons.line_style,
                        showBackButton: true,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(gameLogic: gameLogic),
                                ),
                              );
                            },
                            tooltip: 'Configurações',
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: gameLogic.isGameStarted && !gameLogic.isGameOver
                                ? _pauseGame
                                : null,
                            tooltip: 'Pausar',
                          ),
                        ],
                      ),
                    ),
                    // Pontuação e área de jogo
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Grid do jogo
                            GameGridWidget(
                              gameLogic: gameLogic,
                              onSwipe: _handleSwipeDirection,
                              swipeEnabled: _swipeEnabled,
                            ),

                            // Instruções ou botão de início
                            if (!gameLogic.isGameStarted) ...[
                              ElevatedButton(
                                onPressed: _startGame,
                                child: const Text('Iniciar Jogo'),
                              ),
                              const SizedBox(height: 16),
                              _buildKeyboardInstructions(),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Controles direcionais
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Botão para cima
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _directionButton(
                                icon: Icons.arrow_upward,
                                onPressed: () => _changeDirection(Direction.up),
                              ),
                            ],
                          ),

                          // Botões esquerda e direita
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _directionButton(
                                icon: Icons.arrow_back,
                                onPressed: () => _changeDirection(Direction.left),
                              ),
                              const SizedBox(width: 50),
                              _directionButton(
                                icon: Icons.arrow_forward,
                                onPressed: () => _changeDirection(Direction.right),
                              ),
                            ],
                          ),

                          // Botão para baixo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _directionButton(
                                icon: Icons.arrow_downward,
                                onPressed: () => _changeDirection(Direction.down),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _directionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildKeyboardInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Controles de Teclado',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyHint('↑ ↓ ← →', 'Setas'),
              _buildKeyHint('W A S D', 'WASD'),
              _buildKeyHint('👆 Swipe', 'Gestos'),
              _buildKeyHint('SPACE / P', 'Pausar'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildKeyHint(String keys, String description) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            keys,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
