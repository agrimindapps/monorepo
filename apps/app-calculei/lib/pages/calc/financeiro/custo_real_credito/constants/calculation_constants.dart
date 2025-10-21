/// Constantes utilizadas nos cálculos de custo real de crédito
///
/// Esta classe centraliza todos os valores fixos utilizados na funcionalidade
/// de cálculo do custo real do crédito, facilitando manutenção e compreensão.
class CalculationConstants {
  // Valores padrão para inicialização dos campos

  /// Número padrão de parcelas para inicialização do campo
  /// Valor comum usado em financiamentos (12 meses = 1 ano)
  static const int DEFAULT_INSTALLMENTS = 12;

  /// Taxa padrão de investimento em porcentagem ao mês
  /// Representa um rendimento conservador típico da poupança/CDI
  static const double DEFAULT_INVESTMENT_RATE = 0.7;

  // Formatação e parsing de números

  /// Divisor para conversão de centavos para reais na formatação
  /// Usado no MoneyInputFormatter para converter entrada numérica
  static const double CENTS_TO_REAL_DIVISOR = 100.0;

  /// Símbolo da moeda brasileira
  static const String CURRENCY_SYMBOL = 'R\$';

  /// Número de casas decimais para formatação monetária
  static const int CURRENCY_DECIMAL_DIGITS = 2;

  /// Locale brasileiro para formatação de números
  static const String BRAZILIAN_LOCALE = 'pt_BR';

  // Valores para parsing e limpeza de strings

  /// Caractere vírgula usado na formatação brasileira
  static const String COMMA_CHAR = ',';

  /// Caractere ponto usado na formatação internacional
  static const String DOT_CHAR = '.';

  // Layout e espaçamento (valores em pixels)

  /// Padding padrão para widgets de formulário
  static const double DEFAULT_FORM_PADDING = 16.0;

  /// Espaçamento entre campos do formulário
  static const double FORM_FIELD_SPACING = 16.0;

  /// Espaçamento entre seções do layout
  static const double SECTION_SPACING = 24.0;

  /// Padding horizontal para botões
  static const double BUTTON_HORIZONTAL_PADDING = 32.0;

  /// Padding vertical para botões
  static const double BUTTON_VERTICAL_PADDING = 12.0;

  // Tamanhos de fonte

  /// Tamanho de fonte para títulos de seção
  static const double SECTION_TITLE_FONT_SIZE = 18.0;

  /// Tamanho de fonte para botões
  static const double BUTTON_FONT_SIZE = 16.0;

  // Elevação de componentes

  /// Elevação padrão para cards
  static const double CARD_ELEVATION = 2.0;

  /// Elevação para cards de resultado
  static const double RESULT_CARD_ELEVATION = 2.0;

  // Valores para validação (limites de segurança)

  /// Valor mínimo aceito para campos monetários (1 centavo)
  static const double MIN_CURRENCY_VALUE = 0.01;

  /// Valor máximo aceito para campos monetários (1 bilhão)
  static const double MAX_CURRENCY_VALUE = 1000000000.0;

  /// Número mínimo de parcelas permitido
  static const int MIN_INSTALLMENTS = 1;

  /// Número máximo de parcelas permitido (30 anos)
  static const int MAX_INSTALLMENTS = 360;

  /// Taxa mínima de investimento (0%)
  static const double MIN_INVESTMENT_RATE = 0.0;

  /// Taxa máxima de investimento (50% ao mês)
  static const double MAX_INVESTMENT_RATE = 50.0;

  /// Padding para o card de resultado
  static const double RESULT_CARD_PADDING = 16.0;

  /// Espaçamento entre itens de resultado
  static const double RESULT_ITEM_SPACING = 8.0;

  /// Espaçamento maior entre seções de resultado
  static const double RESULT_SECTION_SPACING = 16.0;

  /// Padding para o container de conclusão
  static const double CONCLUSION_PADDING = 12.0;

  /// Tamanho da fonte para itens de resultado
  static const double RESULT_ITEM_FONT_SIZE = 16.0;

  /// Tamanho da fonte para itens destacados
  static const double RESULT_HIGHLIGHT_FONT_SIZE = 18.0;
}
