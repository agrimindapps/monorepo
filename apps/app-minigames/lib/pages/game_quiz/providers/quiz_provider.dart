// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class QuizProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _questions = [];
  Map<String, dynamic>? _currentQuestion;
  int _score = 0;
  int _lives = 3;
  int _timeLeft = 20;
  QuizStatus _gameStatus = QuizStatus.loading;
  Timer? _timer;

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  Map<String, dynamic>? get currentQuestion => _currentQuestion;
  int get score => _score;
  int get lives => _lives;
  int get timeLeft => _timeLeft;
  QuizStatus get gameStatus => _gameStatus;

  void loadQuestions() {
    _gameStatus = QuizStatus.loading;
    notifyListeners();

    // Exemplo de questões - Adicione mais conforme necessário
    String data = '''
    [
      {
        "id": 1,
        "termo": "Flutter",
        "descricao": "SDK de código aberto criado pelo Google para desenvolvimento de aplicativos multiplataforma",
        "options": ["Flutter", "React", "Angular", "Vue"]
      },
      {
        "id": 2,
        "termo": "Widget",
        "descricao": "Elementos básicos de construção de interfaces no Flutter, tudo é um...",
        "options": ["Widget", "Component", "Element", "View"]
      },
      {
        "id": 3,
        "termo": "setState",
        "descricao": "Método usado para atualizar o estado de um widget e reconstruir a interface",
        "options": ["setState", "updateUI", "refresh", "rebuild"]
      }
    ]
    ''';

    _questions = List<Map<String, dynamic>>.from(json.decode(data));
    _gameStatus = QuizStatus.playing;
    pickRandomQuestion();
  }

  void pickRandomQuestion() {
    if (_questions.isEmpty) {
      _gameStatus = QuizStatus.gameOver;
      notifyListeners();
      return;
    }

    Random random = Random();
    int index = random.nextInt(_questions.length);
    _currentQuestion = _questions[index];
    _questions.removeAt(index); // Remove a questão usada
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    _timeLeft = 20;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        processAnswer(''); // Tempo esgotado
      }
    });
  }

  void processAnswer(String selectedAnswer) {
    _timer?.cancel();
    bool isCorrect = selectedAnswer == _currentQuestion?['termo'];

    if (isCorrect) {
      _score += _timeLeft; // Pontuação baseada no tempo restante
    } else {
      _lives--;
    }

    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      if (_lives > 0) {
        pickRandomQuestion();
      } else {
        _gameStatus = QuizStatus.gameOver;
        notifyListeners();
      }
    });
  }

  void resetGame() {
    _score = 0;
    _lives = 3;
    _questions = [];
    _currentQuestion = null;
    _gameStatus = QuizStatus.loading;
    loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
