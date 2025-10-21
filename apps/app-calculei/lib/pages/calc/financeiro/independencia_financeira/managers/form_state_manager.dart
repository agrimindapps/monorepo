// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/services/formatting_service.dart';

class FormStateManager extends ChangeNotifier {
  final _patrimonioAtualController = TextEditingController();
  final _despesasMensaisController = TextEditingController();
  final _aporteMensalController = TextEditingController();
  final _retornoInvestimentosController = TextEditingController();
  final _taxaRetiradaController = TextEditingController(text: '4,0');

  final _formatoMoeda = OptimizedMoneyInputFormatter();
  final _formatoNumerico = PercentInputFormatter();

  // Getters
  TextEditingController get patrimonioAtualController => _patrimonioAtualController;
  TextEditingController get despesasMensaisController => _despesasMensaisController;
  TextEditingController get aporteMensalController => _aporteMensalController;
  TextEditingController get retornoInvestimentosController => _retornoInvestimentosController;
  TextEditingController get taxaRetiradaController => _taxaRetiradaController;
  OptimizedMoneyInputFormatter get formatoMoeda => _formatoMoeda;
  PercentInputFormatter get formatoNumerico => _formatoNumerico;

  void limpar() {
    _patrimonioAtualController.clear();
    _despesasMensaisController.clear();
    _aporteMensalController.clear();
    _retornoInvestimentosController.clear();
    _taxaRetiradaController.text = '4,0';
    notifyListeners();
  }

  void addFormListener(VoidCallback listener) {
    _patrimonioAtualController.addListener(listener);
    _despesasMensaisController.addListener(listener);
    _aporteMensalController.addListener(listener);
    _retornoInvestimentosController.addListener(listener);
    _taxaRetiradaController.addListener(listener);
  }

  void removeFormListener(VoidCallback listener) {
    _patrimonioAtualController.removeListener(listener);
    _despesasMensaisController.removeListener(listener);
    _aporteMensalController.removeListener(listener);
    _retornoInvestimentosController.removeListener(listener);
    _taxaRetiradaController.removeListener(listener);
  }

  @override
  void dispose() {
    _patrimonioAtualController.dispose();
    _despesasMensaisController.dispose();
    _aporteMensalController.dispose();
    _retornoInvestimentosController.dispose();
    _taxaRetiradaController.dispose();
    super.dispose();
  }
}
