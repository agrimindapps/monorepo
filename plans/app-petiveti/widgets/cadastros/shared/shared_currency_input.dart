// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Widget de entrada de valor monetário unificado para todos os formulários de cadastro
class SharedCurrencyInput extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onValueChanged;
  final String? errorText;
  final bool isRequired;
  final String? hintText;
  final Widget? prefixIcon;
  final EdgeInsets? padding;
  final bool enabled;
  final double? minValue;
  final double? maxValue;
  final String currencySymbol;
  final bool allowNegative;
  final TextAlign textAlign;
  final int decimalPlaces;
  final String? helpText;

  const SharedCurrencyInput({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChanged,
    this.errorText,
    this.isRequired = false,
    this.hintText,
    this.prefixIcon,
    this.padding,
    this.enabled = true,
    this.minValue,
    this.maxValue,
    this.currencySymbol = 'R\$',
    this.allowNegative = false,
    this.textAlign = TextAlign.right,
    this.decimalPlaces = 2,
    this.helpText,
  });

  /// Factory para consulta
  factory SharedCurrencyInput.consulta({
    required double value,
    required ValueChanged<double> onValueChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return SharedCurrencyInput(
      label: 'Valor da Consulta',
      value: value,
      onValueChanged: onValueChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'R\$ 0,00',
      prefixIcon: const Icon(Icons.monetization_on),
      maxValue: FormConstants.maxCurrencyValue,
      helpText: 'Valor pago pela consulta veterinária',
    );
  }

  /// Factory para despesa
  factory SharedCurrencyInput.despesa({
    required double value,
    required ValueChanged<double> onValueChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedCurrencyInput(
      label: 'Valor da Despesa',
      value: value,
      onValueChanged: onValueChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'R\$ 0,00',
      prefixIcon: const Icon(Icons.payment),
      maxValue: FormConstants.maxCurrencyValue,
      helpText: 'Valor gasto com o animal',
    );
  }

  /// Factory para medicamento
  factory SharedCurrencyInput.medicamento({
    required double value,
    required ValueChanged<double> onValueChanged,
    String? errorText,
    bool isRequired = false,
  }) {
    return SharedCurrencyInput(
      label: 'Valor do Medicamento',
      value: value,
      onValueChanged: onValueChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: 'R\$ 0,00',
      prefixIcon: const Icon(Icons.medication),
      maxValue: FormConstants.maxCurrencyValue,
      helpText: 'Valor pago pelo medicamento',
    );
  }

  /// Factory para peso (sem valor monetário, mas pode ser usado para outros números)
  factory SharedCurrencyInput.peso({
    required double value,
    required ValueChanged<double> onValueChanged,
    String? errorText,
    bool isRequired = true,
  }) {
    return SharedCurrencyInput(
      label: 'Peso',
      value: value,
      onValueChanged: onValueChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: '0,0 kg',
      prefixIcon: const Icon(Icons.monitor_weight),
      currencySymbol: '',
      maxValue: 200.0, // Máximo realista para animais domésticos
      decimalPlaces: 1,
      helpText: 'Peso do animal em quilogramas',
    );
  }

  /// Factory genérico
  factory SharedCurrencyInput.generic({
    required String label,
    required double value,
    required ValueChanged<double> onValueChanged,
    String? errorText,
    bool isRequired = false,
    String? hintText,
    Widget? prefixIcon,
    double? maxValue,
    String currencySymbol = 'R\$',
  }) {
    return SharedCurrencyInput(
      label: label,
      value: value,
      onValueChanged: onValueChanged,
      errorText: errorText,
      isRequired: isRequired,
      hintText: hintText,
      prefixIcon: prefixIcon,
      maxValue: maxValue,
      currencySymbol: currencySymbol,
    );
  }

  @override
  State<SharedCurrencyInput> createState() => _SharedCurrencyInputState();
}

class _SharedCurrencyInputState extends State<SharedCurrencyInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _updateControllerValue();
  }

  @override
  void didUpdateWidget(SharedCurrencyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateControllerValue();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateControllerValue() {
    if (widget.value > 0) {
      final formatted = widget.value.toStringAsFixed(widget.decimalPlaces);
      _controller.text = formatted.replaceAll('.', ',');
    } else {
      _controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: FormStyles.smallSpacing),
          _buildTextField(),
          if (widget.errorText != null) ...[
            const SizedBox(height: FormStyles.smallSpacing),
            _buildErrorText(),
          ],
          if (widget.helpText != null) ...[
            const SizedBox(height: FormStyles.tinySpacing),
            _buildHelpText(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.isRequired ? '${widget.label} *' : widget.label,
      style: FormStyles.subtitleTextStyle.copyWith(
        fontSize: FormStyles.bodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField() {
    final hasError = widget.errorText != null;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.numberWithOptions(
        decimal: widget.decimalPlaces > 0,
        signed: widget.allowNegative,
      ),
      textAlign: widget.textAlign,
      decoration: FormStyles.getInputDecoration(
        labelText: widget.hintText ?? '${widget.currencySymbol} 0,${'0' * widget.decimalPlaces}',
        errorText: null, // Handled separately
        prefixIcon: widget.prefixIcon,
        enabled: widget.enabled,
      ).copyWith(
        prefixText: widget.currencySymbol.isNotEmpty ? '${widget.currencySymbol} ' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          borderSide: BorderSide(
            color: hasError ? FormStyles.errorColor : FormStyles.borderColor,
            width: FormStyles.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          borderSide: BorderSide(
            color: hasError ? FormStyles.errorColor : FormStyles.borderColor,
            width: FormStyles.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          borderSide: BorderSide(
            color: hasError ? FormStyles.errorColor : FormStyles.primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          borderSide: const BorderSide(
            color: FormStyles.errorColor,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FormStyles.borderRadius),
          borderSide: const BorderSide(
            color: FormStyles.errorColor,
            width: 2.0,
          ),
        ),
      ),
      inputFormatters: [
        _CurrencyInputFormatter(
          decimalPlaces: widget.decimalPlaces,
          allowNegative: widget.allowNegative,
        ),
      ],
      validator: widget.isRequired ? _validateValue : null,
      onChanged: (value) {
        final parsedValue = _parseValue(value);
        widget.onValueChanged(parsedValue);
      },
      style: FormStyles.bodyTextStyle,
    );
  }

  Widget _buildErrorText() {
    return Text(
      widget.errorText!,
      style: FormStyles.errorTextStyle,
    );
  }

  Widget _buildHelpText() {
    return Text(
      widget.helpText!,
      style: FormStyles.captionTextStyle,
    );
  }

  String? _validateValue(String? value) {
    if (value?.isEmpty ?? true) {
      return FormConstants.requiredFieldMessage;
    }

    final parsedValue = _parseValue(value!);

    if (!widget.allowNegative && parsedValue < 0) {
      return 'Valor não pode ser negativo';
    }

    if (widget.minValue != null && parsedValue < widget.minValue!) {
      return 'Valor mínimo: ${_formatValue(widget.minValue!)}';
    }

    if (widget.maxValue != null && parsedValue > widget.maxValue!) {
      return 'Valor máximo: ${_formatValue(widget.maxValue!)}';
    }

    return null;
  }

  double _parseValue(String value) {
    // Remove currency symbol and spaces, replace comma with dot
    final normalized = value
        .replaceAll(widget.currencySymbol, '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0.0;
  }

  String _formatValue(double value) {
    final formatted = value.toStringAsFixed(widget.decimalPlaces);
    if (widget.currencySymbol.isNotEmpty) {
      return '${widget.currencySymbol} ${formatted.replaceAll('.', ',')}';
    }
    return formatted.replaceAll('.', ',');
  }

  /// Método estático para validação de valor
  static String? validateCurrency(
    String? value, {
    bool required = false,
    double? minValue,
    double? maxValue,
    bool allowNegative = false,
  }) {
    if (required && (value?.isEmpty ?? true)) {
      return FormConstants.requiredFieldMessage;
    }

    if (value?.isEmpty ?? true) return null;

    final parsedValue = double.tryParse(
      value!
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.')
          .trim(),
    );

    if (parsedValue == null) {
      return FormConstants.invalidValueMessage;
    }

    if (!allowNegative && parsedValue < 0) {
      return 'Valor não pode ser negativo';
    }

    if (minValue != null && parsedValue < minValue) {
      return 'Valor mínimo: R\$ ${minValue.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    if (maxValue != null && parsedValue > maxValue) {
      return 'Valor máximo: R\$ ${maxValue.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return null;
  }
}

/// Formatador de entrada para valores monetários
class _CurrencyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowNegative;

  const _CurrencyInputFormatter({
    this.decimalPlaces = 2,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Allow negative sign if permitted
    String filtered = newValue.text;
    if (allowNegative) {
      filtered = filtered.replaceAll(RegExp(r'[^0-9,.-]'), '');
      // Ensure only one negative sign at the beginning
      if (filtered.contains('-')) {
        filtered = filtered.replaceAll('-', '');
        if (newValue.text.startsWith('-')) {
          filtered = '-$filtered';
        }
      }
    } else {
      filtered = filtered.replaceAll(RegExp(r'[^0-9,.]'), '');
    }

    // Ensure only one decimal separator
    final parts = filtered.split(RegExp(r'[,.]'));
    if (parts.length > 2) {
      return oldValue;
    }

    if (parts.length == 2) {
      // Limit decimal places
      if (parts[1].length > decimalPlaces) {
        parts[1] = parts[1].substring(0, decimalPlaces);
      }
      final formatted = '${parts[0]},${parts[1]}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
