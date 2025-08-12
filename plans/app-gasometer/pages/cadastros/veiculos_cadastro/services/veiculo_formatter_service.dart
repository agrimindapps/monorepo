// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../database/enums.dart';
import '../models/veiculos_constants.dart';

/// Service responsável pela formatação de dados de veículos
///
/// Centraliza todas as operações de formatação e apresentação
/// de dados relacionados aos veículos.
class VeiculoFormatterService {
  /// Gera lista de opções de anos para dropdown
  static List<int> getYearOptions() {
    final currentYear = DateTime.now().year;
    return List<int>.generate(
      (currentYear - VeiculosConstants.anoMinimo) + 1,
      (i) => currentYear - i,
    );
  }

  /// Obtém ícone para tipo de combustível
  static IconData getFuelIcon(TipoCombustivel tipo) {
    final iconKey = tipo.toString().split('.').last;
    return VeiculosConstants.iconesCombustivel[iconKey] ??
        Icons.local_gas_station;
  }

  /// Formata valor de odômetro para exibição
  static String formatOdometer(double value) {
    return '${value.toStringAsFixed(0)} ${VeiculosConstants.sufixos['odometro']}';
  }

  /// Formata texto do tipo de combustível
  static String formatCombustivel(TipoCombustivel tipo) {
    return tipo.descricao;
  }

  /// Formata texto do tipo de combustível por índice
  static String formatCombustivelByIndex(int combustivelIndex) {
    try {
      return TipoCombustivel.values[combustivelIndex].descricao;
    } catch (e) {
      return VeiculosConstants.mensagensInfo['naoInformado']!;
    }
  }

  /// Formata valor de campo opcional
  static String formatFieldValue(String? value) {
    return (value == null || value.isEmpty)
        ? VeiculosConstants.mensagensInfo['naoInformado']!
        : value;
  }

  /// Formata título do veículo (marca + modelo)
  static String formatVehicleTitle(String marca, String modelo) {
    return '$marca $modelo';
  }

  /// Formata subtítulo do veículo (ano + cor)
  static String formatVehicleSubtitle(int ano, String cor) {
    return '$ano • $cor';
  }

  /// Formata placa para maiúsculas
  static String formatPlacaInput(String value) {
    return value.toUpperCase();
  }

  /// Formata chassi para maiúsculas
  static String formatChassisInput(String value) {
    return value.toUpperCase();
  }

  /// Formata renavam (apenas dígitos)
  static String formatRenavamInput(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Capitaliza primeira letra de cada palavra
  static String capitalizeWords(String value) {
    if (value.isEmpty) return value;

    return value
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Formata marca/modelo/cor com capitalização
  static String formatTextInput(String value) {
    return capitalizeWords(value.trim());
  }

  // ===================================
  // INPUT FORMATTERS - Migrados do VeiculoValidators
  // ===================================

  /// Input formatters para campo de placa
  static List<TextInputFormatter> get placaInputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          return TextEditingValue(
            text: newValue.text.toUpperCase(),
            selection: newValue.selection,
          );
        }),
      ];

  /// Input formatters para campo de chassi
  static List<TextInputFormatter> get chassiInputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          return TextEditingValue(
            text: newValue.text.toUpperCase(),
            selection: newValue.selection,
          );
        }),
      ];

  /// Input formatters para campo de renavam
  static List<TextInputFormatter> get renavamInputFormatters => [
        FilteringTextInputFormatter.digitsOnly,
      ];
}
