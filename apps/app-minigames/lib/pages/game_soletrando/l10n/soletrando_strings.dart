/// Classe centralizada para todas as strings do jogo Soletrando
/// Preparada para futura internacionalização
class SoletrandoStrings {
  // Título e labels principais
  static const String gameTitle = 'Soletrando';
  static const String categoryLabel = 'Categoria';
  static const String scoreLabel = 'Pontos';
  static const String livesLabel = 'Vidas';
  static const String timeLabel = 'Tempo';
  
  // Categorias de palavras
  static const String categoryFruits = 'Frutas';
  static const String categoryAnimals = 'Animais';
  static const String categoryCountries = 'Países';
  static const String categoryProfessions = 'Profissões';
  
  // Mensagens do jogo
  static const String correctLetter = 'Letra correta!';
  static const String wrongLetter = 'Letra incorreta!';
  static const String wordCompleted = 'Palavra completada!';
  static const String gameWon = 'Parabéns! Você venceu!';
  static const String gameLost = 'Que pena! Você perdeu!';
  static const String timeUp = 'Tempo esgotado!';
  
  // Botões e ações
  static const String newGameButton = 'Novo Jogo';
  static const String continueButton = 'Continuar';
  static const String resetButton = 'Reiniciar';
  static const String changeCategoryButton = 'Mudar Categoria';
  static const String exitButton = 'Sair';
  static const String okButton = 'OK';
  static const String cancelButton = 'Cancelar';
  static const String yesButton = 'Sim';
  static const String noButton = 'Não';
  
  // Diálogos
  static const String gameOverTitle = 'Fim de Jogo';
  static const String gameOverMessage = 'Sua pontuação final foi: ';
  static const String timeOutTitle = 'Tempo Esgotado';
  static const String timeOutMessage = 'O tempo acabou! Você perdeu uma vida.';
  static const String categorySelectionTitle = 'Escolha uma Categoria';
  static const String resetConfirmationTitle = 'Confirmar Reset';
  static const String resetConfirmationMessage = 'Tem certeza que deseja reiniciar o jogo? Sua pontuação será perdida.';
  
  // Hints e instruções
  static const String instructionSelectLetter = 'Selecione uma letra para formar a palavra';
  static const String instructionTimeRunning = 'Corre! O tempo está passando!';
  static const String hintCategory = 'Dica: A palavra é da categoria ';
  
  // Status do jogo
  static const String gameInProgress = 'Jogo em Andamento';
  static const String gameSuccess = 'Sucesso';
  static const String gameFailure = 'Falha';
  static const String gameTimeOut = 'Tempo Esgotado';
  
  // Acessibilidade
  static const String letterButtonAccessibility = 'Botão da letra ';
  static const String timerAccessibility = 'Tempo restante: ';
  static const String scoreAccessibility = 'Pontuação atual: ';
  static const String livesAccessibility = 'Vidas restantes: ';
  static const String wordDisplayAccessibility = 'Palavra atual: ';
  
  // Configurações (preparação para futuras features)
  static const String settingsTitle = 'Configurações';
  static const String soundEnabled = 'Som Habilitado';
  static const String vibrationEnabled = 'Vibração Habilitada';
  static const String difficultyLevel = 'Nível de Dificuldade';
  static const String languageSelection = 'Idioma';
  
  // Níveis de dificuldade (preparação para futuras features)
  static const String difficultyEasy = 'Fácil';
  static const String difficultyMedium = 'Médio';
  static const String difficultyHard = 'Difícil';
  
  // Estatísticas (preparação para futuras features)
  static const String statisticsTitle = 'Estatísticas';
  static const String gamesPlayed = 'Jogos Jogados';
  static const String wordsCompleted = 'Palavras Completadas';
  static const String averageTime = 'Tempo Médio';
  static const String bestScore = 'Melhor Pontuação';
  
  // Mensagens de erro
  static const String errorGeneric = 'Ocorreu um erro inesperado';
  static const String errorLoadingGame = 'Erro ao carregar o jogo';
  static const String errorSavingGame = 'Erro ao salvar o progresso';
  
  // Helper method para obter string de categoria baseada no enum
  static String getCategoryName(String categoryKey) {
    switch (categoryKey.toLowerCase()) {
      case 'fruits':
        return categoryFruits;
      case 'animals':
        return categoryAnimals;
      case 'countries':
        return categoryCountries;
      case 'professions':
        return categoryProfessions;
      default:
        return categoryKey;
    }
  }
  
  // Helper method para obter mensagem de resultado do jogo
  static String getGameResultMessage(String result) {
    switch (result.toLowerCase()) {
      case 'success':
        return gameWon;
      case 'failure':
        return gameLost;
      case 'timeout':
        return timeUp;
      default:
        return gameInProgress;
    }
  }
}

/// Extensão para facilitar o uso de strings localizadas
extension SoletrandoStringsExtension on String {
  /// Capitaliza a primeira letra da string
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// Converte para título (primeira letra de cada palavra maiúscula)
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }
}