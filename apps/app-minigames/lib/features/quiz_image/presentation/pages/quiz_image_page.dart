import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
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

    return GamePageLayout(
      title: 'Quiz de Bandeiras',
      accentColor: const Color(0xFF3F51B5),
      instructions: 'Identifique a bandeira!\n\n'
          '🏳️ Observe a imagem da bandeira\n'
          '⏱️ Tempo limitado por questão\n'
          '✅ Escolha o país correto\n'
          '🎯 10 questões por partida',
      maxGameWidth: 700,
      child: gameStateAsync.when(
        data: (gameState) {
          // Ready state - show start button
          if (gameState.gameState == GameStateEnum.ready) {
            return _buildReadyView(context, ref);
          }

          // Game over state - show results
          if (gameState.gameState == GameStateEnum.gameOver) {
            final notifier = ref.read(quizImageProvider(difficulty).notifier);
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
          child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar jogo',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(quizImageProvider(difficulty)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                ),
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
          const Icon(Icons.flag, size: 80, color: Color(0xFF3F51B5)),
          const SizedBox(height: 24),
          const Text(
            'Quiz de Bandeiras',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dificuldade: ${_getDifficultyName(difficulty)}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '10 questões • ${difficulty.timeLimit}s por questão',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(quizImageProvider(difficulty).notifier).startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text('Começar', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(BuildContext context, WidgetRef ref, dynamic gameState) {
    final question = gameState.currentQuestion;
    final currentIndex = gameState.currentQuestionIndex;
    final totalQuestions = gameState.questions.length;

    return EscKeyboardWrapper(
      onEscPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Pausado'),
            content: const Text('Pressione ESC para continuar ou Reiniciar'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(quizImageProvider(gameState.difficulty).notifier).restartGame();
                },
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Questão ${currentIndex + 1} de $totalQuestions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Acertos: ${gameState.correctAnswers}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: gameState.progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              TimerWidget(
                timeLeft: gameState.timeLeft,
                totalTime: gameState.difficulty.timeLimit,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Question and answers
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                QuestionCardWidget(question: question),
                const SizedBox(height: 16),
                ...List.generate(
                  question.options.length,
                  (index) {
                    final option = question.options[index];
                    final isSelected = gameState.currentSelectedAnswer == option;
                    final isCorrect = question.correctAnswer == option;

                    return AnswerOptionWidget(
                      text: option,
                      index: index,
                      answerState: gameState.currentAnswerState,
                      isSelected: isSelected,
                      isCorrectAnswer: isCorrect,
                      onTap: gameState.currentAnswerState == AnswerState.unanswered
                          ? () {
                              ref
                                  .read(quizImageProvider(difficulty).notifier)
                                  .selectAnswer(option);
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
      ),
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
