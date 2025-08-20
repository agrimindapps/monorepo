// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/gestacao_model.dart';

class GestacaoUtils {
  static void exibirMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void compartilhar(GestacaoModel model) {
    if (!model.calculado || model.dataParto == null) return;

    StringBuffer t = StringBuffer();
    t.writeln('Calculadora de Gestação Animal');
    t.writeln();
    t.writeln('Espécie: ${model.especieController.text}');
    t.writeln('Data do cio/acasalamento: ${model.dataInicioController.text}');
    t.writeln();
    t.writeln('Resultados:');
    t.writeln(
        'Previsão de parto: ${model.dataParto!.day}/${model.dataParto!.month}/${model.dataParto!.year}');
    t.writeln('Período de gestação: ${model.diasGestacao} dias');
    t.writeln();
    t.writeln('Recomendações importantes:');
    t.writeln(
        '• Acompanhamento veterinário regular é essencial durante toda a gestação.');
    t.writeln(
        '• Mantenha a alimentação adequada para gestantes conforme orientação veterinária.');
    t.writeln(
        '• Prepare um local tranquilo, limpo e aquecido para o parto várias semanas antes da data prevista.');
    t.writeln(
        '• Tenha o contato do seu veterinário facilmente acessível em caso de emergência.');

    Share.share(t.toString());
  }
}
