// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class QuizModel {
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic>? currentQuestion;
  int score = 0;
  int lives = 3;
  int timeLeft = 20;
  Timer? timer;
  Function(int)? onTimeChange;
  Function(bool, int)? onAnswerProcessed;
  Function(bool)? onGameOver;

  QuizModel({
    this.onTimeChange,
    this.onAnswerProcessed,
    this.onGameOver,
  });

  void loadQuestions() {
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

    questions = List<Map<String, dynamic>>.from(json.decode(data));
    pickRandomQuestion();
  }

  void pickRandomQuestion() {
    if (questions.isEmpty) {
      onGameOver?.call(true);
      return;
    }

    Random random = Random();
    int index = random.nextInt(questions.length);
    currentQuestion = questions[index];
    questions.removeAt(index); // Remove a questão usada
    startTimer();
  }

  void startTimer() {
    timeLeft = 20;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
        onTimeChange?.call(timeLeft);
      } else {
        timer.cancel();
        processAnswer(''); // Tempo esgotado
      }
    });
  }

  void processAnswer(String selectedAnswer) {
    timer?.cancel();
    bool isCorrect = selectedAnswer == currentQuestion?['termo'];

    if (isCorrect) {
      score += timeLeft; // Pontuação baseada no tempo restante
      onAnswerProcessed?.call(true, timeLeft);
    } else {
      lives--;
      onAnswerProcessed?.call(false, 0);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (lives > 0) {
        pickRandomQuestion();
      } else {
        onGameOver?.call(false);
      }
    });
  }

  void resetGame() {
    score = 0;
    lives = 3;
    questions = [];
    currentQuestion = null;
    loadQuestions();
  }

  void dispose() {
    timer?.cancel();
  }
}
