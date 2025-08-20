// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/conversao_model.dart';

/// Controller para a calculadora de conversão
class ConversaoController {
  final ConversaoModel model;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ValueNotifiers específicos para otimizar rebuilds
  late final ValueNotifier<double?> resultadoNotifier;
  late final ValueNotifier<bool> calculadoNotifier;
  late final ValueNotifier<bool> isLoadingNotifier;

  ConversaoController(this.model) {
    resultadoNotifier = ValueNotifier(model.resultado);
    calculadoNotifier = ValueNotifier(model.calculado);
    isLoadingNotifier = ValueNotifier(false);
  }

  /// Realiza o cálculo de conversão
  Future<void> calcular(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        isLoadingNotifier.value = true;
        
        // Simular delay para demonstrar loading state
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Adicione aqui a lógica de cálculo real
        final valor =
            double.parse(model.valorController.text.replaceAll(',', '.'));
        model.resultado = valor * 2; // Exemplo: multiplicando por 2
        model.calculado = true;
        
        // Atualizar notifiers específicos
        resultadoNotifier.value = model.resultado;
        calculadoNotifier.value = model.calculado;
        isLoadingNotifier.value = false;

        // Mostrar feedback de sucesso
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Cálculo realizado com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        isLoadingNotifier.value = false;
        
        // Mostrar erro
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Erro no cálculo. Verifique os dados inseridos.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  /// Limpa todos os campos e resultados
  void limpar() {
    model.limpar();
    resultadoNotifier.value = model.resultado;
    calculadoNotifier.value = model.calculado;
  }

  /// Valida se um valor é numérico
  String? validarValor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }
    if (double.tryParse(value) == null) {
      return 'Por favor, insira um número válido';
    }
    return null;
  }

  /// Libera os recursos
  void dispose() {
    resultadoNotifier.dispose();
    calculadoNotifier.dispose();
    isLoadingNotifier.dispose();
    model.dispose();
  }
}
