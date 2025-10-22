// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Presentation imports:
import '../providers/flappbird_notifier.dart';
import '../widgets/bird_widget.dart';
import '../widgets/pipe_widget.dart';
import '../widgets/background_widget.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/game_over_dialog.dart';

/// Main Flappy Bird game page
class FlappbirdPage extends ConsumerStatefulWidget {
  const FlappbirdPage({super.key});

  @override
  ConsumerState<FlappbirdPage> createState() => _FlappbirdPageState();
}

class _FlappbirdPageState extends ConsumerState<FlappbirdPage> {
  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(flappbirdGameNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update screen dimensions when layout changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(flappbirdGameNotifierProvider.notifier)
                .updateScreenDimensions(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
          });

          return gameStateAsync.when(
            data: (gameState) {
              return GestureDetector(
                onTap: () {
                  ref.read(flappbirdGameNotifierProvider.notifier).flap();
                },
                child: Stack(
                  children: [
                    // Background (clouds, etc.)
                    const BackgroundWidget(),

                    // Pipes
                    ...gameState.pipes.map((pipe) {
                      return PipeWidget(
                        pipe: pipe,
                        screenWidth: gameState.screenWidth,
                        screenHeight: gameState.playAreaHeight,
                      );
                    }),

                    // Bird
                    BirdWidget(
                      bird: gameState.bird,
                      birdX: gameState.birdX,
                      screenHeight: gameState.playAreaHeight,
                    ),

                    // Ground
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: gameState.groundHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513), // Brown
                          border: Border(
                            top: BorderSide(
                              color: Colors.brown.shade800,
                              width: 5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Score display
                    ScoreDisplayWidget(
                      score: gameState.score,
                      highScore: ref.read(flappbirdGameNotifierProvider.notifier).highScore,
                    ),

                    // Game over dialog
                    if (gameState.isGameOver)
                      GameOverDialog(
                        score: gameState.score,
                        highScore: ref.read(flappbirdGameNotifierProvider.notifier).highScore,
                        onRestart: () {
                          ref
                              .read(flappbirdGameNotifierProvider.notifier)
                              .restartGame();
                        },
                      ),

                    // Start instruction
                    if (gameState.status.isNotStarted)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Tap to Start',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(flappbirdGameNotifierProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
