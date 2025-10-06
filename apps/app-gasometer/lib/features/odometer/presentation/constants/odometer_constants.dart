import 'package:flutter/material.dart';

/// Centralized constants for the odometer feature
///
/// This class organizes all constants related to odometer functionality:
/// - Validation constraints and business rules
/// - UI dimensions and styling
/// - Text labels and messages
/// - Date and time constraints
class OdometerConstants {

  /// Validation constraints
  static const int maxDescriptionLength = 255;
  static const int descriptionMaxLines = 3;
  static const int decimalPlaces = 2;
  static const double minOdometer = 0.0;
  static const double maxOdometer = 999999.0;

  /// Dialog configuration
  static const double dialogMaxHeight = 484.0;
  static const double dialogPreferredHeight = 470.0;

  /// Regular expressions for input formatting
  static const String numberPattern = r'[0-9,.]';
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static RegExp get numberRegex => RegExp(numberPattern);

  /// Date range constraints
  static DateTime get minDate => DateTime(2000);
  static DateTime get maxDate => DateTime.now();

  /// Validation helpers
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isValidDescriptionLength(String description) {
    return description.length <= maxDescriptionLength;
  }

  static const Map<String, String> validationMessages = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorNegativo': 'O valor não pode ser negativo',
    'valorMaximo': 'Valor máximo excedido',
    'dataFutura': 'A data de registro não pode ser futura.',
    'erroGenerico': 'Ocorreu um erro ao salvar o odômetro',
    'veiculoObrigatorio': 'Veículo é obrigatório',
    'tipoObrigatorio': 'Tipo de registro é obrigatório',
    'descricaoLonga': 'Descrição muito longa',
  };

  static const Map<String, String> fieldLabels = {
    'odometro': 'Odômetro',
    'dataHora': 'Data e Hora',
    'descricao': 'Descrição',
    'tipoRegistro': 'Tipo de Registro',
    'veiculo': 'Veículo',
  };

  static const Map<String, String> fieldHints = {
    'odometro': '0,00',
    'descricao': 'Descreva o motivo do registro (Opcional)',
    'tipoRegistro': 'Selecione o tipo de registro',
  };

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
    'tipoRegistro': Icons.category,
    'clear': Icons.clear,
    'expandMore': Icons.expand_more,
  };

  static const Map<String, String> dateTimeLabels = {
    'cancelar': 'Cancelar',
    'confirmar': 'Confirmar',
    'selecioneData': 'Selecione a data',
    'selecioneHora': 'Selecione a hora',
    'hora': 'Hora',
    'minuto': 'Minuto',
  };

  static const Map<String, String> dialogMessages = {
    'titulo': 'Odômetro',
    'tituloNovo': 'Cadastrar Odômetro',
    'tituloEdicao': 'Editar Odômetro',
    'dataInvalida': 'Data inválida',
    'erro': 'Erro',
    'sucesso': 'Sucesso',
    'ok': 'OK',
    'cancelar': 'Cancelar',
    'salvar': 'Salvar',
  };

  static const Map<String, String> units = {
    'odometro': 'km',
    'quilometros': 'km',
  };

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
    'dropdownMaxHeight': 200.0,
  };

  static const Map<String, String> successMessages = {
    'cadastroSucesso': 'Registro de odômetro cadastrado com sucesso!',
    'edicaoSucesso': 'Registro de odômetro atualizado com sucesso!',
    'exclusaoSucesso': 'Registro de odômetro excluído com sucesso!',
  };

  static const Map<String, String> errorMessages = {
    'carregarVeiculo': 'Erro ao carregar dados do veículo',
    'salvarOdometro': 'Erro ao salvar registro de odômetro',
    'atualizarOdometro': 'Erro ao atualizar registro de odômetro',
    'excluirOdometro': 'Erro ao excluir registro de odômetro',
    'carregarOdometros': 'Erro ao carregar registros de odômetro',
    'validacaoOdometro': 'Erro na validação do valor do odômetro',
    'timeoutCarregamento': 'Tempo limite excedido ao carregar dados',
    'networkError': 'Erro de conexão. Verifique sua internet.',
  };

  static const Map<String, dynamic> formConfig = {
    'autovalidateMode': true,
    'showClearButton': true,
    'showCounter': true,
    'enableContextValidation': true,
    'autoSave': false,
  };
}
