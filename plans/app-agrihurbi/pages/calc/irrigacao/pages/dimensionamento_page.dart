// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controllers/dimensionamento_controller.dart';
import '../widgets/dimensionamento/dimensionamento_form.dart';
import '../widgets/dimensionamento/dimensionamento_result.dart';

class DimensionamentoPage extends StatefulWidget {
  const DimensionamentoPage({super.key});

  @override
  State<DimensionamentoPage> createState() => _DimensionamentoPageState();
}

class _DimensionamentoPageState extends State<DimensionamentoPage>
    with TickerProviderStateMixin {
  late final DimensionamentoController _controller;
  late final AnimationController _resultAnimationController;

  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _controller = DimensionamentoController();
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
          title: const Text('Dimensionamento de Irrigação'),
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
                  '• Vazão Requerida: Volume de água necessário por hectare por hora\n\n'
                  '• Área Irrigada: Área total a ser irrigada em hectares\n\n'
                  '• Espaçamento: Distância entre aspersores em metros\n\n'
                  '• Pressão de Operação: Pressão necessária para o funcionamento adequado dos aspersores',
                ),
                SizedBox(height: 16),
                Text(
                  'Como calcular:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Vazão Total = Vazão Requerida × Área\n'
                  '• Área por Aspersor = Espaçamento²\n'
                  '• Número de Aspersores = Área Total ÷ Área por Aspersor\n'
                  '• Vazão por Aspersor = Vazão Total ÷ Número de Aspersores',
                ),
                SizedBox(height: 16),
                Text(
                  'Observações:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Considere as limitações do sistema de bombeamento\n'
                  '• Verifique a uniformidade de distribuição\n'
                  '• Observe o tempo disponível para irrigação',
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
    Dimensionamento de Sistema de Irrigação

    Valores de Entrada:
    Vazão Requerida: ${_numberFormat.format(model.vazaoRequerida)} m³/h/ha
    Área Irrigada: ${_numberFormat.format(model.areaIrrigada)} ha
    Espaçamento: ${_numberFormat.format(model.espacamentoAspersores)} m
    Pressão de Operação: ${_numberFormat.format(model.pressaoOperacao)} mca
    Tempo Disponível: ${_numberFormat.format(model.tempoDisponivel)} h/dia

    Resultados:
    Vazão Total: ${_numberFormat.format(model.vazaoTotal)} m³/h
    Número de Aspersores: ${model.numeroAspersoresFormatado}
    Vazão por Aspersor: ${_numberFormat.format(model.vazaoPorAspersor)} m³/h
    Tempo de Irrigação: ${_numberFormat.format(model.tempoIrrigacaoNecessario)} h
    
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
            DimensionamentoFormWidget(
              controller: _controller,
              onShowHelp: _showHelpDialog,
            ),
            if (_controller.calculado)
              DimensionamentoResultWidget(
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
