import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../providers/quiz_image_notifier.dart';
import '../widgets/question_card_widget.dart';
import '../widgets/answer_option_widget.dart';
import '../widgets/timer_widget.dart';
import '../widgets/results_widget.dart';

/// Main page for Quiz Image game
/// Displays questions with images and multiple choice answers
class QuizImagePage extends ConsumerWidget {
  final GameDifficulty difficulty;

  const QuizImagePage({
    super.key,
    this.difficulty = GameDifficulty.medium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(quizImageProvider(difficulty));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz de Bandeiras'),
        centerTitle: true,
      ),
      body: gameStateAsync.when(
        data: (gameState) {
          // Ready state - show start button
          if (gameState.gameState == GameStateEnum.ready) {
            return _buildReadyView(context, ref);
          }

          // Game over state - show results
          if (gameState.gameState == GameStateEnum.gameOver) {
            final notifier =
                ref.read(quizImageProvider(difficulty).notifier);
            return Center(
              child: ResultsWidget(
                score: gameState.correctAnswers,
                totalQuestions: gameState.questions.length,
                highScore: notifier.highScore,
                onRestart: () => notifier.restartGame(),
              ),
            );
          }

          // Playing state - show quiz
          return _buildQuizView(context, ref, gameState);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar jogo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(quizImageProvider(difficulty));
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flag,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz de Bandeiras',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dificuldade: ${_getDifficultyName(difficulty)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '10 questões • ${difficulty.timeLimit}s por questão',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(quizImageProvider(difficulty).notifier)
                  .startGame();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text(
                  'Começar',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    WidgetRef ref,
    dynamic gameState,
  ) {
    final question = gameState.currentQuestion;
    final currentIndex = gameState.currentQuestionIndex;
    final totalQuestions = gameState.questions.length;

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Questão ${currentIndex + 1} de $totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Acertos: ${gameState.correctAnswers}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: gameState.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 12),
              TimerWidget(
                timeLeft: gameState.timeLeft,
                totalTime: gameState.difficulty.timeLimit,
              ),
            ],
          ),
        ),

        // Question and answers
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                QuestionCardWidget(question: question),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(
                      question.options.length,
                      (index) {
                        final option = question.options[index];
                        final isSelected =
                            gameState.currentSelectedAnswer == option;
                        final isCorrect = question.correctAnswer == option;

                        return AnswerOptionWidget(
                          text: option,
                          index: index,
                          answerState: gameState.currentAnswerState,
                          isSelected: isSelected,
                          isCorrectAnswer: isCorrect,
                          onTap: gameState.currentAnswerState ==
                                  AnswerState.unanswered
                              ? () {
                                  ref
                                      .read(quizImageProvider(difficulty)
                                          .notifier)
                                      .selectAnswer(option);
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDifficultyName(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Fácil';
      case GameDifficulty.medium:
        return 'Médio';
      case GameDifficulty.hard:
        return 'Difícil';
    }
  }
}
