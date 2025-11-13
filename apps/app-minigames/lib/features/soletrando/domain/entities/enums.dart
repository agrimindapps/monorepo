/// Game difficulty levels with associated configuration
enum GameDifficulty {
  easy(
    label: 'Fácil',
    timeInSeconds: 90,
    hints: 5,
    scoreMultiplier: 1,
    mistakesAllowed: 5,
  ),
  medium(
    label: 'Normal',
    timeInSeconds: 60,
    hints: 3,
    scoreMultiplier: 2,
    mistakesAllowed: 3,
  ),
  hard(
    label: 'Difícil',
    timeInSeconds: 30,
    hints: 1,
    scoreMultiplier: 3,
    mistakesAllowed: 1,
  );

  final String label;
  final int timeInSeconds;
  final int hints;
  final int scoreMultiplier;
  final int mistakesAllowed;

  const GameDifficulty({
    required this.label,
    required this.timeInSeconds,
    required this.hints,
    required this.scoreMultiplier,
    required this.mistakesAllowed,
  });
}

/// Word categories with localized labels and hints
enum WordCategory {
  fruits(name: 'Frutas', hint: 'É uma fruta', icon: '🍎'),
  animals(name: 'Animais', hint: 'É um animal', icon: '🦁'),
  countries(name: 'Países', hint: 'É um país', icon: '🌍'),
  professions(name: 'Profissões', hint: 'É uma profissão', icon: '👨‍💼');

  final String name;
  final String hint;
  final String icon;

  const WordCategory({
    required this.name,
    required this.hint,
    required this.icon,
  });
}

/// State of individual letters in the word
enum LetterState {
  pending, // Not guessed yet (shown as _)
  correct, // Correctly guessed (shown as letter)
  incorrect, // Incorrectly guessed (feedback only)
  revealed, // Revealed via hint
}

/// Overall game status
enum GameStatus {
  initial, // Before first word
  playing, // Actively playing
  paused, // Game paused
  wordCompleted, // Current word completed successfully
  gameOver, // Lost all lives
  timeUp, // Time expired
  error, // Error state
}
