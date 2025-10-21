// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'constants/game_config.dart';
import 'controllers/game_controller.dart';
import 'utils/format_utils.dart';
import 'widgets/dialogs/confirmation_dialog.dart';
import 'widgets/dialogs/game_over_dialog.dart';
import 'widgets/dialogs/game_win_dialog.dart';
import 'widgets/dialogs/settings_dialog.dart';
import 'widgets/game_controls_widget.dart';
import 'widgets/game_gesture_detector.dart';
import 'widgets/tile_widget.dart';

/**
 * Página principal do jogo 2048 refatorada com padrão MVC
 * Utiliza Game2048Controller para gerenciar estado e lógica
 * Configurações centralizadas em Game2048Config
 */

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> with WidgetsBindingObserver {
  late Game2048Controller _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Game2048Controller();
    _controller.addListener(_onGameStateChanged);
    _ensureFocus();
    _checkForSavedGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
      _handleGameEvents();
    }
  }

  void _handleGameEvents() {
    // Manipular eventos de vitória/game over
    if (_controller.hasWon && !_controller.isGameOver) {
      _showWinDialog();
    } else if (_controller.isGameOver) {
      _showGameOverDialog();
    }
  }

  void _ensureFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Manipula input do teclado
  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_controller.isGameOver || _controller.isLoading || _controller.isPaused) return false;

    Direction? direction;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        direction = Direction.up;
        break;
      case LogicalKeyboardKey.arrowDown:
        direction = Direction.down;
        break;
      case LogicalKeyboardKey.arrowLeft:
        direction = Direction.left;
        break;
      case LogicalKeyboardKey.arrowRight:
        direction = Direction.right;
        break;
      default:
        return false;
    }

    _controller.makeMove(direction);
    return true;
      return false;
  }

  /// Manipula gestos de swipe
  void _handleSwipe(Direction direction) {
    if (_controller.isGameOver || _controller.isLoading || _controller.isPaused) return;
    _controller.makeMove(direction);
  }

  /// Exibe dialog de vitória
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameWinDialog(
        currentScore: _controller.currentScore,
        moveCount: _controller.moveCount,
        gameDuration: _controller.gameDuration,
        onNewGame: () {
          Navigator.of(context).pop();
          _controller.startNewGame();
        },
        onContinue: () {
          Navigator.of(context).pop();
          // Continuar jogando
        },
      ),
    );
  }

  /// Exibe dialog de game over
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        finalScore: _controller.currentScore,
        highScore: _controller.statistics.highScore,
        moveCount: _controller.moveCount,
        gameDuration: _controller.gameDuration,
        onPlayAgain: () {
          Navigator.of(context).pop();
          _controller.startNewGame();
        },
      ),
    );
  }

  /// Verifica se há progresso significativo que justifica confirmação
  bool _hasSignificantProgress() {
    return !_controller.isGameOver && 
           (_controller.moveCount > 0 || _controller.currentScore > 0);
  }

  /// Cria objeto ProgressInfo com o estado atual do jogo
  ProgressInfo _getCurrentProgressInfo() {
    return ProgressInfo(
      score: _controller.currentScore,
      moveCount: _controller.moveCount,
      duration: FormatUtils.formatDuration(_controller.gameDuration),
      isHighScore: _controller.currentScore > _controller.statistics.highScore,
    );
  }

  /// Manipula novo jogo com confirmação se necessário
  Future<void> _handleNewGame() async {
    if (_hasSignificantProgress()) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        type: ConfirmationType.newGame,
        progressInfo: _getCurrentProgressInfo(),
        onConfirm: () => _controller.startNewGame(),
      );
      
      if (confirmed != true) return;
    } else {
      _controller.startNewGame();
    }
  }

  /// Manipula mudança de tamanho do tabuleiro com confirmação se necessário
  Future<void> _handleBoardSizeChange(BoardSize newSize) async {
    if (_hasSignificantProgress()) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        type: ConfirmationType.changeBoardSize,
        progressInfo: _getCurrentProgressInfo(),
        onConfirm: () => _controller.changeBoardSize(newSize),
        customMessage: 'Alterar para tabuleiro ${newSize.label} irá iniciar um novo jogo e você perderá todo o progresso atual.',
      );
      
      if (confirmed != true) return;
    } else {
      _controller.changeBoardSize(newSize);
    }
  }

  /// Mostra dialog de configurações
  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        currentColorScheme: _controller.currentColorScheme,
        currentBoardSize: _controller.currentBoardSize,
        soundEnabled: _controller.soundEnabled,
        vibrationEnabled: _controller.vibrationEnabled,
        autoSaveSettings: _controller.autoSaveSettings,
        onColorSchemeChanged: (scheme) => _controller.changeColorScheme(scheme),
        onBoardSizeChanged: _handleBoardSizeChange,
        onSoundChanged: (enabled) => _controller.toggleSound(),
        onVibrationChanged: (enabled) => _controller.toggleVibration(),
        onAutoSaveSettingsChanged: (settings) => _controller.updateAutoSaveSettings(settings),
      ),
    );
  }

  /// Manipula mudanças no lifecycle da aplicação
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Salvar automaticamente quando app vai para background
        _controller.forceAutoSave();
        break;
      case AppLifecycleState.resumed:
        // Verificar se existe jogo salvo para restaurar
        _checkForSavedGame();
        break;
      case AppLifecycleState.detached:
        // App sendo fechado
        _controller.forceAutoSave();
        break;
      case AppLifecycleState.hidden:
        // App está oculto
        break;
    }
  }

  /// Verifica se existe jogo salvo e oferece restauração
  Future<void> _checkForSavedGame() async {
    // Aguardar um pouco para garantir que a inicialização terminou
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final hasSaved = await _controller.hasSavedGame;
      if (hasSaved && mounted) {
        _showRestoreGameDialog();
      }
    } catch (error) {
      debugPrint('Erro ao verificar jogo salvo: $error');
    }
  }

  /// Exibe dialog para restaurar jogo salvo
  void _showRestoreGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Colors.blue),
            SizedBox(width: 12),
            Text('Continuar Jogo?'),
          ],
        ),
        content: const Text(
          'Encontramos um jogo salvo automaticamente. Deseja continuar de onde parou ou iniciar um novo jogo?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _controller.clearSavedGame();
              _controller.startNewGame();
            },
            child: const Text('Novo Jogo'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final restored = await _controller.restoreSavedGame();
              if (!restored) {
                // Se falhou ao restaurar, iniciar novo jogo
                _controller.startNewGame();
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  /// Manipula tentativa de sair da página
  Future<bool> _handleWillPop() async {
    if (_hasSignificantProgress()) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        type: ConfirmationType.exitGame,
        progressInfo: _getCurrentProgressInfo(),
        onConfirm: () {
          // Salvar o jogo antes de sair
          _controller.forceAutoSave();
        },
      );
      
      return confirmed == true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Obter configurações responsivas
    final config = Game2048Config.forScreenSize(MediaQuery.of(context).size);
    final gameBoard = _controller.gameBoard;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _handleWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) => _handleKeyEvent(event)
            ? KeyEventResult.handled
            : KeyEventResult.ignored,
        child: Center(
          child: Container(
            width: config.maxGameWidth,
            padding: EdgeInsets.all(config.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header da página
                PageHeaderWidget(
                  title: '2048',
                  subtitle: 'Combine os números para chegar ao 2048!',
                  icon: Icons.grid_4x4,
                  showBackButton: true,
                  actions: [
                    if (_controller.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                
                SizedBox(height: config.spacing),
                // Controles do jogo
                GameControlsWidget(
                  currentScore: _controller.currentScore,
                  highScore: _controller.statistics.highScore,
                  currentColorScheme: _controller.currentColorScheme,
                  currentBoardSize: _controller.currentBoardSize,
                  moveCount: _controller.moveCount,
                  gameDuration: _controller.gameDuration,
                  enabled: !_controller.isLoading,
                  isPaused: _controller.isPaused,
                  canUndo: _controller.canUndo,
                  canRedo: _controller.canRedo,
                  onNewGame: _handleNewGame,
                  onColorSchemeChanged: (scheme) =>
                      _controller.changeColorScheme(scheme),
                  onBoardSizeChanged: _handleBoardSizeChange,
                  onTogglePause: () => _controller.togglePause(),
                  onUndo: () => _controller.undoLastMove(),
                  onRedo: () => _controller.redoLastMove(),
                  onShowSettings: _showSettingsDialog,
                ),

                SizedBox(height: config.spacing),

                // Tabuleiro do jogo
                Stack(
                  children: [
                    GameGestureDetector(
                      onSwipe: _handleSwipe,
                      child: Container(
                        width: config.boardSize,
                        height: config.boardSize,
                        padding: EdgeInsets.all(config.tilePadding),
                        decoration: BoxDecoration(
                          color: Game2048Config.boardBackgroundColor,
                          borderRadius: BorderRadius.circular(config.borderRadius),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _controller.currentBoardSize.size,
                            crossAxisSpacing: config.tilePadding,
                            mainAxisSpacing: config.tilePadding,
                          ),
                          itemCount: _controller.currentBoardSize.size *
                              _controller.currentBoardSize.size,
                          itemBuilder: (context, index) {
                            final row = index ~/ _controller.currentBoardSize.size;
                            final col = index % _controller.currentBoardSize.size;
                            final value = gameBoard.board[row][col];

                            return TileWidget(
                              value: value,
                              colorScheme: _controller.currentColorScheme,
                              size: config.tileSize,
                              fontSize: config.tileFontSize,
                              isNew: gameBoard.getAllTilePositions().any(
                                (pos) =>
                                    pos.row == row && pos.col == col && pos.isNew,
                              ),
                              isMerging: gameBoard.getAllTilePositions().any(
                                (pos) =>
                                    pos.row == row && pos.col == col && pos.isMerging,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Overlay de pausa
                    if (_controller.isPaused)
                      Container(
                        width: config.boardSize,
                        height: config.boardSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(config.borderRadius),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pause_circle_filled,
                                size: 64,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'JOGO PAUSADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toque em "Continuar" para retomar',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: config.spacing),

                // Instruções do jogo
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(config.padding),
                    child: Column(
                      children: [
                        Text(
                          'Como Jogar',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use as setas do teclado ou gestos para mover as peças.\n'
                          'Combine números iguais para alcançar 2048!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // Exibir erro se houver
                if (_controller.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: config.spacing),
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: EdgeInsets.all(config.padding),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _controller.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
