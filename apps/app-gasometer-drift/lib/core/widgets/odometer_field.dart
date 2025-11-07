import 'package:flutter/material.dart';

import '../../../features/fuel/domain/services/fuel_formatter_service.dart';
import 'validated_form_field.dart';

/// Campo unificado para entrada de quilometragem/odômetro
///
/// Centraliza toda a lógica de validação, formatação e apresentação
/// dos campos de odômetro usados em diferentes formulários do app.
///
/// Características:
/// - Validação específica para odômetro com limites apropriados
/// - Formatação automática de números
/// - Validação contextual com leitura anterior
/// - Interface consistente em todos os formulários
/// - Ícone e sufixo padrão (velocímetro + "km")
///
/// Exemplo de uso:
/// ```dart
/// OdometerField(
///   controller: _odometerController,
///   currentOdometer: vehicle.currentOdometer,
///   lastReading: provider.lastOdometerReading,
///   onChanged: (value) => provider.updateOdometer(value),
/// )
/// ```
class OdometerField extends StatelessWidget {
  const OdometerField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.required = true,
    this.currentOdometer,
    this.lastReading,
    this.onChanged,
    this.additionalValidator,
    this.showLastReadingHint = true,
    this.minValue = 0.0,
    this.maxValue = 9999999.0,
  });

  /// Controller do campo de texto
  final TextEditingController controller;

  /// FocusNode do campo (opcional)
  final FocusNode? focusNode;

  /// Label do campo (padrão: "Quilometragem Atual")
  final String? label;

  /// Texto de hint/placeholder
  final String? hint;

  /// Se o campo é obrigatório
  final bool required;

  /// Quilometragem atual do veículo (para validação)
  final double? currentOdometer;

  /// Última leitura registrada (para validação de sequência)
  final double? lastReading;

  /// Callback quando o valor muda
  final void Function(String?)? onChanged;

  /// Callback para validação customizada adicional
  final String? Function(String?)? additionalValidator;

  /// Se deve mostrar texto de ajuda com a última leitura
  final bool showLastReadingHint;

  /// Valor mínimo aceito (padrão: 0)
  final double minValue;

  /// Valor máximo aceito (padrão: 9.999.999)
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValidatedFormField(
      controller: controller,
      focusNode: focusNode,
      label: label ?? 'Quilometragem Atual${required ? ' *' : ''}',
      hint: hint ?? _buildDefaultHint(),
      prefixIcon: Icons.speed,
      required: required,
      validationType: ValidationType.odometer,
      currentOdometer: currentOdometer,
      initialOdometer: lastReading,
      minValue: minValue,
      maxValue: maxValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().odometerFormatter],
      suffix: Text(
        'km',
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      onValidationChanged: (result) {
        if (onChanged != null) {
          onChanged!(controller.text);
        }
      },
      customValidator: (String? value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Quilometragem é obrigatória';
        }

        if (value != null && value.isNotEmpty) {
          final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
          final doubleValue = double.tryParse(cleanValue.replaceAll(',', '.'));

          if (doubleValue == null) {
            return 'Valor inválido';
          }
          if (doubleValue < minValue || doubleValue > maxValue) {
            return 'Valor deve estar entre ${_formatNumber(minValue)} e ${_formatNumber(maxValue)}';
          }
          if (lastReading != null && doubleValue < lastReading!) {
            return 'Quilometragem não pode ser menor que a última leitura (${_formatNumber(lastReading!)} km)';
          }
          if (lastReading != null && (doubleValue - lastReading!) > 50000) {
            return 'Aumento muito grande desde a última leitura. Verifique o valor.';
          }
        }
        if (additionalValidator != null) {
          return additionalValidator!(value);
        }

        return null;
      },
      helperText: showLastReadingHint ? _buildHelperText() : null,
    );
  }

  String _buildDefaultHint() {
    if (lastReading != null) {
      return 'Última: ${_formatNumber(lastReading!)} km';
    }
    return 'Ex: 45.234';
  }

  String? _buildHelperText() {
    if (lastReading != null) {
      return 'Última leitura registrada: ${_formatNumber(lastReading!)} km';
    }
    return null;
  }

  String _formatNumber(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// Variação do OdometerField para casos específicos onde é opcional
class OptionalOdometerField extends StatelessWidget {
  const OptionalOdometerField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.currentOdometer,
    this.lastReading,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final double? currentOdometer;
  final double? lastReading;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return OdometerField(
      controller: controller,
      label: label ?? 'Quilometragem (Opcional)',
      hint: hint,
      required: false,
      currentOdometer: currentOdometer,
      lastReading: lastReading,
      onChanged: onChanged,
      showLastReadingHint: false,
    );
  }
}

/// Variação simplificada do OdometerField para casos básicos
class SimpleOdometerField extends StatelessWidget {
  const SimpleOdometerField({
    super.key,
    required this.controller,
    this.onChanged,
  });
  final TextEditingController controller;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return OdometerField(
      controller: controller,
      label: 'Quilometragem',
      hint: 'Digite a quilometragem atual',
      onChanged: onChanged,
      showLastReadingHint: false,
    );
  }
}
