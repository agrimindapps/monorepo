import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/design_tokens.dart';
import 'validated_form_field.dart';

/// Tipos de campo monetário pré-configurados
enum MoneyFieldType {
  /// Valor total/gasto (ex: despesas, manutenção)
  amount,
  /// Preço por unidade (ex: preço por litro)
  price,
  /// Custo de serviço (ex: mão de obra)
  cost,
  /// Valor genérico monetário
  generic,
}

/// Campo unificado para entrada de valores monetários
///
/// Centraliza toda a lógica de formatação, validação e apresentação
/// de campos monetários usados em diferentes formulários do app.
///
/// Características:
/// - Tipos pré-configurados com labels e hints apropriados
/// - Formatação automática de moeda brasileira (R$)
/// - Validação específica para valores monetários
/// - Interface consistente em todos os formulários
/// - Ícone e prefixo padrão (R$ + attach_money)
///
/// Exemplo de uso:
/// ```dart
/// MoneyFormField(
///   controller: _amountController,
///   type: MoneyFieldType.amount,
///   onChanged: (value) => provider.updateAmount(value),
/// )
/// ```
class MoneyFormField extends StatelessWidget {
  /// Controller do campo de texto
  final TextEditingController controller;

  /// Tipo do campo monetário (define configurações padrão)
  final MoneyFieldType type;

  /// Label customizado (sobrescreve o padrão do tipo)
  final String? customLabel;

  /// Hint customizado (sobrescreve o padrão do tipo)
  final String? customHint;

  /// Se o campo é obrigatório
  final bool required;

  /// Callback quando o valor muda
  final void Function(String?)? onChanged;

  /// Callback para validação customizada adicional
  final String? Function(String?)? additionalValidator;

  /// Valor mínimo aceito (padrão: 0.01)
  final double minValue;

  /// Valor máximo aceito (padrão: 999999.99)
  final double maxValue;

  /// Se deve mostrar helper text com dicas
  final bool showHelperText;

  /// Helper text customizado
  final String? customHelperText;

  /// Se deve aplicar formatação em tempo real
  final bool enableRealTimeFormatting;

  const MoneyFormField({
    super.key,
    required this.controller,
    required this.type,
    this.customLabel,
    this.customHint,
    this.required = true,
    this.onChanged,
    this.additionalValidator,
    this.minValue = 0.01,
    this.maxValue = 999999.99,
    this.showHelperText = false,
    this.customHelperText,
    this.enableRealTimeFormatting = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfiguration();

    return ValidatedFormField(
      controller: controller,
      label: customLabel ?? config.label,
      hint: customHint ?? config.hint,
      prefixIcon: config.icon,
      required: required,
      validationType: ValidationType.money,
      minValue: minValue,
      maxValue: maxValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: _buildFormatters(),
      helperText: _buildHelperText(config),
      customValidator: (value) => _validateMoney(value),
      onChanged: onChanged,
      debounceDuration: const Duration(milliseconds: 300),
    );
  }

  /// Configuração específica para cada tipo de campo
  _MoneyFieldConfig _getTypeConfiguration() {
    switch (type) {
      case MoneyFieldType.amount:
        return _MoneyFieldConfig(
          label: required ? 'Valor Total *' : 'Valor Total',
          hint: 'R\$ 0,00',
          icon: Icons.attach_money,
        );
      case MoneyFieldType.price:
        return _MoneyFieldConfig(
          label: required ? 'Preço por Litro *' : 'Preço por Litro',
          hint: 'R\$ 0,000',
          icon: Icons.local_gas_station,
        );
      case MoneyFieldType.cost:
        return _MoneyFieldConfig(
          label: required ? 'Custo do Serviço *' : 'Custo do Serviço',
          hint: 'R\$ 0,00',
          icon: Icons.build,
        );
      case MoneyFieldType.generic:
        return _MoneyFieldConfig(
          label: required ? 'Valor *' : 'Valor',
          hint: 'R\$ 0,00',
          icon: Icons.attach_money,
        );
    }
  }

  /// Constrói formatadores baseados no tipo
  List<TextInputFormatter> _buildFormatters() {
    if (!enableRealTimeFormatting) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ];
    }

