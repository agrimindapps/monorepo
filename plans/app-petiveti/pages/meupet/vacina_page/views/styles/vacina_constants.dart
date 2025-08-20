class VacinaConstants {
  // Time periods
  static const int diasAvisoVencimento = 30; // Days to warn about expiration
  static const int diasIntervaloHistorico = 365; // Days for historical data range
  
  // UI Layout
  static const double larguraMaximaConteudo = 1020.0; // Maximum content width
  static const double alturaHeaderAproximada = 215.0; // Approximate header height
  
  // Network timeouts
  static const Duration timeoutOperacaoRede = Duration(seconds: 30); // Network operation timeout
  
  // UI Spacing
  static const double espacamentoPadrao = 8.0; // Default spacing
  static const double espacamentoCards = 8.0; // Card spacing
  static const double espacamentoSecoes = 16.0; // Section spacing
  
  // Icon sizes
  static const double tamanhoIconeVacina = 32.0; // Vaccine icon size
  static const double tamanhoIconeStatus = 64.0; // Status icon size
  
  // Widget sizing
  static const double larguraWidgetCentral = 300.0; // Central widget width
  static const double paddingHorizontalPadrao = 32.0; // Default horizontal padding
  static const double paddingVerticalPadrao = 12.0; // Default vertical padding
  static const double bordaCircularPadrao = 8.0; // Default border radius
  static const double bordaCircularBotao = 20.0; // Button border radius
  static const double bordaCircularContador = 12.0; // Counter border radius
  
  // Specific spacing values
  static const double espacamentoMinimoTop = 4.0; // Minimal top spacing
  static const double espacamentoDropdown = 4.0; // Dropdown spacing
  static const double espacamentoIconeTexto = 12.0; // Icon to text spacing
  
  // Padding variations
  static const double paddingConteudoPadrao = 8.0; // Standard content padding
}