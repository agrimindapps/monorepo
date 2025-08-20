// Flutter imports:
import 'package:flutter/material.dart';

/// Configuration constants for vaccination form fields
class FieldConfig {
  
  // Field length limits
  static const int maxVaccineNameLength = 50;
  static const int maxObservationsLength = 500;
  
  // Form spacing
  static const double fieldSpacing = 16.0;
  static const double sectionSpacing = 24.0;
  static const double buttonSpacing = 32.0;
  
  // Padding
  static const EdgeInsets fieldPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 8.0);
  
  // Animation durations
  static const Duration fieldAnimationDuration = Duration(milliseconds: 300);
  static const Duration validationDelay = Duration(milliseconds: 500);
  
  // Field labels
  static const String vaccineNameLabel = 'Nome da Vacina';
  static const String applicationDateLabel = 'Data de Aplicação';
  static const String applicationTimeLabel = 'Hora de Aplicação';
  static const String nextDoseLabel = 'Próxima Dose';
  static const String observationsLabel = 'Observações';
  
  // Button labels
  static const String saveButtonLabel = 'Salvar Vacina';
  static const String cancelButtonLabel = 'Cancelar';
  static const String clearButtonLabel = 'Limpar';
  
  // Validation messages
  static const String requiredFieldMessage = 'Este campo é obrigatório';
  static const String invalidDateMessage = 'Data inválida';
  static const String futureDateMessage = 'Data não pode ser futura';
  static const String invalidCharactersMessage = 'Contém caracteres inválidos';
  static const String tooLongMessage = 'Texto muito longo';
  
  // Icons
  static const IconData vaccineIcon = Icons.local_hospital;
  static const IconData dateIcon = Icons.calendar_today;
  static const IconData timeIcon = Icons.access_time;
  static const IconData observationsIcon = Icons.note;
  static const IconData saveIcon = Icons.save;
  static const IconData cancelIcon = Icons.cancel;
  static const IconData clearIcon = Icons.clear;
}
