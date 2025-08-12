// Barrel file for all odometer constants
// Provides centralized access to all constant definitions

// Flutter imports:
import 'package:flutter/material.dart';

export 'business_constants.dart';
export 'ui_constants.dart';
export 'validation_constants.dart';

/// Backward compatibility class that aggregates all constants
/// This class maintains the original interface while providing access to the new organized structure
@Deprecated(
    'Use specific constant classes instead: OdometroUIConstants, OdometroValidationConstants, OdometroBusinessConstants')
class OdometroConstants {
  // Validation constraints - delegated to ValidationConstants
  static const int maxDescriptionLength = 255;
  static const int descriptionMaxLines = 3;
  static const int decimalPlaces = 2;
  static const double minOdometer = 0.0;

  // Dialog configuration - delegated to UIConstants
  static const double dialogMaxHeight = 484.0;
  static const double dialogPreferredHeight = 470.0;

  // Validation messages - delegated to ValidationConstants
  static const Map<String, String> validationMessages = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorNegativo': 'O valor não pode ser negativo',
    'dataFutura': 'A data de registro não pode ser futura.',
    'erroGenerico': 'Ocorreu um erro ao salvar o odômetro',
  };

  // Field labels and hints - delegated to BusinessConstants
  static const Map<String, String> fieldLabels = {
    'odometro': 'Odometro',
    'dataHora': 'Data e Hora',
    'descricao': 'Descrição',
  };

  static const Map<String, String> fieldHints = {
    'odometro': '0,00',
    'descricao': 'Descreva o motivo do registro (Opcional)',
  };

  // Section titles and icons - delegated to UIConstants
  static const Map<String, String> sectionTitles = {
    'informacoesBasicas': 'Informações Básicas',
    'adicionais': 'Adicionais',
  };

  static const Map<String, IconData> sectionIcons = {
    'informacoesBasicas': Icons.event_note,
    'adicionais': Icons.notes,
    'odometro': Icons.speed,
    'dataHora': Icons.calendar_today,
    'descricao': Icons.description,
    'clear': Icons.clear,
  };

  // Date and time configuration - delegated to BusinessConstants
  static const Map<String, String> dateTimeLabels = {
    'cancelar': 'Cancelar',
    'confirmar': 'Confirmar',
    'selecioneData': 'Selecione a data',
    'selecioneHora': 'Selecione a hora',
    'hora': 'Hora',
    'minuto': 'Minuto',
  };

  // Dialog titles and buttons - delegated to ValidationConstants
  static const Map<String, String> dialogMessages = {
    'titulo': 'Odômetro',
    'dataInvalida': 'Data inválida',
    'erro': 'Erro',
    'ok': 'OK',
  };

  // Units and suffixes - delegated to BusinessConstants
  static const Map<String, String> units = {
    'odometro': 'km',
  };

  // Input formatters configuration - delegated to ValidationConstants
  static const String numberPattern = r'[0-9,.]';
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';

  // Default values - delegated to BusinessConstants
  static const double defaultOdometro = 0.0;
  static const String defaultDescricao = '';
  static const String defaultTipoRegistro = 'Outros';

  static const Map<String, dynamic> defaultValues = {
    'odometro': defaultOdometro,
    'descricao': defaultDescricao,
    'tipoRegistro': defaultTipoRegistro,
  };

  // Styling constants - delegated to UIConstants
  static const Map<String, double> dimensions = {
    'cardElevation': 0.0,
    'cardBorderRadius': 8.0,
    'cardMarginBottom': 12.0,
    'cardPadding': 12.0,
    'sectionPadding': 8.0,
    'fieldSpacing': 4.0,
    'iconSize': 16.0,
    'clearIconSize': 18.0,
    'calendarIconSize': 20.0,
    'dividerWidth': 1.0,
    'dividerSpacing': 40.0,
    'timePickerSpacing': 20.0,
  };

  // Regular expressions
  static RegExp get numberRegex => RegExp(numberPattern);

  // Validation helpers
  static bool isValidOdometerValue(String value) {
    final cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    final number = double.tryParse(cleanValue);
    return number != null && number >= minOdometer;
  }

  // Date range constraints
  static DateTime get minDate => DateTime(2000);
  static DateTime get maxDate => DateTime.now();

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isValidDescriptionLength(String description) {
    return description.length <= maxDescriptionLength;
  }
}
