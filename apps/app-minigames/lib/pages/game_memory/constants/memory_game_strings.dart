/// Strings centralizadas para o jogo da memória
/// 
/// Centraliza todas as strings do jogo para facilitar
/// internacionalização e manutenção.
library;

/// Strings da interface do usuário
class MemoryGameStrings {
  /// Título do jogo
  static const String gameTitle = 'Jogo da Memória';
  
  /// Botões
  static const String startGame = 'Iniciar Jogo';
  static const String pauseGame = 'Pausar';
  static const String resumeGame = 'Retomar';
  static const String restartGame = 'Reiniciar';
  static const String newGame = 'Novo Jogo';
  static const String exitGame = 'Sair';
  static const String playAgain = 'Jogar Novamente';
  static const String continueButton = 'Continuar';
  static const String cancel = 'Cancelar';
  static const String ok = 'OK';
  static const String close = 'Fechar';
  static const String save = 'Salvar';
  static const String load = 'Carregar';
  static const String delete = 'Excluir';
  static const String confirm = 'Confirmar';
  static const String apply = 'Aplicar';
  static const String reset = 'Resetar';
  
  /// Informações do jogo
  static const String time = 'Tempo';
  static const String moves = 'Movimentos';
  static const String pairs = 'Pares';
  static const String score = 'Pontuação';
  static const String bestScore = 'Melhor Pontuação';
  static const String level = 'Nível';
  static const String difficulty = 'Dificuldade';
  static const String mode = 'Modo';
  
  /// Estados do jogo
  static const String gameStarted = 'Jogo iniciado!';
  static const String gamePaused = 'Jogo pausado';
  static const String gameResumed = 'Jogo retomado';
  static const String gameCompleted = 'Jogo concluído!';
  static const String gameOver = 'Fim de jogo';
  static const String congratulations = 'Parabéns!';
  static const String newRecord = 'Novo recorde!';
  static const String matchFound = 'Par encontrado!';
  static const String noMatch = 'Não é um par';
  
  /// Dificuldades
  static const String easy = 'Fácil';
  static const String medium = 'Médio';
  static const String hard = 'Difícil';
  
  /// Modos de jogo
  static const String classicMode = 'Clássico';
  static const String timeAttackMode = 'Contra o Tempo';
  static const String challengeMode = 'Desafio';
  static const String zenMode = 'Zen';
  
  /// Descrições dos modos
  static const String classicModeDescription = 'Modo tradicional sem limites de tempo ou movimentos';
  static const String timeAttackModeDescription = 'Complete o jogo antes que o tempo acabe!';
  static const String challengeModeDescription = 'Complete com o mínimo de movimentos possível!';
  static const String zenModeDescription = 'Jogue sem pressa, focando na tranquilidade';
  
  /// Configurações
  static const String settings = 'Configurações';
  static const String audio = 'Áudio';
  static const String sound = 'Som';
  static const String music = 'Música';
  static const String effects = 'Efeitos';
  static const String hapticFeedback = 'Feedback Tátil';
  static const String animations = 'Animações';
  static const String theme = 'Tema';
  static const String language = 'Idioma';
  static const String accessibility = 'Acessibilidade';
  static const String performance = 'Performance';
  
  /// Temas
  static const String lightTheme = 'Claro';
  static const String darkTheme = 'Escuro';
  static const String autoTheme = 'Automático';
  static const String highContrast = 'Alto Contraste';
  
  /// Acessibilidade
  static const String screenReader = 'Leitor de Tela';
  static const String largeText = 'Texto Grande';
  static const String reduceMotion = 'Reduzir Movimento';
  static const String colorBlindSupport = 'Suporte a Daltonismo';
  static const String voiceCommands = 'Comandos de Voz';
  static const String visualIndicators = 'Indicadores Visuais';
  