    // Formatador mais específico baseado no tipo
    switch (type) {
      case MoneyFieldType.price:
        // Preço por litro - permite 3 casas decimais
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          _MoneyInputFormatter(decimalPlaces: 3),
        ];
      default:
        // Outros tipos - 2 casas decimais padrão
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          _MoneyInputFormatter(decimalPlaces: 2),
        ];
    }
  }

  /// Constrói helper text baseado na configuração
  String? _buildHelperText(_MoneyFieldConfig config) {
    if (customHelperText != null) return customHelperText;
    if (!showHelperText) return null;

    switch (type) {
      case MoneyFieldType.price:
        return 'Use vírgula para casas decimais (ex: 5,789)';
      case MoneyFieldType.amount:
        return 'Digite o valor total gasto';
      case MoneyFieldType.cost:
        return 'Valor do serviço ou mão de obra';
      default:
        return 'Digite o valor em reais';
    }
  }

  /// Validação específica para valores monetários
  String? _validateMoney(String? value) {
    if (required && (value == null || value.isEmpty)) {
      return 'Valor é obrigatório';
    }

    if (value != null && value.isNotEmpty) {
      // Remove formatação e converte para número
      final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
      final doubleValue = double.tryParse(cleanValue.replaceAll(',', '.'));

      if (doubleValue == null) {
        return 'Valor inválido';
      }

      // Validação de range
      if (doubleValue < minValue || doubleValue > maxValue) {
        return 'Valor deve estar entre R\$ ${_formatCurrency(minValue)} e R\$ ${_formatCurrency(maxValue)}';
      }

      // Validações específicas por tipo
      switch (type) {
        case MoneyFieldType.price:
          if (doubleValue > 50.0) {
            return 'Preço por litro muito alto. Verifique o valor.';
          }
          break;
        case MoneyFieldType.amount:
          if (doubleValue > 50000.0) {
            return 'Valor muito alto. Verifique se está correto.';
          }
          break;
        default:
          break;
      }
    }

    // Validação adicional customizada
    if (additionalValidator != null) {
      return additionalValidator!(value);
    }

    return null;
  }

  /// Formata valor para exibição
  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}

/// Configuração interna para tipos de campo
class _MoneyFieldConfig {
  final String label;
  final String hint;
  final IconData icon;

  const _MoneyFieldConfig({
    required this.label,
    required this.hint,
    required this.icon,
  });
}

/// Formatador customizado para entrada de dinheiro
class _MoneyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  _MoneyInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Implementação básica - pode ser expandida para formatação mais sofisticada
    final newText = newValue.text;

    // Limita casas decimais
    if (newText.contains(',')) {
      final parts = newText.split(',');
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        final truncated = parts[0] + ',' + parts[1].substring(0, decimalPlaces);
        return TextEditingValue(
          text: truncated,
          selection: TextSelection.collapsed(offset: truncated.length),
        );
      }
    }

    return newValue;
  }
}

/// Variações pré-configuradas para casos específicos
class AmountFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool required;
  final void Function(String?)? onChanged;

  const AmountFormField({
    super.key,
    required this.controller,
    this.label,
    this.required = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MoneyFormField(
      controller: controller,
      type: MoneyFieldType.amount,
      customLabel: label,
      required: required,
      onChanged: onChanged,
    );
  }
}

class PriceFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool required;
  final void Function(String?)? onChanged;

  const PriceFormField({
    super.key,
    required this.controller,
    this.label,
    this.required = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MoneyFormField(
      controller: controller,
      type: MoneyFieldType.price,
      customLabel: label,
      required: required,
      onChanged: onChanged,
      showHelperText: true,
    );
  }
}

class CostFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool required;
  final void Function(String?)? onChanged;

  const CostFormField({
    super.key,
    required this.controller,
    this.label,
    this.required = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MoneyFormField(
      controller: controller,
      type: MoneyFieldType.cost,
      customLabel: label,
      required: required,
      onChanged: onChanged,
    );
  }
}