/// Game categories for filtering and organization
enum GameCategory {
  all('Todos', '🎮'),
  puzzle('Quebra-Cabeça', '🧩'),
  strategy('Estratégia', '♟️'),
  arcade('Arcade', '👾'),
  word('Palavras', '📝'),
  quiz('Quiz', '❓'),
  classic('Clássicos', '🏆'),
  casual('Casual', '🎯');

  const GameCategory(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}
