// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/massa_corporea_model.dart';

class MassaCorporeaController extends ChangeNotifier {
  final model = MassaCorporeaModel();
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();
  final FocusNode focusPeso = FocusNode();
  final FocusNode focusAltura = FocusNode();

  // Formatadores de texto
  final pesomask = MaskTextInputFormatter(
    mask: '##,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final alturamask = MaskTextInputFormatter(
    mask: '#,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get calculado => model.calculado;
  double get resultado => model.resultado;
  String get textIMC => model.textIMC;
  int get generoSelecionado => model.generoSelecionado;
  double get altura => model.altura;
  double get peso => model.peso;

  List<Map<String, dynamic>> get generos => model.generos;

  void setGenero(int value) {
    model.generoSelecionado = value;
    notifyListeners();
  }

  void calcular(BuildContext context) {
    if (pesoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o peso.');
      focusPeso.requestFocus();
      return;
    }

    if (alturaController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a altura.');
      focusAltura.requestFocus();
      return;
    }

    model.altura = double.parse(alturaController.text.replaceAll(',', '.'));
    model.peso = double.parse(pesoController.text.replaceAll(',', '.'));

    model.resultado =
        model.peso / ((model.altura / 100) * (model.altura / 100));
    model.resultado = double.parse(model.resultado.toStringAsFixed(2));

    _calcularCategoria();
    model.calculado = true;
    ScaffoldMessenger.of(context).clearSnackBars();
    notifyListeners();
  }

  void _calcularCategoria() {
    if (model.generoSelecionado == 1) {
      if (model.resultado < 20.7) {
        model.textIMC = 'Abaixo do Peso (IMC menor que 20,7)';
      } else if (model.resultado >= 20.7 && model.resultado < 26.4) {
        model.textIMC = 'Peso Ideal (IMC entre 20,7 e 26,4)';
      } else if (model.resultado >= 26.4 && model.resultado <= 27.8) {
        model.textIMC = 'Obesidade I (IMC entre 26,4 e 27,8)';
      } else if (model.resultado >= 27.8 && model.resultado <= 31.1) {
        model.textIMC = 'Obesidade II (IMC entre 27,8 e 31,1)';
      } else {
        model.textIMC = 'Obesidade III (IMC maior que 31,1)';
      }
    } else {
      if (model.resultado < 19.1) {
        model.textIMC = 'Abaixo do Peso (IMC menor que 19,1)';
      } else if (model.resultado >= 19.1 && model.resultado <= 25.8) {
        model.textIMC = 'Peso Ideal (IMC entre 19,1 e 25,8)';
      } else if (model.resultado >= 25.8 && model.resultado <= 27.3) {
        model.textIMC = 'Obesidade I (IMC entre 25,8 e 27,3)';
      } else if (model.resultado >= 27.3 && model.resultado <= 32.3) {
        model.textIMC = 'Obesidade II (IMC entre 27,3 e 32,3)';
      } else {
        model.textIMC = 'Obesidade III (IMC maior que 32,3)';
      }
    }
  }

  void limpar() {
    model.limpar();
    alturaController.clear();
    pesoController.clear();
    notifyListeners();
  }

  void compartilhar() {
    StringBuffer t = StringBuffer();
    t.writeln('Massa Corporal');
    t.writeln();
    t.writeln('Valores');
    t.writeln(
        'Gênero: ${model.generoSelecionado == 1 ? 'Masculino' : 'Feminino'}');
    t.writeln('Altura: ${model.altura} Cm');
    t.writeln('Peso: ${model.peso.toStringAsFixed(2)} Kgs');
    t.writeln();
    t.writeln('Resultados');
    t.writeln('Seu IMC: ${model.resultado.toStringAsFixed(2)}');
    t.writeln('Categoria: ${model.textIMC}');

    SharePlus.instance.share(ShareParams(text: t.toString()));
  }

  String getSuggestionText() {
    if (model.textIMC.contains('Abaixo do Peso')) {
      return 'Considere consultar um nutricionista para elaborar um plano alimentar que ajude a ganhar peso de forma saudável.';
    } else if (model.textIMC.contains('Peso Ideal')) {
      return 'Continue mantendo hábitos saudáveis de alimentação e atividade física regular para preservar seu peso ideal.';
    } else if (model.textIMC.contains('Obesidade')) {
      return 'Recomenda-se consultar um profissional de saúde para orientações específicas sobre alimentação e atividade física adequada.';
    } else {
      return 'Procure adotar uma alimentação balanceada e praticar exercícios físicos regularmente para melhorar seus índices de saúde.';
    }
  }

  Color getColorForIMC(bool isDark) {
    if (model.textIMC.contains('Peso Ideal')) {
      return isDark ? Colors.green.shade300 : Colors.green;
    } else if (model.textIMC.contains('Abaixo do Peso')) {
      return isDark ? Colors.amber.shade300 : Colors.amber;
    } else if (model.textIMC.contains('Obesidade I')) {
      return isDark ? Colors.orange.shade300 : Colors.orange;
    } else if (model.textIMC.contains('Obesidade II')) {
      return isDark ? Colors.deepOrange.shade300 : Colors.deepOrange;
    } else {
      return isDark ? Colors.red.shade300 : Colors.red;
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
    alturaController.dispose();
    pesoController.dispose();
    focusPeso.dispose();
    focusAltura.dispose();
    super.dispose();
  }
}
