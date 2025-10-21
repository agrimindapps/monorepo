// Flutter imports:
import 'package:flutter/material.dart';

class OrcamentoModel {
  double rendaTotal;
  double despesasEssenciais;
  double despesasNaoEssenciais;
  double investimentos;

  // Valores calculados
  double get totalReal =>
      despesasEssenciais + despesasNaoEssenciais + investimentos;

  // Valores ideais
  double get despesasEssenciaisIdeal => rendaTotal * 0.5;
  double get despesasNaoEssenciaisIdeal => rendaTotal * 0.3;
  double get investimentosIdeal => rendaTotal * 0.2;

  // Diferenças
  double get diferencaEssenciais =>
      despesasEssenciais - despesasEssenciaisIdeal;
  double get diferencaNaoEssenciais =>
      despesasNaoEssenciais - despesasNaoEssenciaisIdeal;
  double get diferencaInvestimentos => investimentos - investimentosIdeal;

  // Percentuais reais
  double get percentEssenciais =>
      rendaTotal > 0 ? despesasEssenciais / rendaTotal : 0;
  double get percentNaoEssenciais =>
      rendaTotal > 0 ? despesasNaoEssenciais / rendaTotal : 0;
  double get percentInvestimentos =>
      rendaTotal > 0 ? investimentos / rendaTotal : 0;

  OrcamentoModel({
    this.rendaTotal = 0.0,
    this.despesasEssenciais = 0.0,
    this.despesasNaoEssenciais = 0.0,
    this.investimentos = 0.0,
  });

  // Avalia a situação do orçamento
  (String mensagem, Color cor) avaliarSituacao() {
    if (totalReal > rendaTotal) {
      return ('Atenção! Gastos excedem a renda', Colors.red);
    }

    if (percentInvestimentos >= 0.2) {
      return (
        'Excelente! Você está acima da meta de investimentos',
        Colors.green
      );
    }

    if (percentInvestimentos >= 0.15 && percentInvestimentos < 0.2) {
      return ('Bom! Você está próximo da meta de investimentos', Colors.blue);
    }

    if (percentEssenciais > 0.6) {
      return ('Atenção! Despesas essenciais muito altas', Colors.orange);
    }

    if (percentNaoEssenciais > 0.4) {
      return ('Atenção! Despesas não essenciais muito altas', Colors.orange);
    }

    if (percentEssenciais <= 0.55 &&
        percentNaoEssenciais <= 0.35 &&
        percentInvestimentos >= 0.15) {
      return ('Bom! Seu orçamento está equilibrado', Colors.green);
    }

    return (
      'Há espaço para melhorias na distribuição do seu orçamento',
      Colors.blue
    );
  }
}
