// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/question.dart';

class QuizController with ChangeNotifier {
  // Lista de perguntas
  List<QuizQuestion> _questions = [];

  // Estado do jogo
  GameState _gameState = GameState.ready;

  // Pergunta atual
  int _currentQuestionIndex = 0;

  // Configurações do jogo
  GameDifficulty _difficulty = GameDifficulty.medium;

  // Tempo restante
  int _timeLeft = 0;

  // Timer
  Timer? _timer;

  // Estado da resposta atual
  AnswerState _currentAnswerState = AnswerState.unanswered;

  // Pontuação atual
  int _score = 0;

  // Maior pontuação
  int _highScore = 0;

  // Resposta selecionada
  String? _selectedAnswer;

  // Getters
  GameState get gameState => _gameState;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion get currentQuestion => _questions[_currentQuestionIndex];
  int get timeLeft => _timeLeft;
  AnswerState get currentAnswerState => _currentAnswerState;
  int get score => _score;
  int get highScore => _highScore;
  int get totalQuestions => _questions.length;
  GameDifficulty get difficulty => _difficulty;
  String? get selectedAnswer => _selectedAnswer;

  // Inicializa o controlador
  Future<void> initialize(List<QuizQuestion> questions) async {
    _questions = questions.map((q) => q.copyWithShuffledOptions()).toList();

    // Carrega o high score salvo
    await _loadHighScore();

    // Configura o estado inicial
    _gameState = GameState.ready;
    _currentQuestionIndex = 0;
    _timeLeft = _difficulty.timeLimit;
    _score = 0;
    _currentAnswerState = AnswerState.unanswered;
    _selectedAnswer = null;

    notifyListeners();
  }

  // Carrega o high score salvo
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('quiz_image_high_score') ?? 0;
  }

  // Salva o high score
  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_image_high_score', _highScore);
  }

  // Inicia o jogo
  void startGame() {
    _gameState = GameState.playing;
    _startTimer();
    notifyListeners();
  }

  // Inicia o timer
  void _startTimer() {
    _timeLeft = _difficulty.timeLimit;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _handleTimeout();
      }
    });
  }

  // Manipula o timeout de uma pergunta
  void _handleTimeout() {
    if (_currentAnswerState == AnswerState.unanswered) {
      _currentAnswerState = AnswerState.incorrect;
      _timer?.cancel();

      // Aguarda 2 segundos e move para a próxima pergunta
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
      notifyListeners();
    }
  }

  // Seleciona uma resposta
  void selectAnswer(String answer) {
    // Ignora se já respondeu a pergunta atual
    if (_currentAnswerState != AnswerState.unanswered) return;

    _selectedAnswer = answer;

    // Verifica se a resposta está correta
    final isCorrect = currentQuestion.isCorrect(answer);
    _currentAnswerState =
        isCorrect ? AnswerState.correct : AnswerState.incorrect;

    // Se estiver correta, aumenta o score
    if (isCorrect) {
      _score++;
    }

    // Pausa o timer
    _timer?.cancel();

    // Aguarda 2 segundos e move para a próxima pergunta
    Future.delayed(const Duration(seconds: 2), _nextQuestion);

    notifyListeners();
  }

  // Move para a próxima pergunta
  void _nextQuestion() {
    // Verifica se acabaram as perguntas
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _currentAnswerState = AnswerState.unanswered;
      _selectedAnswer = null;
      _startTimer();
    } else {
      _endGame();
    }

    notifyListeners();
  }

  // Finaliza o jogo
  void _endGame() {
    _gameState = GameState.gameOver;
    _timer?.cancel();

    // Calcula a porcentagem de acertos
    final percentage = (_score / _questions.length * 100).round();

    // Atualiza o high score se necessário
    if (percentage > _highScore) {
      _highScore = percentage;
      _saveHighScore();
    }

    notifyListeners();
  }

  // Reinicia o jogo
  void restartGame() {
    // Embaralha as perguntas e opções
    _questions = _questions.map((q) => q.copyWithShuffledOptions()).toList()
      ..shuffle();

    _gameState = GameState.ready;
    _currentQuestionIndex = 0;
    _timeLeft = _difficulty.timeLimit;
    _score = 0;
    _currentAnswerState = AnswerState.unanswered;
    _selectedAnswer = null;

    notifyListeners();
  }

  // Define a dificuldade
  void setDifficulty(GameDifficulty difficulty) {
    _difficulty = difficulty;
    _timeLeft = difficulty.timeLimit;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
