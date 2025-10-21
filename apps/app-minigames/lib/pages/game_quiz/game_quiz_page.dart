// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'providers/quiz_provider.dart';
import 'widgets/options_grid.dart';
import 'widgets/question_card.dart';
import 'widgets/status_card.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizProvider()..loadQuestions(),
      child: const _QuizPageContent(),
    );
  }
}

class _QuizPageContent extends StatelessWidget {
  const _QuizPageContent();


  void _showGameOverDialog(BuildContext context, QuizProvider provider, bool completed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(completed ? 'Parabéns!' : 'Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pontuação final: ${provider.score}'),
            const SizedBox(height: 8),
            Text(completed
                ? 'Você completou todas as questões!'
                : 'Suas vidas acabaram!'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Jogar Novamente'),
            onPressed: () {
              Navigator.of(context).pop();
              provider.resetGame();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        // Show game over dialog when status changes to gameOver
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.gameStatus == QuizStatus.gameOver) {
            bool completed = provider.questions.isEmpty;
            _showGameOverDialog(context, provider, completed);
          }
        });

        if (provider.gameStatus == QuizStatus.loading ||
            provider.currentQuestion == null) {
          return const Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1020,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        PageHeaderWidget(
                          title: 'Quiz de Texto',
                          subtitle: 'Carregando...',
                          icon: Icons.quiz,
                          showBackButton: true,
                        ),
                        SizedBox(height: 50),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1020,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header da página
                      const PageHeaderWidget(
                        title: 'Quiz de Texto',
                        subtitle: 'Teste seus conhecimentos respondendo perguntas',
                        icon: Icons.quiz,
                        showBackButton: true,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusBar(provider),
                      const SizedBox(height: 32),
                      QuestionCard(
                          question: provider.currentQuestion!['descricao']),
                      const SizedBox(height: 32),
                      OptionsGrid(
                        options: List<String>.from(
                            provider.currentQuestion!['options']),
                        onOptionSelected: (option) =>
                            provider.processAnswer(option),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(QuizProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatusCard(
          icon: Icons.star,
          color: Colors.amber,
          label: 'Pontos',
          value: provider.score.toString(),
        ),
        StatusCard(
          icon: Icons.favorite,
          color: Colors.red,
          label: 'Vidas',
          value: provider.lives.toString(),
        ),
        StatusCard(
          icon: Icons.timer,
          color: Colors.blue,
          label: 'Tempo',
          value: '${provider.timeLeft} s',
        ),
      ],
    );
  }
}
