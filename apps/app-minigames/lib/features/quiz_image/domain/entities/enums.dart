/// Game difficulty levels that affect timer and number of options
enum GameDifficulty {
  easy(timeLimit: 30, optionsCount: 2),
  medium(timeLimit: 20, optionsCount: 3),
  hard(timeLimit: 15, optionsCount: 4);

  final int timeLimit;
  final int optionsCount;

  const GameDifficulty({
    required this.timeLimit,
    required this.optionsCount,
  });
}

/// Current state of the quiz game
enum GameStateEnum {
  ready,
  playing,
  gameOver,
}

/// State of the current question's answer
enum AnswerState {
  unanswered,
  correct,
  incorrect,
}
