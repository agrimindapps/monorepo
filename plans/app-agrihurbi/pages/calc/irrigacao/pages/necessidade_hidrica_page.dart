// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controllers/necessidade_hidrica_controller.dart';
import '../widgets/necessidade_hidrica/necessidade_hidrica_form.dart';
import '../widgets/necessidade_hidrica/necessidade_hidrica_result.dart';

class NecessidadeHidricaPage extends StatefulWidget {
  const NecessidadeHidricaPage({super.key});

  @override
  State<NecessidadeHidricaPage> createState() => _NecessidadeHidricaPageState();
}

class _NecessidadeHidricaPageState extends State<NecessidadeHidricaPage>
    with TickerProviderStateMixin {
  late final NecessidadeHidricaController _controller;
  late final AnimationController _resultAnimationController;

  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _controller = NecessidadeHidricaController();
    _resultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.addListener(_handleControllerUpdate);
  }

  void _handleControllerUpdate() {
    if (_controller.calculado) {
      _resultAnimationController.forward(from: 0);
    }
    setState(() {});
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Necessidade Hídrica'),
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
                  '• Evapotranspiração (ETo): É a quantidade de água perdida para a atmosfera através da evaporação do solo e transpiração das plantas.\n\n'
                  '• Coeficiente de Cultura (Kc): É um fator que relaciona a evapotranspiração da cultura com a evapotranspiração de referência.\n\n'
                  '• Eficiência de Irrigação: Indica quanto da água aplicada é efetivamente aproveitada pela cultura.',
                ),
                SizedBox(height: 16),
                Text(
                  'Como calcular:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Necessidade Bruta = (ETo × Kc) / Eficiência\n\n'
                  'Volume Total = Necessidade Bruta × Área × 10\n'
                  '(O fator 10 converte mm/ha para m³)',
                ),
                SizedBox(height: 16),
                Text(
                  'Observações:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Os valores de Kc variam conforme o estágio da cultura\n'
                  '• A eficiência depende do sistema de irrigação utilizado\n'
                  '• Considere as condições climáticas locais para ETo',
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

  void _compartilhar() {
    final model = _controller.model;
    final shareText = '''
    Necessidade Hídrica

    ${_controller.selectedCultura != null ? 'Cultura: ${_controller.selectedCultura}\n' : ''}
    
    Valores de Entrada:
    Evapotranspiração (ETo): ${_numberFormat.format(model.evapotranspiracao)} mm/dia
    Coeficiente de Cultura (Kc): ${_numberFormat.format(model.coeficienteCultura)}
    Área Plantada: ${_numberFormat.format(model.areaPlantada)} ha
    Eficiência do Sistema: ${_numberFormat.format(model.eficienciaIrrigacao)}%

    Resultados:
    Necessidade Bruta: ${_numberFormat.format(model.necessidadeBruta)} mm/dia
    Volume Total Diário: ${_numberFormat.format(model.volumeTotalDiario)} m³/dia
    
    Calculado com App FNutriTuti
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NecessidadeHidricaFormWidget(
              controller: _controller,
              onShowHelp: _showHelpDialog,
            ),
            if (_controller.calculado)
              NecessidadeHidricaResultWidget(
                controller: _controller,
                animation: _resultAnimationController,
                onShare: _compartilhar,
              ),
          ],
        ),
      ),
    );
  }
}
