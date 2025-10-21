/// Constantes de configuração do jogo da memória
///
/// Esta classe centraliza todas as configurações e constantes utilizadas
/// no jogo, facilitando manutenção e customização.
class MemoryGameConfig {
  // ========== TIMING CONSTANTS ==========

  /// Delay antes de mostrar o diálogo de fim de jogo
  ///
  /// Este delay permite que:
  /// 1. A última animação de carta seja completada
  /// 2. O feedback háptico seja processado
  /// 3. O usuário tenha um momento para processar a vitória
  /// 4. A interface não pareça muito abrupta
  static const Duration gameOverDelay = Duration(milliseconds: 500);

  /// Delay padrão para animações de cartas
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);

  /// Duração do feedback háptico
  static const Duration hapticFeedbackDuration = Duration(milliseconds: 100);

  // ========== UI CONSTANTS ==========

  /// Padding horizontal padrão
  static const double defaultHorizontalPadding = 32.0;

  /// Margem entre cartas
  static const double cardMargin = 8.0;

  /// Padding da grade de cartas
  static const double gridPadding = 16.0;

  /// Tamanho mínimo das cartas
  static const double minCardSize = 40.0;

  /// Tamanho máximo das cartas
  static const double maxCardSize = 120.0;

  /// Altura reservada para elementos da UI (AppBar, botões, etc.)
  static const double uiReservedHeight = 200.0;

  // ========== GAME BEHAVIOR CONSTANTS ==========

  /// Debounce para cliques em cartas (previne cliques duplos acidentais)
  static const Duration cardTapDebounce = Duration(milliseconds: 200);

  /// Timeout para operações de matching (segurança contra travamentos)
  static const Duration matchProcessingTimeout = Duration(seconds: 2);

  /// Permite configurar o delay do game over em runtime se necessário
  /// (útil para testes ou diferentes experiências de usuário)
  static Duration getGameOverDelay({bool isTestMode = false}) {
    if (isTestMode) {
      return const Duration(milliseconds: 100); // Delay reduzido para testes
    }
    return gameOverDelay;
  }

  /// Obtém a duração da animação baseada na dificuldade
  static Duration getAnimationDuration(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1: // Fácil
        return const Duration(milliseconds: 400);
      case 2: // Médio
        return const Duration(milliseconds: 350);
      case 3: // Difícil
        return const Duration(milliseconds: 300);
      default:
        return cardAnimationDuration;
    }
  }
}
