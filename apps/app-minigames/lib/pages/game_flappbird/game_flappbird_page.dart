// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'providers/game_state_provider.dart';
import 'widgets/game_renderer.dart';

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late GameStateProvider _gameStateProvider;
  
  // Animação do batimento de asas
  AnimationController? _flapController;
  Animation<double>? _flapAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameStateProvider = GameStateProvider();

    // Configura a animação do bater de asas
    _flapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flapAnimation = Tween<double>(begin: 0, end: 0.2).animate(_flapController!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _flapController!.reverse();
        }
      });
    
    // Set animation controller in provider
    _gameStateProvider.setAnimationController(_flapController!, _flapAnimation!, this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameStateProvider.dispose();
    _flapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _gameStateProvider.pauseGame();
        break;
      case AppLifecycleState.resumed:
        // Don't auto-resume, let user decide
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }


  void _onTap() {
    _gameStateProvider.jump();
  }

  void _changeDifficulty(GameDifficulty newDifficulty) {
    _gameStateProvider.changeDifficulty(newDifficulty);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gameHeight = size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    if (!_gameStateProvider.gameState.isInitialized) {
      _gameStateProvider.initialize(
        screenWidth: size.width,
        screenHeight: gameHeight,
      );
    }

    return ChangeNotifierProvider.value(
      value: _gameStateProvider,
      child: Scaffold(
        body: Column(
          children: [
            // Header da página
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PageHeaderWidget(
                title: 'Flappy Bird',
                subtitle: 'Voe entre os obstáculos e marque pontos',
                icon: Icons.flight,
                showBackButton: true,
                actions: [
                  Consumer<GameStateProvider>(
                    builder: (context, gameStateProvider, child) {
                      if (gameStateProvider.gameState.gameState == GameState.playing) {
                        return IconButton(
                          onPressed: () {
                            if (gameStateProvider.gameState.isPaused) {
                              gameStateProvider.resumeGame();
                            } else {
                              gameStateProvider.pauseGame();
                            }
                          },
                          icon: Icon(
                            gameStateProvider.gameState.isPaused 
                                ? Icons.play_arrow 
                                : Icons.pause
                          ),
                          tooltip: gameStateProvider.gameState.isPaused 
                              ? 'Retomar' 
                              : 'Pausar',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  PopupMenuButton<GameDifficulty>(
                    tooltip: 'Dificuldade',
                    icon: const Icon(Icons.settings),
                    onSelected: _changeDifficulty,
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
            // Área do jogo
            Expanded(
              child: GestureDetector(
                onTap: _onTap,
                child: Consumer<GameStateProvider>(
                  builder: (context, gameStateProvider, child) {
                    if (!gameStateProvider.gameState.isInitialized || gameStateProvider.gameLogic == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return GameRenderer(
                      gameLogic: gameStateProvider.gameLogic!,
                      flapAnimation: gameStateProvider.flapAnimation,
                      flapController: gameStateProvider.flapController,
                      isPaused: gameStateProvider.gameState.isPaused,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
