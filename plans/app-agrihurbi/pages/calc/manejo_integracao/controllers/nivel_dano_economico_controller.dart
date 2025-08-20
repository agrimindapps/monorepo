// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../models/nivel_dano_economico_model.dart';

class NivelDanoEconomicoController extends GetxController {
  final model = NivelDanoEconomicoModel();
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  // Controllers
  final custoProduto = TextEditingController();
  final eficaciaControle = TextEditingController();
  final danoPlanta = TextEditingController();
  final valorProduto = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();

  NivelDanoEconomicoController() {
    _setupListeners();
  }

  void _setupListeners() {
    custoProduto.addListener(() => update());
    eficaciaControle.addListener(() => update());
    danoPlanta.addListener(() => update());
    valorProduto.addListener(() => update());
  }

  @override
  void onClose() {
    custoProduto.dispose();
    eficaciaControle.dispose();
    danoPlanta.dispose();
    valorProduto.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    super.onClose();
  }

  bool get calculado => model.calculado;
  num get resultado => model.resultado;
  String get nivelRisco => model.getNivelRisco();
  String get interpretacao => model.getInterpretacao();

  Future<void> compartilhar() async {
    final shareText = '''
    Nível de Dano Econômico (NDE)
    
    Valores
    Custo do produto de controle: R\$ ${_numberFormat.format(model.custoProduto)}/ha
    Eficácia do controle: ${_numberFormat.format(model.eficaciaControle)}%
    Dano por unidade: ${_numberFormat.format(model.danoPlanta)}%
    Valor do produto agrícola: R\$ ${_numberFormat.format(model.valorProduto)}/unidade
    
    Resultado
    Nível de Dano Econômico: ${_numberFormat.format(model.resultado)} unidades/ha
    ''';

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  bool validarCampos(BuildContext context) {
    if (custoProduto.text.isEmpty) {
      focus1.requestFocus();
      _exibirMensagem(context, 'Informe o custo do produto de controle');
      return false;
    }

    if (eficaciaControle.text.isEmpty) {
      focus2.requestFocus();
      _exibirMensagem(context, 'Informe a eficácia do controle');
      return false;
    }

    if (danoPlanta.text.isEmpty) {
      focus3.requestFocus();
      _exibirMensagem(context, 'Informe o dano por unidade');
      return false;
    }

    if (valorProduto.text.isEmpty) {
      focus4.requestFocus();
      _exibirMensagem(context, 'Informe o valor do produto agrícola');
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    model.custoProduto = num.parse(custoProduto.text.replaceAll(',', '.'));
    model.eficaciaControle =
        num.parse(eficaciaControle.text.replaceAll(',', '.'));
    model.danoPlanta = num.parse(danoPlanta.text.replaceAll(',', '.'));
    model.valorProduto = num.parse(valorProduto.text.replaceAll(',', '.'));

    model.calcular();
    update();

    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    model.limpar();
    custoProduto.clear();
    eficaciaControle.clear();
    danoPlanta.clear();
    valorProduto.clear();
    update();
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
