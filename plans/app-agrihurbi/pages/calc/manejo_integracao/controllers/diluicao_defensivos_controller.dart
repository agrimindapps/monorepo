// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../models/diluicao_defensivos_model.dart';

class DiluicaoDefensivosController extends GetxController {
  final model = DiluicaoDefensivosModel();
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  // Controllers
  final doseRecomendada = TextEditingController();
  final volumeCalda = TextEditingController();
  final volumePulverizador = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  DiluicaoDefensivosController() {
    _setupListeners();
  }

  void _setupListeners() {
    // Notificar mudanças e validar formato dos números em tempo real
    doseRecomendada.addListener(() {
      _validarFormatoNumerico(doseRecomendada);
      
    });

    volumeCalda.addListener(() {
      _validarFormatoNumerico(volumeCalda);
      
    });

    volumePulverizador.addListener(() {
      _validarFormatoNumerico(volumePulverizador);
      
    });
  }

  void _validarFormatoNumerico(TextEditingController controller) {
    if (controller.text.isEmpty) return;

    final text = controller.text;
    // Permitir apenas números, vírgula e ponto
    if (!RegExp(r'^[\d,.]+$').hasMatch(text)) {
      controller.text = text.replaceAll(RegExp(r'[^\d,.]'), '');
      return;
    }

    // Garantir apenas uma vírgula ou ponto
    final pontos = text.split('.').length - 1;
    final virgulas = text.split(',').length - 1;
    if (pontos + virgulas > 1) {
      controller.text = text.substring(0, text.length - 1);
    }
  }

  @override
  void onClose() {
    doseRecomendada.dispose();
    volumeCalda.dispose();
    volumePulverizador.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    super.onClose();
  }

  String get unidadeSelecionada => model.unidadeSelecionada;
  List<String> get unidades => DiluicaoDefensivosModel.unidades;
  bool get calculado => model.calculado;
  num get resultado => model.resultado;
  num get areaAtingida => model.areaAtingida;

  void setUnidade(String? novaUnidade) {
    if (novaUnidade != null && novaUnidade != model.unidadeSelecionada) {
      // Resetar o estado quando a unidade mudar
      limpar();
      model.unidadeSelecionada = novaUnidade;
      
    }
  }

  Future<void> compartilhar() async {
    final shareText = '''
    Diluição de Defensivos Agrícolas
    
    Valores
    Dose recomendada: ${_numberFormat.format(model.doseRecomendada)} ${model.unidadeOriginal}/ha
    Volume de calda: ${_numberFormat.format(model.volumeCalda)} L/ha
    Volume do pulverizador: ${_numberFormat.format(model.volumePulverizador)} L
    
    Resultado
    Quantidade do defensivo: ${_numberFormat.format(model.resultado)} ${model.unidadeSelecionada}
    Área atingida com o pulverizador: ${_numberFormat.format(model.areaAtingida)} ha
    ''';

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  bool validarCampos(BuildContext context) {
    // Validar campos vazios
    if (doseRecomendada.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, 'Informe a dose recomendada');
      return false;
    }

    if (volumeCalda.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, 'Informe o volume de calda recomendado');
      return false;
    }

    if (volumePulverizador.text.isEmpty) {
      focus3.requestFocus();
      _exibirMensagem(context, 'Informe o volume do pulverizador');
      return false;
    }

    // Validar formato dos números
    final doseValida =
        num.tryParse(doseRecomendada.text.replaceAll(',', '.')) != null;
    final caldaValida =
        num.tryParse(volumeCalda.text.replaceAll(',', '.')) != null;
    final pulverizadorValido =
        num.tryParse(volumePulverizador.text.replaceAll(',', '.')) != null;

    if (!doseValida || !caldaValida || !pulverizadorValido) {
      _exibirMensagem(context, 'Um ou mais valores não são números válidos');
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    try {
      // Validar e converter os valores
      final dose = _validarEConverter(
          doseRecomendada.text, 'dose recomendada', 0.001, 1000);
      final calda =
          _validarEConverter(volumeCalda.text, 'volume de calda', 1, 2000);
      final pulverizador = _validarEConverter(
          volumePulverizador.text, 'volume do pulverizador', 1, 5000);

      if (dose == null || calda == null || pulverizador == null) return;

      model.doseRecomendada = dose;
      model.volumeCalda = calda;
      model.volumePulverizador = pulverizador;

      model.calcular();
      

      _exibirMensagem(context, 'Cálculo realizado com sucesso!',
          isError: false);
    } catch (e) {
      _exibirMensagem(context, 'Erro ao calcular: ${e.toString()}');
    }
  }

  num? _validarEConverter(String valor, String campo, num min, num max) {
    if (valor.isEmpty) return null;

    final numero = num.tryParse(valor.replaceAll(',', '.'));
    if (numero == null) {
      throw Exception('O valor de $campo não é um número válido');
    }
    if (numero < min) {
      throw Exception('O valor de $campo não pode ser menor que $min');
    }
    if (numero > max) {
      throw Exception('O valor de $campo não pode ser maior que $max');
    }
    return numero;
  }

  void limpar() {
    model.limpar();
    doseRecomendada.clear();
    volumeCalda.clear();
    volumePulverizador.clear();
    
  }

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  String formatNumber(num value) => _numberFormat.format(value);
}