  /// Estatísticas
  static const String statistics = 'Estatísticas';
  static const String totalGames = 'Total de Jogos';
  static const String totalWins = 'Total de Vitórias';
  static const String totalMoves = 'Total de Movimentos';
  static const String totalTime = 'Tempo Total';
  static const String averageTime = 'Tempo Médio';
  static const String bestTime = 'Melhor Tempo';
  static const String perfectGames = 'Jogos Perfeitos';
  static const String winRate = 'Taxa de Vitória';
  static const String efficiency = 'Eficiência';
  
  /// Diálogos
  static const String pauseDialogTitle = 'Jogo Pausado';
  static const String gameOverDialogTitle = 'Jogo Concluído';
  static const String newRecordDialogTitle = 'Novo Recorde!';
  static const String confirmExitTitle = 'Confirmar Saída';
  static const String confirmRestartTitle = 'Confirmar Reinício';
  static const String settingsDialogTitle = 'Configurações';
  static const String statisticsDialogTitle = 'Suas Estatísticas';
  static const String helpDialogTitle = 'Como Jogar';
  
  /// Mensagens de confirmação
  static const String confirmExitMessage = 'Tem certeza que deseja sair do jogo?';
  static const String confirmRestartMessage = 'Tem certeza que deseja reiniciar o jogo atual?';
  static const String confirmResetStatsMessage = 'Tem certeza que deseja resetar todas as estatísticas?';
  static const String confirmDeleteSaveMessage = 'Tem certeza que deseja excluir este save?';
  
  /// Mensagens de resultado
  static const String gameCompletedMessage = 'Você completou o jogo!';
  static const String newRecordMessage = 'Você estabeleceu um novo recorde!';
  static const String gameCompletedIn = 'Concluído em';
  static const String withMoves = 'com movimentos';
  static const String inTime = 'em';
  
  /// Instruções
  static const String howToPlayTitle = 'Como Jogar';
  static const String howToPlayContent = '''
🎯 Objetivo: Encontre todos os pares de cartas iguais.

📱 Como jogar:
• Toque em uma carta para virá-la
• Toque em outra carta para formar um par
• Se as cartas forem iguais, elas permanecerão viradas
• Se forem diferentes, voltarão a ficar viradas para baixo

🏆 Pontuação: Baseada no tempo, movimentos e dificuldade.

💡 Dicas:
• Memorize a posição das cartas
• Comece pelas bordas
• Mantenha a concentração
''';
  
  /// Erros e avisos
  static const String error = 'Erro';
  static const String warning = 'Aviso';
  static const String information = 'Informação';
  static const String success = 'Sucesso';
  
  /// Mensagens de erro
  static const String errorLoadingGame = 'Erro ao carregar o jogo';
  static const String errorSavingGame = 'Erro ao salvar o jogo';
  static const String errorLoadingStats = 'Erro ao carregar estatísticas';
  static const String errorInvalidMove = 'Movimento inválido';
  static const String errorGameNotStarted = 'O jogo ainda não foi iniciado';
  static const String errorGameAlreadyFinished = 'O jogo já foi finalizado';
  
  /// Mensagens de sucesso
  static const String gameSaved = 'Jogo salvo com sucesso';
  static const String gameLoaded = 'Jogo carregado com sucesso';
  static const String settingsSaved = 'Configurações salvas';
  static const String statsReset = 'Estatísticas resetadas';
  
  /// Tooltips e dicas
  static const String pauseTooltip = 'Pausar jogo';
  static const String resumeTooltip = 'Retomar jogo';
  static const String restartTooltip = 'Reiniciar jogo';
  static const String settingsTooltip = 'Configurações';
  static const String helpTooltip = 'Ajuda';
  static const String muteTooltip = 'Silenciar';
  static const String unmuteTooltip = 'Ativar som';
  
  /// Navegação
  static const String back = 'Voltar';
  static const String next = 'Próximo';
  static const String previous = 'Anterior';
  static const String menu = 'Menu';
  static const String home = 'Início';
  
