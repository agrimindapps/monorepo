// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../utils/despesas_utils.dart';

class DespesaCadastroFormHelpers {
  static String getCharacterCountText(int current, int max) {
    return '$current/$max';
  }

  static Color getCharacterCountColor(int current, int max) {
    final percentage = current / max;

    if (percentage >= 1.0) {
      return const Color(0xFFE53935); // Red - over limit
    } else if (percentage >= 0.8) {
      return const Color(0xFFFF9800); // Orange - near limit
    } else {
      return const Color(0xFF757575); // Gray - normal
    }
  }

  static bool isCharacterLimitExceeded(int current, int max) {
    return current > max;
  }

  static bool isCharacterLimitNear(int current, int max) {
    return current > (max * 0.8);
  }

  static Map<String, dynamic> getFormStatistics({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasTipo': tipo.isNotEmpty,
      'hasValor': valor > 0,
      'hasDescricao': descricao.isNotEmpty,
      'hasObservacao': observacao != null && observacao.isNotEmpty,
      'tipoLength': tipo.length,
      'descricaoLength': descricao.length,
      'observacaoLength': observacao?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        tipo: tipo,
        valor: valor,
        descricao: descricao,
        observacao: observacao,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    int completed = 0;
    const int total = 4; // Required fields only

    if (animalId.isNotEmpty) completed++;
    if (tipo.isNotEmpty) completed++;
    if (valor > 0) completed++;
    if (descricao.isNotEmpty) completed++;

    return (completed / total) * 100;
  }

  static String getFormCompletionText(double percentage) {
    if (percentage == 100) {
      return 'Formulário completo';
    } else if (percentage >= 75) {
      return 'Quase pronto';
    } else if (percentage >= 50) {
      return 'Metade completo';
    } else if (percentage > 0) {
      return 'Iniciado';
    } else {
      return 'Não iniciado';
    }
  }

  static Color getFormCompletionColor(double percentage) {
    if (percentage == 100) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 75) {
      return const Color(0xFF66BB6A); // Light green
    } else if (percentage >= 50) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF757575); // Gray
    }
  }

  static bool isFormValid({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return animalId.isNotEmpty &&
        DespesasUtils.isTipoValid(tipo) &&
        DespesasUtils.isValidValor(valor) &&
        DespesasUtils.isValidDescricao(descricao) &&
        DespesasUtils.isValidObservacao(observacao);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    if (!DespesasUtils.isTipoValid(tipo)) {
      errors['tipo'] = 'Tipo de despesa inválido';
    }

    if (!DespesasUtils.isValidValor(valor)) {
      errors['valor'] = 'Valor deve ser maior que R\$ 0,00 e menor que R\$ 99.999,99';
    }

    if (!DespesasUtils.isValidDescricao(descricao)) {
      errors['descricao'] = 'Descrição é obrigatória e deve ter no máximo 255 caracteres';
    }

    if (!DespesasUtils.isValidObservacao(observacao)) {
      errors['observacao'] = 'Observação deve ter no máximo 500 caracteres';
    }

    return errors;
  }

  static Widget buildProgressIndicator(double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso do formulário',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: getFormCompletionColor(percentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            getFormCompletionColor(percentage),
          ),
        ),
      ],
    );
  }

  static Widget buildStepIndicator({
    required int currentStep,
    required int totalSteps,
    required List<String> stepTitles,
  }) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent 
                      ? Colors.blue 
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stepTitles[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted || isCurrent 
                      ? Colors.blue 
                      : Colors.grey[600],
                  fontWeight: isCurrent 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  static List<String> getFormSteps() {
    return [
      'Animal',
      'Tipo',
      'Valor',
      'Descrição',
      'Confirmação',
    ];
  }

  static int getCurrentStep({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
  }) {
    if (animalId.isEmpty) return 0;
    if (tipo.isEmpty) return 1;
    if (valor <= 0) return 2;
    if (descricao.isEmpty) return 3;
    return 4;
  }
}
