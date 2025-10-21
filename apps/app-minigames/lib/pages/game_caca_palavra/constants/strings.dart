/// Constantes de strings para o jogo Caça Palavras
///
/// REFATORAÇÃO CONCLUÍDA:
/// - Centralizou todas as strings literais usadas no jogo
/// - Organizou por categorias lógicas (UI, Diálogos, Mensagens, etc.)
/// - Facilitou manutenção e futuras traduções
/// - Evitou duplicação de strings hardcoded
library;

class GameStrings {
  // ========== Strings da UI Principal ==========

  /// Título principal do jogo
  static const String gameTitle = 'Caça Palavras';

  /// Texto do botão de novo jogo
  static const String newGameButton = 'Novo Jogo';

  /// Label do indicador de progresso
  static const String progressLabel = 'Progresso:';

  /// Texto da lista de palavras
  static const String wordsToFind = 'Palavras para encontrar:';

  // ========== Tooltips e Acessibilidade ==========

  /// Tooltip do botão de instruções
  static const String instructionsTooltip = 'Instruções';

  /// Tooltip do menu de dificuldade
  static const String difficultyTooltip = 'Dificuldade';

  // ========== Labels de Dificuldade ==========

  /// Label para dificuldade fácil
  static const String difficultyEasy = 'Fácil';

  /// Label para dificuldade média
  static const String difficultyMedium = 'Médio';

  /// Label para dificuldade difícil
  static const String difficultyHard = 'Difícil';

  // ========== Diálogos - Vitória ==========

  /// Título do diálogo de vitória
  static const String victoryTitle = 'Parabéns!';

  /// Mensagem principal do diálogo de vitória
  static const String victoryMessage = 'Você encontrou todas as palavras!';

  /// Label para mostrar dificuldade no diálogo
  static const String victoryDifficultyLabel = 'Dificuldade:';

  /// Label para mostrar palavras encontradas
  static const String victoryWordsFoundLabel = 'Palavras encontradas:';

  /// Botão para jogar novamente
  static const String playAgainButton = 'Jogar Novamente';

  /// Botão para sair do jogo
  static const String exitButton = 'Sair';

  // ========== Diálogos - Instruções ==========

  /// Título do diálogo de instruções
  static const String instructionsTitle = 'Como Jogar';

  /// Instrução 1
  static const String instruction1 =
      '• Encontre todas as palavras escondidas no grid.';

  /// Instrução 2
  static const String instruction2 =
      '• As palavras podem estar na horizontal, vertical ou diagonal.';

  /// Instrução 3
  static const String instruction3 =
      '• Selecione uma letra e arraste até formar a palavra.';

  /// Instrução 4
  static const String instruction4 =
      '• Quando encontrar uma palavra, ela será marcada na lista.';

  /// Instrução 5
  static const String instruction5 =
      '• Toque em uma palavra na lista para destacá-la.';

  /// Botão de confirmação das instruções
  static const String understoodButton = 'Entendi';

  // ========== Diálogos - Confirmação de Mudança de Dificuldade ==========

  /// Título do diálogo de confirmação
  static const String changeDifficultyTitle = 'Mudar dificuldade';

  /// Mensagem de confirmação
  static const String changeDifficultyMessage =
      'Mudar a dificuldade reiniciará o jogo. Deseja continuar?';

  /// Botão de cancelar
  static const String cancelButton = 'Cancelar';

  /// Botão de reiniciar
  static const String restartButton = 'Reiniciar';

  // ========== Mensagens de Estado ==========

  /// Separador para mostrar progresso (ex: "5/8")
  static const String progressSeparator = '/';

  // ========== Strings de Direções (para futuro uso) ==========

  /// Label para direção horizontal
  static const String directionHorizontal = 'Horizontal';

  /// Label para direção vertical
  static const String directionVertical = 'Vertical';

  /// Label para direção diagonal descendente
  static const String directionDiagonalDown = 'Diagonal Desc.';

  /// Label para direção diagonal ascendente
  static const String directionDiagonalUp = 'Diagonal Asc.';

  // ========== Utilitários ==========

  /// Cria texto de progresso formatado (ex: "5/8")
  static String formatProgress(int current, int total) {
    return '$current$progressSeparator$total';
  }

  /// Cria texto de dificuldade formatado (ex: "Dificuldade: Médio")
  static String formatDifficulty(String difficulty) {
    return '$victoryDifficultyLabel $difficulty';
  }

  /// Cria texto de palavras encontradas formatado
  static String formatWordsFound(int count) {
    return '$victoryWordsFoundLabel $count';
  }
}
