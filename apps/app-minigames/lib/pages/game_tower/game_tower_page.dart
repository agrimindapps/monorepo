// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'models/game_logic.dart';
import 'widgets/block_widget.dart';
import 'widgets/clouds_background.dart';

class TowerStackGame extends StatefulWidget {
  const TowerStackGame({super.key});

  @override
  State<TowerStackGame> createState() => _TowerStackGameState();
}

class _TowerStackGameState extends State<TowerStackGame>
    with SingleTickerProviderStateMixin {
  late TowerGameLogic gameLogic;
  double screenWidth = 0;
  Timer? gameTimer;
  AnimationController? _comboAnimController;
  Animation<double>? _comboAnimation;

  @override
  void initState() {
    super.initState();
    _comboAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _comboAnimation = CurvedAnimation(
      parent: _comboAnimController!,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      gameLogic = TowerGameLogic(blockWidth: 200.0, screenWidth: screenWidth);
      gameLogic.loadHighScore();
      startMovingBlock();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _comboAnimController?.dispose();
    super.dispose();
  }

  void startMovingBlock() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || gameLogic.isPaused) return;
      setState(() {
        gameLogic.updateMovingBlock();
      });
    });
  }

  void dropBlock() {
    if (gameLogic.isPaused || gameLogic.isGameOver) return;

    final bool success = gameLogic.dropBlock();

    if (!success) {
      // Game Over
      showGameOverDialog();
      HapticFeedback.heavyImpact(); // Vibração forte para game over
    } else {
      // Block placed successfully
      HapticFeedback.mediumImpact(); // Vibração média para colocação normal

      // Se foi uma colocação perfeita
      if (gameLogic.isPerfectPlacement) {
        showPerfectText();
        _comboAnimController?.reset();
        _comboAnimController?.forward();

        // Vibração extra para colocação perfeita
        if (gameLogic.combo > 1) {
          HapticFeedback.heavyImpact();
        }
      }
    }
  }

  void showPerfectText() {
    String message = gameLogic.combo > 1
        ? 'Perfeito! Combo x${gameLogic.combo}'
        : 'Perfeito!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: gameLogic.combo > 2 ? Colors.purple : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void showGameOverDialog() {
    gameLogic.saveHighScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sua pontuação: ${gameLogic.score}'),
            Text('Melhor pontuação: ${gameLogic.highScore}'),
            const SizedBox(height: 10),
            Text('Maior combo: ${gameLogic.combo}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              restartGame();
            },
            child: const Text('Tentar Novamente'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void pauseGame() {
    setState(() {
      gameLogic.togglePause();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Jogo Pausado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pontuação atual: ${gameLogic.score}'),
            Text(
                'Combo atual: ${gameLogic.combo > 1 ? gameLogic.combo : "Nenhum"}'),
            const SizedBox(height: 10),
            DropdownButton<GameDifficulty>(
              value: gameLogic.difficulty,
              items: GameDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.label),
                );
              }).toList(),
              onChanged: (newDifficulty) {
                if (newDifficulty != null) {
                  setState(() {
                    gameLogic.difficulty = newDifficulty;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resumeGame();
            },
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              restartGame();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void resumeGame() {
    setState(() {
      gameLogic.togglePause();
    });
    startMovingBlock();
  }

  void restartGame() {
    setState(() {
      gameLogic.startNewGame();
    });
    startMovingBlock();
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
              title: 'Tower Stack',
              subtitle: 'Pontuação: ${gameLogic.score}',
              icon: Icons.architecture,
              showBackButton: true,
              actions: [
                // Exibir o combo atual se existir
                if (gameLogic.combo > 1)
                  Center(
                    child: AnimatedBuilder(
                        animation: _comboAnimation!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_comboAnimation!.value * 0.3),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Combo x${gameLogic.combo}',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 + (gameLogic.combo > 3 ? 2 : 0),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: pauseGame,
                ),
              ],
            ),
          ),
          // Área do jogo
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlue[200]!, Colors.blue[800]!],
                ),
              ),
              child: Stack(
                children: [
            // Fundo com nuvens
            const Positioned.fill(
              child: CloudsBackgroundWidget(),
            ),

            // Mostrar informação de dificuldade atual
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Dificuldade: ${gameLogic.getDifficultyLabel()}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Blocos empilhados
            ..._buildBlocks(),

            // Bloco em movimento
            Positioned(
              left: gameLogic.posX,
              bottom: gameLogic.blocks.length * gameLogic.blockHeight,
              child: GestureDetector(
                onTap: dropBlock,
                child: BlockWidget(
                  width: gameLogic.blockWidth,
                  height: gameLogic.blockHeight,
                  color: gameLogic.getNextBlockColor(),
                  isMoving: true,
                ),
              ),
            ),

            // Área de toque para o jogo inteiro
            Positioned.fill(
              child: GestureDetector(
                onTap: dropBlock,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlocks() {
    return List.generate(gameLogic.blocks.length, (index) {
      final block = gameLogic.blocks[index];
      return Positioned(
        left: block.posX,
        bottom: index * block.height,
        child: BlockWidget(
          width: block.width,
          height: block.height,
          color: block.color,
        ),
      );
    });
  }
}
