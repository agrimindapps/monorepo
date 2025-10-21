// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'question.dart';

class QuizImageLogic {
  // Configurações
  GameDifficulty difficulty;
  GameState gameState = GameState.ready;

  // Estado do jogo
  late List<QuizQuestion> questions;
  int currentQuestionIndex = 0;
  int timeLeft = 0;
  int correctAnswers = 0;
  int highScore = 0;

  // Conjunto de questões disponíveis
  final List<Map<String, dynamic>> _availableQuestions = [
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/9/9a/Flag_of_Spain.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Itália', 'Espanha', 'França', 'Portugal', 'México'],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/0/05/Flag_of_Brazil.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Argentina', 'Brasil', 'Colômbia', 'Uruguai', 'Venezuela'],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/c/c3/Flag_of_France.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Alemanha', 'Holanda', 'França', 'Itália', 'Bélgica'],
      'correctAnswerIndex': 2,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/b/ba/Flag_of_Germany.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Bélgica', 'Alemanha', 'Áustria', 'Suíça', 'Polônia'],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/a/a4/Flag_of_the_United_States.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': [
        'Canadá',
        'Reino Unido',
        'Austrália',
        'Estados Unidos',
        'Irlanda'
      ],
      'correctAnswerIndex': 3,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/9/9e/Flag_of_Japan.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['China', 'Coreia do Sul', 'Japão', 'Vietnã', 'Tailândia'],
      'correctAnswerIndex': 2,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/0/0f/Flag_of_South_Korea.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Japão', 'Taiwan', 'Vietnã', 'Coreia do Sul', 'China'],
      'correctAnswerIndex': 3,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/0/09/Flag_of_South_Korea.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': [
        'Taiwan',
        'Coreia do Norte',
        'Indonésia',
        'Coreia do Sul',
        'Filipinas'
      ],
      'correctAnswerIndex': 3,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/f/fa/Flag_of_the_People%27s_Republic_of_China.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Vietnã', 'China', 'Hong Kong', 'Taiwan', 'Coreia do Norte'],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/4/41/Flag_of_India.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Paquistão', 'Bangladesh', 'Nepal', 'Butão', 'Índia'],
      'correctAnswerIndex': 4,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/4/49/Flag_of_Ukraine.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Suécia', 'Ucrânia', 'Romênia', 'Eslováquia', 'Moldova'],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/f/f3/Flag_of_Russia.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['Polônia', 'Eslováquia', 'Eslovênia', 'Rússia', 'Sérvia'],
      'correctAnswerIndex': 3,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/0/03/Flag_of_Italy.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': ['México', 'Hungria', 'Itália', 'Irlanda', 'Bulgária'],
      'correctAnswerIndex': 2,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/1/1a/Flag_of_Argentina.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': [
        'Uruguai',
        'Argentina',
        'Honduras',
        'El Salvador',
        'Nicarágua'
      ],
      'correctAnswerIndex': 1,
    },
    {
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/8/88/Flag_of_Australia_%28converted%29.svg',
      'question': 'Esta é a bandeira de qual país?',
      'options': [
        'Nova Zelândia',
        'Reino Unido',
        'Austrália',
        'Fiji',
        'Tuvalu'
      ],
      'correctAnswerIndex': 2,
    },
  ];

  QuizImageLogic({
    this.difficulty = GameDifficulty.medium,
  }) {
    _initializeGame();
    _loadHighScore();
  }

  void _initializeGame() {
    // Seleciona questões aleatórias
    questions = _generateQuestions();

    // Define os valores iniciais
    currentQuestionIndex = 0;
    correctAnswers = 0;
    gameState = GameState.ready;

    // Define o tempo inicial para a primeira questão
    _resetTimer();
  }

  List<QuizQuestion> _generateQuestions() {
    // Embaralha as questões disponíveis
    final shuffled = List.of(_availableQuestions)..shuffle(Random());

    // Seleciona as primeiras 10 questões
    final selectedQuestions = shuffled.take(10).toList();

    // Converte para objetos QuizQuestion e ajusta opções conforme dificuldade
    return selectedQuestions.map((q) {
      // Obtém todas as opções disponíveis
      final allOptions = List.of(q['options'] as List<String>);

      // Índice da resposta correta
      final correctIndex = q['correctAnswerIndex'] as int;
      String correctOption = allOptions[correctIndex];

      // Ajusta o número de opções conforme dificuldade
      final adjustedOptions = <String>[correctOption];

      // Remove a resposta correta temporariamente
      allOptions.removeAt(correctIndex);

      // Embaralha as opções restantes
      allOptions.shuffle();

      // Adiciona opções até atingir o número desejado para a dificuldade
      adjustedOptions.addAll(
        allOptions.take(difficulty.optionsCount - 1),
      );

      // Embaralha as opções ajustadas
      adjustedOptions.shuffle();

      // Encontra o novo índice da resposta correta
      final newCorrectIndex = adjustedOptions.indexOf(correctOption);

      return QuizQuestion.withIndex(
        imageUrl: q['imageUrl'] as String,
        question: q['question'] as String,
        options: adjustedOptions,
        correctAnswerIndex: newCorrectIndex,
      );
    }).toList();
  }

  void startGame() {
    if (gameState == GameState.ready) {
      gameState = GameState.playing;
    }
  }

  void _resetTimer() {
    timeLeft = difficulty.timeLimit;
  }

  void updateTimer() {
    if (gameState == GameState.playing && timeLeft > 0) {
      timeLeft--;

      // Registra o tempo gasto na questão atual
      questions[currentQuestionIndex].timeSpent++;

      // Verifica se o tempo acabou
      if (timeLeft <= 0) {
        // Considera como resposta incorreta quando o tempo acaba
        questions[currentQuestionIndex].answerState = AnswerState.incorrect;
        goToNextQuestion();
      }
    }
  }

  void selectAnswer(int answerIndex) {
    if (gameState == GameState.playing &&
        !questions[currentQuestionIndex].isAnswered) {
      // Registra a resposta
      questions[currentQuestionIndex].selectAnswer(answerIndex);

      // Atualiza a contagem de respostas corretas
      if (questions[currentQuestionIndex].isSelectedCorrect) {
        correctAnswers++;
      }

      // Aguarda um momento para mostrar feedback antes de avançar
      Future.delayed(const Duration(milliseconds: 800), goToNextQuestion);
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      // Avança para a próxima questão
      currentQuestionIndex++;
      _resetTimer();
    } else {
      // Finaliza o quiz
      gameState = GameState.gameOver;
      _saveHighScore();
    }
  }

  void restart({GameDifficulty? newDifficulty}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
    }
    _initializeGame();
  }

  double get progress {
    return (currentQuestionIndex + 1) / questions.length;
  }

  QuizQuestion get currentQuestion {
    return questions[currentQuestionIndex];
  }

  double get scorePercentage {
    return correctAnswers / questions.length * 100;
  }

  Future<void> _loadHighScore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt('quiz_image_high_score') ?? 0;
    } catch (e) {
      debugPrint('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    final score = (scorePercentage).round();
    if (score > highScore) {
      highScore = score;
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('quiz_image_high_score', highScore);
      } catch (e) {
        debugPrint('Error saving high score: $e');
      }
    }
  }
}
