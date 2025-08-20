// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'form_state_manager.dart';

/// Widget base para campos de formulário com estado gerenciado
abstract class FormFieldWidget<T> extends StatefulWidget {
  final String fieldName;
  final FormStateManager stateManager;
  final String? label;
  final String? hint;
  final bool required;
  final Function(T)? onChanged;
  final Function(FieldValidationResult)? validator;

  const FormFieldWidget({
    super.key,
    required this.fieldName,
    required this.stateManager,
    this.label,
    this.hint,
    this.required = false,
    this.onChanged,
    this.validator,
  });
}

/// State base para campos de formulário
abstract class FormFieldWidgetState<T, W extends FormFieldWidget<T>>
    extends State<W> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Escuta mudanças no state manager
    widget.stateManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.stateManager.removeListener(_onStateChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    widget.stateManager.setFieldFocus(widget.fieldName, _focusNode.hasFocus);

    if (!_focusNode.hasFocus) {
      _validateField();
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _validateField() {
    final value = widget.stateManager.getFieldValue<T>(widget.fieldName);
    final validation = validateValue(value);

    widget.stateManager.validateField<T>(widget.fieldName, validation);

    if (widget.validator != null) {
      widget.validator!(validation);
    }
  }

  /// Implementar validação específica do campo
  FieldValidationResult validateValue(T value);

  /// Implementar construção do widget específico
  Widget buildFieldWidget(
      BuildContext context, ManagedFieldState<T> fieldState);

  /// Atualizar valor do campo
  void updateValue(T value) {
    final validation = validateValue(value);
    widget.stateManager.updateField<T>(
      widget.fieldName,
      value,
      validation: validation,
    );

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  /// Obter estado atual do campo
  ManagedFieldState<T> get fieldState =>
      widget.stateManager.getFieldState<T>(widget.fieldName);

  /// Obter valor atual do campo
  T get currentValue => fieldState.value;

  /// Verificar se tem erro
  bool get hasError => !fieldState.validation.isValid;

  /// Verificar se tem warning
  bool get hasWarning => fieldState.validation.warningMessage != null;

  /// Focus node para acesso pelos widgets filhos
  FocusNode get focusNode => _focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (widget.required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Widget específico do campo
        buildFieldWidget(context, fieldState),

        // Mensagens de erro/warning
        if (hasError || hasWarning) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.warning_amber_outlined,
                size: 16,
                color: hasError ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hasError
                      ? fieldState.validation.errorMessage!
                      : fieldState.validation.warningMessage!,
                  style: TextStyle(
                    color: hasError ? Colors.red : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Widget específico para campos de texto
class TextFormFieldWidget extends FormFieldWidget<String> {
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final String? suffixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const TextFormFieldWidget({
    super.key,
    required super.fieldName,
    required super.stateManager,
    super.label,
    super.hint,
    super.required,
    super.onChanged,
    super.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.suffixText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState
    extends FormFieldWidgetState<String, TextFormFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  FieldValidationResult validateValue(String value) {
    // Validação básica
    if (widget.required && value.isEmpty) {
      return FieldValidationResult.invalid(
          '${widget.label ?? 'Campo'} é obrigatório');
    }

    if (widget.maxLength != null && value.length > widget.maxLength!) {
      return FieldValidationResult.invalid(
          'Máximo ${widget.maxLength} caracteres');
    }

    return FieldValidationResult.valid();
  }

  @override
  Widget buildFieldWidget(
      BuildContext context, ManagedFieldState<String> fieldState) {
    // Sincronizar controller com o estado
    if (_controller.text != fieldState.value) {
      _controller.text = fieldState.value;
    }

    return TextField(
      controller: _controller,
      focusNode: focusNode,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixText: widget.suffixText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.blue,
          ),
        ),
      ),
      onChanged: updateValue,
    );
  }
}
