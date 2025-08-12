/// Business logic constants for the odometer registration feature
/// Contains default values, units, and business rules
class OdometroBusinessConstants {
  // Private constructor to prevent instantiation
  OdometroBusinessConstants._();

  /// Default values for form initialization
  static const DefaultValues defaults = DefaultValues._();

  /// Text labels and hints for form fields
  static const FieldLabels labels = FieldLabels._();

  /// Units and measurement constants
  static const Units units = Units._();

  /// Date and time picker configuration
  static const DateTimeConfig dateTime = DateTimeConfig._();
}

/// Default values for form fields (typed constants to avoid unnecessary toString() calls)
class DefaultValues {
  const DefaultValues._();

  /// Default odometer reading value
  static const double odometer = 0.0;

  /// Default description text
  static const String description = '';

  /// Default registration type
  static const String registrationType = 'Outros';

  /// Legacy map for backward compatibility with existing code
  static const Map<String, dynamic> legacy = {
    'odometro': odometer,
    'descricao': description,
    'tipoRegistro': registrationType,
  };
}

/// Field labels and hints in Portuguese (user interface text)
class FieldLabels {
  const FieldLabels._();

  /// Form field labels displayed to users
  static const Map<String, String> labels = {
    'odometro': 'Odometro',
    'dataHora': 'Data e Hora',
    'descricao': 'Descrição',
  };

  /// Placeholder hints for input fields
  static const Map<String, String> hints = {
    'odometro': '0,00',
    'descricao': 'Descreva o motivo do registro (Opcional)',
  };

  /// Section titles for form organization
  static const Map<String, String> sections = {
    'informacoesBasicas': 'Informações Básicas',
    'adicionais': 'Adicionais',
  };
}

/// Units and measurement constants
class Units {
  const Units._();

  /// Measurement units for different values
  static const Map<String, String> measurement = {
    'odometro': 'km',
  };
}

/// Date and time picker configuration
class DateTimeConfig {
  const DateTimeConfig._();

  /// Text labels for date/time pickers
  static const Map<String, String> labels = {
    'cancelar': 'Cancelar',
    'confirmar': 'Confirmar',
    'selecioneData': 'Selecione a data',
    'selecioneHora': 'Selecione a hora',
    'hora': 'Hora',
    'minuto': 'Minuto',
  };
}
