// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controllers/capacidade_campo_controller.dart';
import '../widgets/capacidade_campo/capacidade_campo_form.dart';
import '../widgets/capacidade_campo/capacidade_campo_result.dart';

class CapacidadeCampoPage extends StatefulWidget {
  const CapacidadeCampoPage({super.key});

  @override
  State<CapacidadeCampoPage> createState() => _CapacidadeCampoPageState();
}

class _CapacidadeCampoPageState extends State<CapacidadeCampoPage>
    with TickerProviderStateMixin {
  late final CapacidadeCampoController _controller;
  late final AnimationController _resultAnimationController;

  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');
  final _percentFormat = NumberFormat('#,##0.0', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _controller = CapacidadeCampoController();
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
          title: const Text('Capacidade de Campo e Água Disponível'),
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
                  '• Capacidade de Campo (CC): É o teor de água retido no solo após a drenagem do excesso, geralmente atingida 1-3 dias após uma chuva ou irrigação.\n'
                  '• Ponto de Murcha Permanente (PMP): É o teor de água no solo em que as plantas não conseguem mais extrair água suficiente e murcham permanentemente.\n'
                  '• Água Disponível Total (ADT): É a diferença entre a capacidade de campo e o ponto de murcha permanente.\n'
                  '• Água Facilmente Disponível (AFD): É a porção da água disponível que as plantas conseguem extrair facilmente sem estresse (normalmente 50% da ADT).',
                ),
                SizedBox(height: 16),
                Text(
                  'Como calcular:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Água Disponível Total (mm) = (CC - PMP) × Densidade × (Profundidade / 10)\n'
                  '• Volume Total (m³) = ADT (mm) × Área (ha) × 10\n'
                  '• Eficiência de Armazenamento (%) = ((Umidade atual - PMP) / (CC - PMP)) × 100',
                ),
                SizedBox(height: 16),
                Text(
                  'Observações:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• A eficiência acima de 50% indica boa disponibilidade de água.\n'
                  '• Valores abaixo de 25% indicam necessidade de irrigação urgente.\n'
                  '• Os valores referenciais para cada tipo de solo são aproximados e podem variar conforme composição específica.',
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
    String shareText;

    if (_controller.camposAdicionais) {
      shareText = '''
      Capacidade de Campo e Ponto de Murcha

      Tipo de Solo: ${_controller.tipoSolo}
      
      Valores de Entrada:
      Peso do solo úmido: ${_numberFormat.format(model.soloPesoUmido)} g
      Peso do solo seco: ${_numberFormat.format(model.soloPesoSeco)} g
      Capacidade de campo: ${_numberFormat.format(model.capacidadeCampo)} %
      Ponto de murcha permanente: ${_numberFormat.format(model.pontoMurcha)} %
      Densidade do solo: ${_numberFormat.format(model.densidadeSolo)} g/cm³
      Profundidade efetiva do sistema radicular: ${_numberFormat.format(model.profundidadeRaiz)} cm
      Área irrigada: ${_numberFormat.format(model.areaIrrigada)} ha

      Resultados:
      Umidade gravimétrica atual: ${_numberFormat.format(model.umidadeGravimetrica)} %
      Umidade volumétrica atual: ${_numberFormat.format(model.umidadeVolumetrica)} %
      Água disponível total: ${_numberFormat.format(model.aguaDisponivel)} mm
      Água facilmente disponível: ${_numberFormat.format(model.aguaFacilmenteDisponivel)} mm
      Volume total de água disponível: ${_numberFormat.format(model.volumeTotalAgua)} m³
      Eficiência de armazenamento: ${_percentFormat.format(model.eficienciaArmazenamento)} %
      
      Calculado com App FNutriTuti
      ''';
    } else {
      shareText = '''
      Capacidade de Campo e Ponto de Murcha

      Tipo de Solo: ${_controller.tipoSolo}
      
      Valores de Entrada:
      Capacidade de campo: ${_numberFormat.format(model.capacidadeCampo)} %
      Ponto de murcha permanente: ${_numberFormat.format(model.pontoMurcha)} %
      Densidade do solo: ${_numberFormat.format(model.densidadeSolo)} g/cm³
      Profundidade efetiva do sistema radicular: ${_numberFormat.format(model.profundidadeRaiz)} cm
      Área irrigada: ${_numberFormat.format(model.areaIrrigada)} ha

      Resultados:
      Água disponível total: ${_numberFormat.format(model.aguaDisponivel)} mm
      Água facilmente disponível: ${_numberFormat.format(model.aguaFacilmenteDisponivel)} mm
      Volume total de água disponível: ${_numberFormat.format(model.volumeTotalAgua)} m³
      
      Calculado com App FNutriTuti
      ''';
    }

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
            CapacidadeCampoFormWidget(
              controller: _controller,
              onShowHelp: _showHelpDialog,
            ),
            if (_controller.calculado)
              CapacidadeCampoResultWidget(
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
