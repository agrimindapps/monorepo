// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/controllers/models/valor_futuro_model.dart';

class ValorFuturoController extends ChangeNotifier {
  final model = ValorFuturoModel();
  final valorInicialController = TextEditingController();
  final taxaJurosController = TextEditingController();
  final periodoController = TextEditingController();
  final FocusNode focusValorInicial = FocusNode();
  final FocusNode focusTaxaJuros = FocusNode();
  final FocusNode focusPeriodo = FocusNode();

  // Formatadores de texto
  final valorInicialMask = MaskTextInputFormatter(
    mask: '#####,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final taxaJurosMask = MaskTextInputFormatter(
    mask: '##,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final periodoMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get calculado => model.calculado;
  double get valorInicial => model.valorInicial;
  double get taxa => model.taxa;
  int get periodo => model.periodo;
  bool get ehAnual => model.ehAnual;
  double get valorFuturo => model.valorFuturo;
  double get lucro => model.lucro;
  String get classificacao => model.classificacao;
  String get periodoFormatado => '$periodo ${ehAnual ? 'anos' : 'meses'}';

  void setTipoTaxa(bool isAnual) {
    model.ehAnual = isAnual;
    notifyListeners();
  }

  void calcular(BuildContext context) {
    if (valorInicialController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o valor inicial.');
      focusValorInicial.requestFocus();
      return;
    }

    if (taxaJurosController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a taxa de juros.');
      focusTaxaJuros.requestFocus();
      return;
    }

    if (periodoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o período.');
      focusPeriodo.requestFocus();
      return;
    }

    model.valorInicial =
        double.parse(valorInicialController.text.replaceAll(',', '.'));
    model.taxa = double.parse(taxaJurosController.text.replaceAll(',', '.'));
    model.periodo = int.parse(periodoController.text);

    model.calcular();
    model.calculado = true;
    ScaffoldMessenger.of(context).clearSnackBars();
    notifyListeners();
  }

  void limpar() {
    model.limpar();
    valorInicialController.clear();
    taxaJurosController.clear();
    periodoController.clear();
    notifyListeners();
  }

  void compartilhar() {
    StringBuffer t = StringBuffer();
    t.writeln('Valor Futuro');
    t.writeln();
    t.writeln('Valores');
    t.writeln('Valor Inicial: R\$ ${model.valorInicial.toStringAsFixed(2)}');
    t.writeln(
        'Taxa de Juros: ${model.taxa.toStringAsFixed(2)}% ${model.ehAnual ? 'ao ano' : 'ao mês'}');
    t.writeln('Período: ${model.periodo} ${model.ehAnual ? 'anos' : 'meses'}');
    t.writeln();
    t.writeln('Resultados');
    t.writeln('Valor Futuro: R\$ ${model.valorFuturo.toStringAsFixed(2)}');
    t.writeln('Lucro: R\$ ${model.lucro.toStringAsFixed(2)}');
    t.writeln('Classificação: ${model.classificacao}');

    Share.share(t.toString());
  }

  Color getColorForValorFuturo(bool isDark) {
    if (model.valorFuturo > model.valorInicial * 2) {
      return isDark ? Colors.green.shade300 : Colors.green; // Mais que dobrou
    } else if (model.valorFuturo > model.valorInicial * 1.5) {
      return isDark ? Colors.blue.shade300 : Colors.blue; // Aumentou 50%
    } else if (model.valorFuturo > model.valorInicial * 1.2) {
      return isDark ? Colors.amber.shade300 : Colors.amber; // Aumentou 20%
    } else {
      return isDark ? Colors.orange.shade300 : Colors.orange; // Aumento menor
    }
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

  @override
  void dispose() {
    valorInicialController.dispose();
    taxaJurosController.dispose();
    periodoController.dispose();
    focusValorInicial.dispose();
    focusTaxaJuros.dispose();
    focusPeriodo.dispose();
    super.dispose();
  }
}
