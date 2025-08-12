// Flutter imports:
import 'package:flutter/material.dart';

class OdometroConstants {
  // Validation constraints
  static const int maxDescriptionLength =
      255; // Máximo de caracteres permitidos para descrição (baseado em limites de banco de dados)
  static const int descriptionMaxLines =
      3; // Número máximo de linhas visíveis no campo de descrição para melhor UX
  static const int decimalPlaces =
      2; // Precisão decimal para valores de odômetro (centésimos para alta precisão)
  static const double minOdometer =
      0.0; // Valor mínimo válido para odômetro (não pode ser negativo)

  // Dialog configuration
  static const double dialogMaxHeight =
      484.0; // Altura máxima do dialog baseada no conteúdo mínimo + padding (calculada para acomodar todos os campos sem scroll)
  static const double dialogPreferredHeight =
      470.0; // Altura preferida do dialog para otimizar exibição em dispositivos médios

  // Validation messages
  static const Map<String, String> validationMessages = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorNegativo': 'O valor não pode ser negativo',
    'dataFutura': 'A data de registro não pode ser futura.',
    'erroGenerico': 'Ocorreu um erro ao salvar o odômetro',
  };

  // Field labels and hints
  static const Map<String, String> fieldLabels = {
    'odometro': 'Odometro',
    'dataHora': 'Data e Hora',
    'descricao': 'Descrição',
  };

  static const Map<String, String> fieldHints = {
    'odometro': '0,00',
    'descricao': 'Descreva o motivo do registro (Opcional)',
  };

  // Section titles and icons
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

  // Date and time configuration
  static const Map<String, String> dateTimeLabels = {
    'cancelar': 'Cancelar',
    'confirmar': 'Confirmar',
    'selecioneData': 'Selecione a data',
    'selecioneHora': 'Selecione a hora',
    'hora': 'Hora',
    'minuto': 'Minuto',
  };

  // Dialog titles and buttons
  static const Map<String, String> dialogMessages = {
    'titulo': 'Odômetro',
    'dataInvalida': 'Data inválida',
    'erro': 'Erro',
    'ok': 'OK',
  };

  // Units and suffixes
  static const Map<String, String> units = {
    'odometro': 'km',
  };

  // Input formatters configuration
  static const String numberPattern = r'[0-9,.]';
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';

  // Default values - typed constants to avoid unnecessary toString() calls
  static const double defaultOdometro = 0.0;
  static const String defaultDescricao = '';
  static const String defaultTipoRegistro = 'Outros';

  // Legacy map for backward compatibility
  static const Map<String, dynamic> defaultValues = {
    'odometro': defaultOdometro,
    'descricao': defaultDescricao,
    'tipoRegistro': defaultTipoRegistro,
  };

  // Styling constants - dimensões baseadas em Material Design guidelines
  static const Map<String, double> dimensions = {
    'cardElevation':
        0.0, // Elevação zero para design flat moderno, seguindo tendências atuais de UI
    'cardBorderRadius':
        8.0, // Raio de borda padrão do Material Design 3 para elementos de conteúdo
    'cardMarginBottom':
        12.0, // Espaçamento vertical entre cards para respiração visual adequada
    'cardPadding':
        12.0, // Padding interno do card para conforto de leitura (múltiplo de 4 do Material Design)
    'sectionPadding':
        8.0, // Padding menor para seções internas, criando hierarquia visual
    'fieldSpacing':
        4.0, // Espaçamento mínimo entre campos relacionados para agrupamento visual
    'iconSize':
        16.0, // Tamanho padrão de ícones pequenos para elementos secundários
    'clearIconSize':
        18.0, // Ícone de limpeza ligeiramente maior para melhor área de toque (acessibilidade)
    'calendarIconSize':
        20.0, // Ícone de calendário maior para destaque e fácil identificação
    'dividerWidth':
        1.0, // Largura padrão de divisores para separação sutil de conteúdo
    'dividerSpacing':
        40.0, // Espaçamento horizontal do divisor para alinhamento com texto
    'timePickerSpacing':
        20.0, // Espaçamento específico para seletores de tempo, baseado em área de toque confortável
  };

  // Regular expressions
  static RegExp get numberRegex => RegExp(numberPattern);

  // Validation helpers - moved formatting to OdometroFormatter
  static bool isValidOdometerValue(String value) {
    // Use the formatter service for consistency
    final cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    final number = double.tryParse(cleanValue);
    return number != null && number >= minOdometer;
  }

  // Date range constraints
  static DateTime get minDate => DateTime(
      2000); // Data mínima permitida - início do ano 2000 (marco tecnológico comum para sistemas automotivos)
  static DateTime get maxDate => DateTime
      .now(); // Data máxima é sempre o momento atual (previne registros futuros)

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isValidDescriptionLength(String description) {
    return description.length <= maxDescriptionLength;
  }
}
