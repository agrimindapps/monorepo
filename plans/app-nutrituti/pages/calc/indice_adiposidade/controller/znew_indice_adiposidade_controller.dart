// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/znew_indice_adiposidade_model.dart';
import '../utils/znew_indice_adiposidade_utils.dart';

class ZNewIndiceAdiposidadeController extends ChangeNotifier {
  // Controllers e focus nodes
  final quadrilController = TextEditingController();
  final alturaController = TextEditingController();
  final idadeController = TextEditingController();
  final focusQuadril = FocusNode();
  final focusAltura = FocusNode();
  final focusIdade = FocusNode();

  int generoSelecionado = 1;
  bool calculado = false;
  late ZNewIndiceAdiposidadeModel modelo;

  ZNewIndiceAdiposidadeController() {
    modelo = ZNewIndiceAdiposidadeModel.empty();
  }

  void setGeneroSelecionado(int genero) {
    generoSelecionado = genero;
    notifyListeners();
  }

  void calcular(BuildContext context) {
    if (quadrilController.text.isEmpty) {
      _exibirMensagem(
          context, 'Necessário informar a circunferência do quadril');
      focusQuadril.requestFocus();
      return;
    }
    if (alturaController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a altura');
      focusAltura.requestFocus();
      return;
    }
    if (idadeController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a idade');
      focusIdade.requestFocus();
      return;
    }
    modelo.generoSelecionado = generoSelecionado;
    modelo.quadril = double.parse(quadrilController.text.replaceAll(',', '.'));
    modelo.altura = double.parse(alturaController.text.replaceAll(',', '.'));
    modelo.idade = int.parse(idadeController.text);
    modelo.iac =
        ZNewIndiceAdiposidadeUtils.calcularIAC(modelo.quadril, modelo.altura);
    modelo.classificacao = ZNewIndiceAdiposidadeUtils.obterClassificacao(
        modelo.iac, modelo.generoSelecionado);
    modelo.comentario =
        ZNewIndiceAdiposidadeUtils.obterComentario(modelo.classificacao);
    calculado = true;
    notifyListeners();
    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    generoSelecionado = 1;
    quadrilController.clear();
    alturaController.clear();
    idadeController.clear();
    modelo = ZNewIndiceAdiposidadeModel.empty();
    calculado = false;
    focusQuadril.requestFocus();
    notifyListeners();
  }

  void compartilhar() {
    final texto = ZNewIndiceAdiposidadeUtils.gerarTextoCompartilhamento(modelo);
    Share.share(texto);
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
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
  }

  @override
  void dispose() {
    quadrilController.dispose();
    alturaController.dispose();
    idadeController.dispose();
    focusQuadril.dispose();
    focusAltura.dispose();
    focusIdade.dispose();
    super.dispose();
  }
}
