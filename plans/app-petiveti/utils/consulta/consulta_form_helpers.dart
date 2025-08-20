// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'consulta_core.dart';

class ConsultaFormHelpers {
  static List<DropdownMenuItem<String>> buildMotivoDropdownItems() {
    return ConsultaCore.getAvailableMotivos()
        .map((motivo) => DropdownMenuItem<String>(
              value: motivo,
              child: Text(motivo),
            ))
        .toList();
  }

  static List<DropdownMenuItem<String>> buildVeterinarioDropdownItems() {
    return ConsultaCore.getCommonVeterinarios()
        .map((vet) => DropdownMenuItem<String>(
              value: vet,
              child: Text(vet),
            ))
        .toList();
  }

  static InputDecoration buildVeterinarioDecoration() {
    return const InputDecoration(
      labelText: 'Veterinário',
      hintText: 'Nome do veterinário',
      prefixIcon: Icon(Icons.person),
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration buildMotivoDecoration() {
    return const InputDecoration(
      labelText: 'Motivo',
      hintText: 'Selecione o motivo da consulta',
      prefixIcon: Icon(Icons.medical_services),
      border: OutlineInputBorder(),
    );
  }

  static InputDecoration buildDiagnosticoDecoration() {
    return const InputDecoration(
      labelText: 'Diagnóstico',
      hintText: 'Diagnóstico da consulta',
      prefixIcon: Icon(Icons.assignment),
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    );
  }

  static InputDecoration buildObservacoesDecoration() {
    return const InputDecoration(
      labelText: 'Observações (opcional)',
      hintText: 'Observações adicionais',
      prefixIcon: Icon(Icons.note),
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    );
  }

  static InputDecoration buildDataConsultaDecoration() {
    return const InputDecoration(
      labelText: 'Data da Consulta',
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

  static String? getHintForMotivo(String? motivo) {
    return ConsultaCore.generateSuggestion(motivo ?? '', null);
  }

  static bool isFormComplete({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
  }) {
    return animalId != null && animalId.isNotEmpty &&
           veterinario != null && veterinario.isNotEmpty &&
           motivo != null && motivo.isNotEmpty &&
           diagnostico != null && diagnostico.isNotEmpty &&
           dataConsulta != null;
  }

  static double calculateFormProgress({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
  }) {
    int filledFields = 0;
    const totalFields = 5;

    if (animalId != null && animalId.isNotEmpty) filledFields++;
    if (veterinario != null && veterinario.isNotEmpty) filledFields++;
    if (motivo != null && motivo.isNotEmpty) filledFields++;
    if (diagnostico != null && diagnostico.isNotEmpty) filledFields++;
    if (dataConsulta != null) filledFields++;

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

  static List<String> getQuickMotivoSuggestions() {
    return [
      'Consulta de rotina',
      'Check-up',
      'Vacina',
      'Exame',
    ];
  }

  static Widget buildQuickMotivoButtons({
    required Function(String) onMotivoSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: getQuickMotivoSuggestions()
          .map((motivo) => OutlinedButton(
                onPressed: () => onMotivoSelected(motivo),
                child: Text(motivo),
              ))
          .toList(),
    );
  }

  static List<String> getFormSteps() {
    return [
      'Animal',
      'Veterinário',
      'Motivo',
      'Diagnóstico',
      'Data',
    ];
  }

  static int getCurrentStep({
    required String? animalId,
    required String? veterinario,
    required String? motivo,
    required String? diagnostico,
    required DateTime? dataConsulta,
  }) {
    if (animalId == null || animalId.isEmpty) return 0;
    if (veterinario == null || veterinario.isEmpty) return 1;
    if (motivo == null || motivo.isEmpty) return 2;
    if (diagnostico == null || diagnostico.isEmpty) return 3;
    if (dataConsulta == null) return 4;
    return 5;
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
}
