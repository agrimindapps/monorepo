// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'despesas_core.dart';

class DespesasFormHelpers {
  static List<DropdownMenuItem<String>> buildTipoDropdownItems() {
    return DespesasCore.getAvailableTipos()
        .map((tipo) => DropdownMenuItem<String>(
              value: tipo,
              child: Text(tipo),
            ))
        .toList();
  }

  static List<DropdownMenuItem<String>> buildCommonTipoDropdownItems() {
    return DespesasCore.getCommonTipos()
        .map((tipo) => DropdownMenuItem<String>(
              value: tipo,
              child: Text(tipo),
            ))
        .toList();
  }

  static InputDecoration buildTipoDecoration() {
    return const InputDecoration(
      labelText: 'Tipo',
      hintText: 'Selecione o tipo da despesa',
      prefixIcon: Icon(Icons.category),
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration buildValorDecoration() {
    return const InputDecoration(
      labelText: 'Valor',
      hintText: 'R\$ 0,00',
      prefixIcon: Icon(Icons.attach_money),
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration buildDescricaoDecoration() {
    return const InputDecoration(
      labelText: 'Descrição',
      hintText: 'Digite uma descrição da despesa',
      prefixIcon: Icon(Icons.description),
      border: OutlineInputBorder(),
      counterText: '',
    );
  }

  static InputDecoration buildObservacaoDecoration() {
    return const InputDecoration(
      labelText: 'Observação (opcional)',
      hintText: 'Informações adicionais',
      prefixIcon: Icon(Icons.note),
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    );
  }

  static InputDecoration buildDataDecoration() {
    return const InputDecoration(
      labelText: 'Data',
      hintText: 'DD/MM/AAAA',
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

  static String formatCurrency(String text) {
    // Remove all non-numeric characters except dots and commas
    String numericOnly = text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Replace comma with dot for parsing
    numericOnly = numericOnly.replaceAll(',', '.');
    
    // Try to parse as double
    final value = double.tryParse(numericOnly);
    if (value == null) return text;
    
    // Format back to Brazilian currency format
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String? getHintForTipo(String? tipo) {
    return DespesasCore.generateSuggestion(tipo ?? '', null);
  }

  static bool isFormComplete({
    required String? tipo,
    required String? valor,
    required String? descricao,
    required DateTime? data,
    required String? animalId,
  }) {
    return tipo != null && tipo.isNotEmpty &&
           valor != null && valor.isNotEmpty &&
           descricao != null && descricao.isNotEmpty &&
           data != null &&
           animalId != null && animalId.isNotEmpty;
  }

  static double calculateFormProgress({
    required String? tipo,
    required String? valor,
    required String? descricao,
    required DateTime? data,
    required String? animalId,
  }) {
    int filledFields = 0;
    const totalFields = 5;

    if (tipo != null && tipo.isNotEmpty) filledFields++;
    if (valor != null && valor.isNotEmpty) filledFields++;
    if (descricao != null && descricao.isNotEmpty) filledFields++;
    if (data != null) filledFields++;
    if (animalId != null && animalId.isNotEmpty) filledFields++;

    return filledFields / totalFields;
  }

  static Widget buildProgressIndicator(double progress) {
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
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  static List<String> getQuickAmountSuggestions() {
    return ['10,00', '25,00', '50,00', '100,00', '200,00'];
  }

  static Widget buildQuickAmountButtons({
    required Function(String) onAmountSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: getQuickAmountSuggestions()
          .map((amount) => OutlinedButton(
                onPressed: () => onAmountSelected(amount),
                child: Text('R\$ $amount'),
              ))
          .toList(),
    );
  }
}
