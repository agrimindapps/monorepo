// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/controller/model/reserva_emergencia_model.dart';
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/controller/utils/reserva_emergencia_utils.dart';

class ReservaEmergenciaController extends ChangeNotifier {
  // Controllers para os campos de entrada
  final TextEditingController despesasMensaisController =
      TextEditingController();
  final TextEditingController despesasExtrasController =
      TextEditingController();
  final TextEditingController mesesController =
      TextEditingController(text: '6');
  final TextEditingController valorPoupadoController = TextEditingController();

  // Focus nodes para controle de foco
  final FocusNode focusDespesasMensais = FocusNode();
  final FocusNode focusDespesasExtras = FocusNode();
  final FocusNode focusMeses = FocusNode();
  final FocusNode focusValorPoupado = FocusNode();

  // Estado da calculadora
  bool _resultadoVisible = false;
  ReservaEmergenciaModel _modelo = ReservaEmergenciaModel.empty();
  Map<String, num> _tempoConstrucao = {'anos': 0, 'meses': 0};

  // Getters
  bool get resultadoVisible => _resultadoVisible;
  ReservaEmergenciaModel get modelo => _modelo;
  Map<String, num> get tempoConstrucao => _tempoConstrucao;

  // Decrementa o número de meses
  void decrementarMeses() {
    final valorAtual = int.tryParse(mesesController.text) ?? 0;
    if (valorAtual > 1) {
      mesesController.text = (valorAtual - 1).toString();
    }
  }

  // Incrementa o número de meses
  void incrementarMeses() {
    final valorAtual = int.tryParse(mesesController.text) ?? 0;
    mesesController.text = (valorAtual + 1).toString();
  }

  // Limpa todos os campos
  void limparCampos() {
    despesasMensaisController.clear();
    despesasExtrasController.clear();
    mesesController.text = '6';
    valorPoupadoController.clear();
    _resultadoVisible = false;
    notifyListeners();
  }

  Color getColorForCategoria(bool isDark) {
    if (!_resultadoVisible) {
      return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }

    switch (modelo.categoriaReserva) {
      case 'Mínima':
        return isDark ? Colors.red.shade300 : Colors.red;
      case 'Básica':
        return isDark ? Colors.orange.shade300 : Colors.orange;
      case 'Confortável':
        return isDark ? Colors.green.shade300 : Colors.green;
      case 'Robusta':
        return isDark ? Colors.green.shade300 : Colors.green;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  // Calcula a reserva de emergência
  bool calcularReserva(BuildContext context) {
    // Validar entrada
    if (!_validarEntrada(context)) {
      return false;
    }

    // Parsear os valores
    final double despesasMensais =
        _parseMoneyValue(despesasMensaisController.text);
    final double despesasExtras =
        _parseMoneyValue(despesasExtrasController.text);
    final int mesesDesejados = int.tryParse(mesesController.text) ?? 0;

    // Calcular o valor da reserva
    final double valorTotalReserva = ReservaEmergenciaUtils.calcularReserva(
      despesasMensais,
      despesasExtras,
      mesesDesejados,
    );

    // Calcular tempo estimado para construção da reserva se houver entrada
    final valorPoupado = _parseMoneyValue(valorPoupadoController.text);
    final Map<String, num> tempoConstrucao =
        ReservaEmergenciaUtils.estimarTempoConstrucao(
      valorTotalReserva,
      valorPoupado,
    );

    // Criar o modelo com os resultados
    _modelo = ReservaEmergenciaModel(
      despesasMensais: despesasMensais,
      despesasExtras: despesasExtras,
      mesesDesejados: mesesDesejados,
      valorTotalReserva: valorTotalReserva,
    );

    _tempoConstrucao = tempoConstrucao;
    _resultadoVisible = true;
    notifyListeners();
    return true;
  }

  // Compartilha os resultados
  void compartilharResultados() {
    if (!_resultadoVisible) return;

    final texto = '''
Cálculo de Reserva de Emergência:

Despesas Mensais: ${ReservaEmergenciaUtils.formatarMoeda(modelo.despesasMensais)}
${modelo.despesasExtras > 0 ? 'Despesas Extras: ${ReservaEmergenciaUtils.formatarMoeda(modelo.despesasExtras)}\n' : ''}
Período: ${modelo.mesesDesejados} meses
Valor Total: ${ReservaEmergenciaUtils.formatarMoeda(modelo.valorTotalReserva)}
Categoria: ${modelo.categoriaReserva}

${_tempoConstrucao['anos']! > 0 || _tempoConstrucao['meses']! > 0 ? '\nTempo estimado para construção:\n' : ''}${_tempoConstrucao['anos']! > 0 ? '${_tempoConstrucao['anos']} ${_tempoConstrucao['anos']! == 1 ? 'ano' : 'anos'}' : ''}${_tempoConstrucao['anos']! > 0 && _tempoConstrucao['meses']! > 0 ? ' e ' : ''}${_tempoConstrucao['meses']! > 0 ? '${_tempoConstrucao['meses']} ${_tempoConstrucao['meses']! == 1 ? 'mês' : 'meses'}' : ''}''';

    Share.share(texto);
  }

  bool _validarEntrada(BuildContext context) {
    if (despesasMensaisController.text.isEmpty) {
      _exibirMensagem(context, 'Informe suas despesas mensais');
      return false;
    }

    final despesasMensais = _parseMoneyValue(despesasMensaisController.text);
    if (despesasMensais <= 0) {
      _exibirMensagem(
          context, 'O valor das despesas mensais deve ser maior que zero');
      return false;
    }

    final meses = int.tryParse(mesesController.text);
    if (meses == null || meses <= 0) {
      _exibirMensagem(context, 'O número de meses deve ser maior que zero');
      return false;
    }

    return true;
  }

  void _exibirMensagem(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  double _parseMoneyValue(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(
          value
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim(),
        ) ??
        0;
  }

  @override
  void dispose() {
    despesasMensaisController.dispose();
    despesasExtrasController.dispose();
    mesesController.dispose();
    valorPoupadoController.dispose();
    focusDespesasMensais.dispose();
    focusDespesasExtras.dispose();
    focusMeses.dispose();
    focusValorPoupado.dispose();
    super.dispose();
  }
}
