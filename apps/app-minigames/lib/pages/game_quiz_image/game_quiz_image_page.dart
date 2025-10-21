// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'constants/enums.dart';
import 'models/game_logic.dart';
import 'widgets/answer_option_widget.dart';
import 'widgets/question_card_widget.dart';
import 'widgets/results_widget.dart';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  late QuizImageLogic gameLogic;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    gameLogic = QuizImageLogic();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        gameLogic.updateTimer();
      });
    });
  }

  void _selectAnswer(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      gameLogic.selectAnswer(index);
    });
  }

  void _restartGame({GameDifficulty? difficulty}) {
    setState(() {
      gameLogic.restart(newDifficulty: difficulty);
    });
  }

  void _startGame() {
    setState(() {
      gameLogic.startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header da página
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PageHeaderWidget(
                title: 'Quiz de Bandeiras',
                subtitle: 'Teste seu conhecimento sobre as bandeiras do mundo!',
                icon: Icons.flag,
                showBackButton: true,
                actions: [
                  PopupMenuButton<GameDifficulty>(
                    tooltip: 'Dificuldade',
                    icon: const Icon(Icons.settings),
                    onSelected: (difficulty) {
                      _restartGame(difficulty: difficulty);
                    },
                    itemBuilder: (context) => GameDifficulty.values
                        .map((difficulty) => PopupMenuItem(
                              value: difficulty,
                              child: Text(GameDifficultyExtension(difficulty).label),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Barra de progresso
            LinearProgressIndicator(
              value: gameLogic.progress,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),

            // Informações do jogo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contador de questões
                  Text(
                    'Questão ${gameLogic.currentQuestionIndex + 1}/${gameLogic.questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Timer
                  Row(
                    children: [
                      const Icon(Icons.timer),
                      const SizedBox(width: 4),
                      Text(
                        '${gameLogic.timeLeft}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gameLogic.timeLeft <= 5
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conteúdo principal do jogo
            Expanded(
              child: _buildGameContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    if (gameLogic.gameState == GameState.ready) {
      return _buildStartScreen();
    } else if (gameLogic.gameState == GameState.playing) {
      return _buildQuestionScreen();
    } else {
      return _buildResultsScreen();
    }
  }

  Widget _buildStartScreen() {
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
          const Text(
            'Quiz de Bandeiras',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Teste seu conhecimento sobre as bandeiras do mundo!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Iniciar Quiz',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dificuldade: ${GameDifficultyExtension(gameLogic.difficulty).label}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = gameLogic.currentQuestion;
    final isAnswered = question.isAnswered;
    final selectedAnswer = question.selectedAnswer;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cartão com a imagem e pergunta
            QuestionCardWidget(question: question),

            const SizedBox(height: 20),

            // Lista de opções
            ...List.generate(
              question.options.length,
              (index) {
                final option = question.options[index];
                final isSelected = selectedAnswer == option;
                final isCorrect = option == question.correctAnswer;

                // Define o estado da resposta
                AnswerState state = AnswerState.unanswered;
                if (isAnswered) {
                  if (isSelected) {
                    state =
                        isCorrect ? AnswerState.correct : AnswerState.incorrect;
                  } else if (isCorrect) {
                    state = AnswerState.correct;
                  }
                }

                return AnswerOptionWidget(
                  text: option,
                  index: index,
                  state: state,
                  isCorrect: isCorrect,
                  onTap: () => _selectAnswer(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Center(
      child: ResultsWidget(
        score: gameLogic.correctAnswers,
        totalQuestions: gameLogic.questions.length,
        highScore: gameLogic.highScore,
        onRestart: _restartGame,
      ),
    );
  }
}
