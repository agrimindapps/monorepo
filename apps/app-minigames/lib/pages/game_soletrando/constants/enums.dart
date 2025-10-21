// Enums e constantes para o jogo Soletrando

// Dificuldades do jogo
enum Difficulty {
  easy('Fácil', 90, 5, 1),
  normal('Normal', 60, 3, 2),
  hard('Difícil', 30, 1, 3);

  final String label;
  final int timeInSeconds;
  final int hints;
  final int scoreMultiplier;

  const Difficulty(
      this.label, this.timeInSeconds, this.hints, this.scoreMultiplier);
}

// Categorias de palavras
enum WordCategory {
  fruits('Frutas', 'É uma fruta'),
  animals('Animais', 'É um animal'),
  countries('Países', 'É um país'),
  professions('Profissões', 'É uma profissão');

  final String label;
  final String hint;

  const WordCategory(this.label, this.hint);

  static WordCategory fromString(String value) {
    return WordCategory.values.firstWhere(
      (category) => category.label == value,
      orElse: () => WordCategory.fruits,
    );
  }
}

// Resultado do jogo
enum GameResult {
  inProgress('Em andamento'),
  success('Parabéns!'),
  failure('Game Over'),
  timeOut('Tempo Esgotado');

  final String message;

  const GameResult(this.message);
}
