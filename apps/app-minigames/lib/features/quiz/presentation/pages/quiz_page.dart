// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Presentation imports:
import '../providers/quiz_game_notifier.dart';

/// Quiz game page
class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(quizGameProvider);
    final notifier = ref.read(quizGameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.restartGame(),
          ),
        ],
      ),
      body: gameState.when(
        data: (state) {
          if (state.gameStatus.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.gameStatus.isGameOver) {
            return _buildGameOver(context, notifier, state.score, notifier.highScore);
          }

          final question = state.currentQuestion;
          if (question == null) {
            return const Center(child: Text('Nenhuma questão disponível'));
          }

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vidas: ${'❤️' * state.lives}'),
                    Text('Score: ${state.score}'),
                    Text('Tempo: ${state.timeLeft}s'),
                  ],
                ),
              ),

              // Progress
              LinearProgressIndicator(value: state.progress),

              const SizedBox(height: 24),

              // Question
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Questão ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.question,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    Color? buttonColor;

                    if (state.currentAnswerState.isCorrect && option == question.correctAnswer) {
                      buttonColor = Colors.green;
                    } else if (state.currentAnswerState.isIncorrect && option == question.correctAnswer) {
                      buttonColor = Colors.green;
                    }

                    return ElevatedButton(
                      onPressed: state.currentAnswerState.isNone
                          ? () => notifier.selectAnswer(option)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, QuizGameNotifier notifier, int score, int highScore) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text('Score: $score', style: const TextStyle(fontSize: 24)),
          Text('High Score: $highScore', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => notifier.restartGame(),
            child: const Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }
}
