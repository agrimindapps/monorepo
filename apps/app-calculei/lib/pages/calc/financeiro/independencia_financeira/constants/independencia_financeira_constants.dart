/// Constantes para o módulo de independência financeira
class IndependenciaFinanceiraConstants {
  // Constantes de formatação e limites
  static const double defaultTaxaRetirada = 4.0;
  static const String formatoTaxaRetirada = '4,0';
  static const double minTaxaRetirada = 0.5;
  static const double maxTaxaRetirada = 10.0;

  // Constantes de layout
  static const double spacing = 16.0;
  static const double spacingSmall = 8.0;
  static const double cardElevation = 2.0;
  static const double cardPadding = 16.0;
  static const double graficoHeight = 300.0;

  // Constantes de texto
  static const String labelPatrimonioAtual = 'Patrimônio Atual (R\$)';
  static const String hintPatrimonioAtual = 'Ex: 100.000,00';
  static const String labelDespesasMensais = 'Despesas Mensais (R\$)';
  static const String hintDespesasMensais = 'Ex: 5.000,00';
  static const String labelAporteMensal = 'Aporte Mensal (R\$)';
  static const String hintAporteMensal = 'Ex: 2.000,00';
  static const String labelRetornoAnual = 'Retorno Anual (%)';
  static const String hintRetornoAnual = 'Ex: 8,0';
  static const String labelTaxaRetirada = 'Taxa de Retirada (%)';
  static const String hintTaxaRetirada = 'Ex: 4,0';

  // Constantes de validação
  static const String erroPatrimonioAtualVazio = 'Insira o patrimônio atual';
  static const String erroDespesasMensaisVazio = 'Insira as despesas mensais';
  static const String erroAporteMensalVazio = 'Insira o aporte mensal';
  static const String erroRetornoAnualVazio = 'Insira o retorno anual';
  static const String erroTaxaRetiradaVazio = 'Insira a taxa de retirada';

  // Constantes de estilo
  static const double titleFontSize = 18.0;
  static const double subtitleFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double buttonFontSize = 16.0;

  // Prefixos e sufixos
  static const String prefixoMoeda = 'R\$ ';
  static const String sufixoPercentual = '%';
  static const String sufixoK = 'K';
  static const String sufixoM = 'M';

  // Não instanciável
  IndependenciaFinanceiraConstants._();
}
