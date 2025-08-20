// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'lembrete_core.dart';

class LembreteFormHelpers {
  static List<DropdownMenuItem<String>> buildTipoDropdownItems() {
    return LembreteCore.getSuggestedTypes()
        .map((tipo) => DropdownMenuItem<String>(
              value: tipo,
              child: Text(tipo),
            ))
        .toList();
  }

  static InputDecoration buildTituloDecoration() {
    return const InputDecoration(
      labelText: 'Título',
      hintText: 'Digite o título do lembrete',
      prefixIcon: Icon(Icons.title),
      border: OutlineInputBorder(),
      counterText: '',
    );
  }

  static InputDecoration buildDescricaoDecoration() {
    return const InputDecoration(
      labelText: 'Descrição (opcional)',
      hintText: 'Digite uma descrição detalhada',
      prefixIcon: Icon(Icons.description),
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    );
  }

  static InputDecoration buildTipoDecoration() {
    return const InputDecoration(
      labelText: 'Tipo',
      hintText: 'Selecione o tipo do lembrete',
      prefixIcon: Icon(Icons.category),
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration buildDataHoraDecoration() {
    return const InputDecoration(
      labelText: 'Data e Hora',
      hintText: 'Selecione data e hora',
      prefixIcon: Icon(Icons.calendar_today),
      border: OutlineInputBorder(),
    );
  }

  static Widget buildCharacterCounter(String text, int maxLength) {
    final currentLength = text.length;
    final color = currentLength > maxLength ? Colors.red : Colors.grey;
    
    return Text(
      '$currentLength/$maxLength',
      style: TextStyle(
        color: color,
        fontSize: 12,
      ),
    );
  }

  static Widget buildFormSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  static List<String> getRepetirOptions() {
    return [
      'Não repetir',
      'Diariamente',
      'Semanalmente',
      'Mensalmente',
      'Anualmente',
    ];
  }

  static List<DropdownMenuItem<String>> buildRepetirDropdownItems() {
    return getRepetirOptions()
        .map((option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ))
        .toList();
  }

  static String getHintTextForTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'medicamento':
        return 'Ex: Dar medicamento para dor';
      case 'consulta':
        return 'Ex: Consulta com veterinário';
      case 'vacina':
        return 'Ex: Aplicar vacina antirrábica';
      case 'banho e tosa':
        return 'Ex: Levar para banho e tosa';
      case 'ração':
        return 'Ex: Comprar ração premium';
      case 'exercício':
        return 'Ex: Caminhada no parque';
      default:
        return 'Digite o título do lembrete';
    }
  }

  static bool shouldShowTimeRemaining(DateTime? dataHora) {
    if (dataHora == null) return false;
    final now = DateTime.now();
    final diff = dataHora.difference(now);
    return diff.inDays <= 30;
  }
}
