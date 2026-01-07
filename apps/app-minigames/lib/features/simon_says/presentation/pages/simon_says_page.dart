import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/simon_says_controller.dart';
import '../widgets/simon_button.dart';

class SimonSaysPage extends ConsumerWidget {
  const SimonSaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simonSaysControllerProvider);
    final notifier = ref.read(simonSaysControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Simon Says'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score Display
            Text(
              'Score: ${state.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status Message
            Text(
              _getStatusMessage(state.gameState),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),

            // Game Board
            SizedBox(
              width: 320,
              height: 320,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.all(16),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SimonButton(
                    index: 0,
                    color: Colors.green,
                    isActive: state.activeIndex == 0,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(0),
                  ),
                  SimonButton(
                    index: 1,
                    color: Colors.red,
                    isActive: state.activeIndex == 1,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(1),
                  ),
                  SimonButton(
                    index: 2,
                    color: Colors.yellow,
                    isActive: state.activeIndex == 2,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(2),
                  ),
                  SimonButton(
                    index: 3,
                    color: Colors.blue,
                    isActive: state.activeIndex == 3,
                    enabled: state.gameState == SimonGameState.waitingForInput,
                    onTap: () => notifier.handleInput(3),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Controls
            if (state.gameState == SimonGameState.idle || 
                state.gameState == SimonGameState.gameOver)
              ElevatedButton(
                onPressed: () => notifier.startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: Text(
                  state.gameState == SimonGameState.idle ? 'START' : 'TRY AGAIN',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(SimonGameState state) {
    switch (state) {
      case SimonGameState.idle:
        return 'Tap Start to play';
      case SimonGameState.showingSequence:
        return 'Watch carefully...';
      case SimonGameState.waitingForInput:
        return 'Your turn!';
      case SimonGameState.gameOver:
        return 'Game Over!';
    }
  }
}