  /// Unidades de tempo
  static const String seconds = 'segundos';
  static const String minutes = 'minutos';
  static const String hours = 'horas';
  static const String sec = 's';
  static const String min = 'm';
  static const String hr = 'h';
  
  /// Números por extenso (para acessibilidade)
  static const List<String> numbers = [
    'zero', 'um', 'dois', 'três', 'quatro', 'cinco',
    'seis', 'sete', 'oito', 'nove', 'dez',
    'onze', 'doze', 'treze', 'quatorze', 'quinze',
    'dezesseis', 'dezessete', 'dezoito', 'dezenove', 'vinte'
  ];
  
  /// Cores (para acessibilidade)
  static const Map<String, String> colorNames = {
    'red': 'vermelho',
    'green': 'verde',
    'blue': 'azul',
    'yellow': 'amarelo',
    'purple': 'roxo',
    'orange': 'laranja',
    'pink': 'rosa',
    'brown': 'marrom',
    'gray': 'cinza',
    'black': 'preto',
    'white': 'branco',
  };
  
  /// Formas (para acessibilidade)
  static const Map<String, String> shapeNames = {
    'circle': 'círculo',
    'square': 'quadrado',
    'triangle': 'triângulo',
    'star': 'estrela',
    'heart': 'coração',
    'diamond': 'losango',
    'oval': 'oval',
    'rectangle': 'retângulo',
  };
  
  /// Formatação de tempo
  static String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
  
  /// Formatação de pontuação
  static String formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      return score.toString();
    }
  }
  
  /// Mensagem de progresso
  static String progressMessage(int current, int total) {
    return '$current de $total';
  }
  
  /// Mensagem de porcentagem
  static String percentageMessage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  /// Plural/singular dinâmico
  static String pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
  
  /// Mensagem de movimento
  static String movesMessage(int moves) {
    return '$moves ${pluralize(moves, "movimento", "movimentos")}';
  }
  
  /// Mensagem de par
  static String pairsMessage(int pairs, int total) {
    return '$pairs de $total ${pluralize(total, "par", "pares")}';
  }
  
  /// Mensagem de vitória personalizada
  static String victoryMessage(int moves, String time) {
    return 'Parabéns! Você completou o jogo em $moves ${pluralize(moves, "movimento", "movimentos")} e $time.';
  }
  
  /// Mensagem de novo recorde personalizada
  static String newRecordMessageDetailed(int score, int previousBest) {
    return 'Novo recorde! Você fez $score pontos, superando o recorde anterior de $previousBest pontos.';
  }
}

/// Strings específicas para acessibilidade
class AccessibilityStrings {
  static const String cardRevealed = 'Carta revelada';
  static const String cardHidden = 'Carta oculta';
  static const String cardMatched = 'Par encontrado';
  static const String tapToReveal = 'Toque para revelar';
  static const String position = 'Posição';
  static const String of = 'de';
  static const String showing = 'mostrando';
  static const String gameBoard = 'Tabuleiro do jogo';
  static const String gameInfo = 'Informações do jogo';
  static const String gameControls = 'Controles do jogo';
  
  /// Gera descrição acessível para carta
  static String cardDescription({
    required int position,
    required int total,
    required String state,
    String? content,
  }) {
    final baseDescription = 'Carta $position de $total, $state';
    if (content != null) {
      return '$baseDescription, $showing $content';
    }
    return baseDescription;
  }
  
  /// Gera anúncio para ação
  static String actionAnnouncement(String action) {
    switch (action) {
      case 'match_found':
        return 'Par encontrado!';
      case 'no_match':
        return 'As cartas não fazem par';
      case 'game_completed':
        return 'Jogo concluído! Parabéns!';
      case 'game_paused':
        return 'Jogo pausado';
      case 'game_resumed':
        return 'Jogo retomado';
      default:
        return action;
    }
  }
}