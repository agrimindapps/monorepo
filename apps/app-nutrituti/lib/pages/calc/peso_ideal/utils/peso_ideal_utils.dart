// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/peso_ideal_model.dart';

class PesoIdealUtils {
  static void calcular(BuildContext context, PesoIdealModel model) {
    if (model.alturaController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a altura');
      model.focusAltura.requestFocus();
      return;
    }

    final altura =
        double.parse(model.alturaController.text.replaceAll(',', '.'));

    if (altura < 130) {
      _exibirMensagem(context, 'Altura deve ser maior que 130 cm');
      model.focusAltura.requestFocus();
      return;
    }

    model.calcular();
    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  static void _exibirMensagem(BuildContext context, String message,
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

  static void compartilhar(PesoIdealModel model) {
    final shareText = '''
    Peso Ideal
    
    Valores
    Gênero: ${model.generoDef['text']}
    Altura: ${model.numberFormat.format(model.altura)} cm
    
    Resultado
    Peso ideal considerado: ${model.numberFormat.format(model.resultado)} Kgs
    
    Método de cálculo: ${model.generoDef['id'] == 1 ? 'Masculino' : 'Feminino'}
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }
}
