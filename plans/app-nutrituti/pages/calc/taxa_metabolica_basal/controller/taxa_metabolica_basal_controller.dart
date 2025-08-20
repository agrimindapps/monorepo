// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/taxa_metabolica_basal_model.dart';

class TaxaMetabolicaBasalController extends ChangeNotifier {
  final _model = TaxaMetabolicaBasalModel();
  bool _isCalculated = false;

  // Getters
  TaxaMetabolicaBasalModel get model => _model;
  bool get isCalculated => _isCalculated;

  // Controllers para os campos de texto
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  final idadeController = TextEditingController();

  // Focus nodes
  final focusPeso = FocusNode();
  final focusAltura = FocusNode();
  final focusIdade = FocusNode();

  void setGenero(int value) {
    _model.generoSelecionado = value;
    notifyListeners();
  }

  void setNivelAtividade(int value) {
    _model.nivelAtividadeSelecionado = value;
    notifyListeners();
  }

  bool validarDados(BuildContext context) {
    if (pesoController.text.isEmpty) {
      _showMessage(context, 'Necessário informar o peso.');
      focusPeso.requestFocus();
      return false;
    }

    if (alturaController.text.isEmpty) {
      _showMessage(context, 'Necessário informar a altura.');
      focusAltura.requestFocus();
      return false;
    }

    if (idadeController.text.isEmpty) {
      _showMessage(context, 'Necessário informar a idade.');
      focusIdade.requestFocus();
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarDados(context)) return;

    _model.peso = double.parse(pesoController.text.replaceAll(',', '.'));
    _model.altura = double.parse(alturaController.text);
    _model.idade = int.parse(idadeController.text);
    _model.calcular();
    _isCalculated = true;

    notifyListeners();
  }

  void limpar() {
    _model.limpar();
    pesoController.clear();
    alturaController.clear();
    idadeController.clear();
    _isCalculated = false;

    notifyListeners();
  }

  void _showMessage(BuildContext context, String message,
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

  @override
  void dispose() {
    pesoController.dispose();
    alturaController.dispose();
    idadeController.dispose();
    focusPeso.dispose();
    focusAltura.dispose();
    focusIdade.dispose();
    super.dispose();
  }
}
