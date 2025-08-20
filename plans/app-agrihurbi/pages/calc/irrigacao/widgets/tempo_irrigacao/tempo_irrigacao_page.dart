// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../controllers/tempo_irrigacao_controller.dart';
import 'tempo_irrigacao_form.dart';
import 'tempo_irrigacao_result.dart';

class TempoIrrigacaoPage extends StatefulWidget {
  const TempoIrrigacaoPage({super.key});

  @override
  State<TempoIrrigacaoPage> createState() => _TempoIrrigacaoPageState();
}

class _TempoIrrigacaoPageState extends State<TempoIrrigacaoPage> {
  final _controller = TempoIrrigacaoController();

  void _compartilhar() {
    final model = _controller.model;
    final shareText = '''
    Tempo de Irrigação

    Valores
    Lâmina a aplicar: ${model.laminaAplicarFormatada} mm
    Vazão por emissor: ${model.vazaoEmissor} L/h
    Espaçamento entre emissores: ${model.espacamentoEmissores} m
    Espaçamento entre linhas: ${model.espacamentoLinhas} m
    Eficiência da irrigação: ${model.eficienciaIrrigacao}%
    
    Resultado
    Área por emissor: ${model.areaPorEmissorFormatada} m²
    Volume por emissor: ${model.volumePorEmissorFormatado} L
    Tempo de irrigação: ${model.tempoIrrigacaoFormatado} h (${model.tempoIrrigacaoMinutosFormatado} min)
    Volume total por hectare: ${model.volumeTotalPorHectareFormatado} m³/ha
    
    Calculado com App FNutriTuti
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajuda - Tempo de Irrigação'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conceitos básicos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Lâmina a aplicar: Quantidade de água (em mm) necessária para irrigar adequadamente a cultura.\n'
                  '• Vazão por emissor: Quantidade de água (em L/h) que cada emissor libera.\n'
                  '• Espaçamento: Distância entre emissores e entre linhas de irrigação.\n'
                  '• Eficiência da irrigação: Porcentagem da água aplicada que é efetivamente utilizada pela cultura.',
                ),
                SizedBox(height: 16),
                Text(
                  'Como calcular:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'O tempo de irrigação é calculado pela fórmula:\n\n'
                  'Tempo = (Lâmina × Área por emissor) / (Vazão por emissor × Eficiência)\n\n'
                  'Onde:\n'
                  '• Área por emissor = Espaçamento entre emissores × Espaçamento entre linhas\n'
                  '• Volume por emissor = Lâmina × Área por emissor',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
            child: TempoIrrigacaoForm(
              controller: _controller,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
            child: TempoIrrigacaoResult(
              model: _controller.model,
              isVisible: _controller.calculado,
              onShare: _compartilhar,
            ),
          ),
          TextButton.icon(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline),
            label: const Text('Ajuda sobre tempo de irrigação'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
