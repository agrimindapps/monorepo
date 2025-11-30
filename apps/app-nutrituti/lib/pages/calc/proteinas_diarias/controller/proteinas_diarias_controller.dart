// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/proteinas_diarias_model.dart';

class ProteinasDiariasController {
  final ProteinasDiariasModel model;

  ProteinasDiariasController(this.model);

  void calcular(BuildContext context) {
    if (model.pesoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o peso');
      model.focusPeso.requestFocus();
      return;
    }

    model.peso = double.parse(model.pesoController.text.replaceAll(',', '.'));

    if (model.peso <= 0) {
      _exibirMensagem(context, 'Peso deve ser maior que 0');
      model.focusPeso.requestFocus();
      return;
    }

    // Cálculo baseado no nível de atividade
    double fatorAtividade = _getFatorAtividade(model.nivelAtividade);

    // Cálculo das proteínas (g/kg de peso corporal)
    model.proteinasMinimas = model.peso * fatorAtividade;
    model.proteinasMaximas =
        model.peso * (fatorAtividade + 0.4); // Adiciona margem superior

    model.calculado = true;

    // Exibir mensagem de sucesso
    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  double _getFatorAtividade(String nivel) {
    switch (nivel) {
      case 'Sedentário':
        return 0.8;
      case 'Levemente ativo':
        return 1.0;
      case 'Moderadamente ativo':
        return 1.2;
      case 'Muito ativo':
        return 1.6;
      case 'Extremamente ativo':
        return 2.0;
      default:
        return 0.8;
    }
  }

  void limpar() {
    model.limpar();
  }

  void compartilhar() {
    if (!model.calculado) return;

    // TODO: Implement share functionality
    // final shareText = '''
    // Cálculo de Proteínas Diárias
    // 
    // Valores de entrada:
    // Peso: ${model.numberFormat.format(model.peso)} kg
    // Nível de atividade: ${model.nivelAtividade}
    // 
    // Resultado:
    // Consumo recomendado de proteínas:
    // Mínimo: ${model.numberFormat.format(model.proteinasMinimas)} g/dia
    // Máximo: ${model.numberFormat.format(model.proteinasMaximas)} g/dia
    // ''';
    // SharePlus.instance.share(ShareParams(text: shareText));
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
}
