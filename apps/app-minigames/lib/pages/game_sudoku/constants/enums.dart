// Níveis de dificuldade para o jogo Sudoku
enum DifficultyLevel {
  easy(cellsToRemove: 30, label: 'Fácil'),
  medium(cellsToRemove: 45, label: 'Médio'),
  hard(cellsToRemove: 55, label: 'Difícil');

  final int cellsToRemove;
  final String label;

  const DifficultyLevel({required this.cellsToRemove, required this.label});
}
