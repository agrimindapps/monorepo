// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
import '../providers/quiz_game_notifier.dart';

/// Quiz game page
class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(quizGameProvider);
    final notifier = ref.read(quizGameProvider.notifier);

    return GamePageLayout(
      title: 'Quiz',
      accentColor: const Color(0xFF2196F3),
      instructions: 'Teste seus conhecimentos!\n\n'
          '⏱️ Tempo limitado por questão\n'
          '❤️ Você tem 3 vidas\n'
          '⭐ Mais pontos por respostas rápidas\n'
          '🏆 Bata seu recorde!',
      maxGameWidth: 700,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reiniciar',
          onPressed: () => notifier.restartGame(),
        ),
      ],
      child: gameState.when(
        data: (state) {
          if (state.gameStatus.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          }

          if (state.gameStatus.isGameOver) {
            return _buildGameOver(context, notifier, state.score, notifier.highScore);
          }

          final question = state.currentQuestion;
          if (question == null) {
            return const Center(
              child: Text(
                'Nenhuma questão disponível',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

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
                        notifier.restartGame();
                      },
                      child: const Text('Reiniciar'),
                    ),
                  ],
                ),
              );
            },
            child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vidas: ${'❤️' * state.lives}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Score: ${state.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.timeLeft <= 5
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.timeLeft}s',
                        style: TextStyle(
                          color: state.timeLeft <= 5 ? Colors.red : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Progress
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 20),

              // Question
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Questão ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Options
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    Color buttonColor = Colors.white.withValues(alpha: 0.1);
                    Color textColor = Colors.white;

                    if (state.currentAnswerState.isCorrect && option == question.correctAnswer) {
                      buttonColor = Colors.green;
                    } else if (state.currentAnswerState.isIncorrect) {
                      if (option == question.correctAnswer) {
                        buttonColor = Colors.green;
                      }
                    }

                    return ElevatedButton(
                      onPressed: state.currentAnswerState.isNone
                          ? () {
                              HapticFeedback.selectionClick();
                              notifier.selectAnswer(option);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Erro: $error',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, QuizGameNotifier notifier, int score, int highScore) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 24),
          const Text(
            'Game Over!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: $score',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Recorde: $highScore',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (score >= highScore && score > 0) ...[
            const SizedBox(height: 8),
            const Text(
              '🎉 Novo Recorde!',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => notifier.restartGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Jogar Novamente',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
