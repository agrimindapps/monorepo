import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_tokens.dart';

/// Estados de validação para feedback visual
enum ValidationState {
  /// Campo ainda não foi validado
  initial,
  /// Validação em progresso (debounce)
  validating,
  /// Campo válido
  valid,
  /// Campo inválido
  invalid,
  /// Erro de validação
  error,
}

/// Tipo de função de validação assíncrona
typedef AsyncValidator = Future<String?> Function(String value);

/// Campo de texto com validação em tempo real e feedback visual melhorado
class ValidatedTextField extends StatefulWidget {

  const ValidatedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    this.asyncValidator,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.validateOnChange = true,
    this.showValidationIcon = true,
    this.showCharacterCount = false,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.decoration,
    this.textStyle,
  });
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool required;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;
  final AsyncValidator? asyncValidator;
  final Duration debounceDuration;
  final bool validateOnChange;
  final bool showValidationIcon;
  final bool showCharacterCount;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> 
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  ValidationState _validationState = ValidationState.initial;
  String? _errorMessage;
  Timer? _debounceTimer;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  
  bool get _shouldShowValidationIcon => 
      widget.showValidationIcon && 
      _validationState != ValidationState.initial &&
      _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _iconAnimationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!widget.validateOnChange) return;
    
    final text = _controller.text;
    _debounceTimer?.cancel();
    widget.onChanged?.call(text);
    if (text.isEmpty) {
      setState(() {
        _validationState = ValidationState.initial;
        _errorMessage = null;
      });
      return;
    }
    setState(() {
      _validationState = ValidationState.validating;
      _errorMessage = null;
    });
    _debounceTimer = Timer(widget.debounceDuration, () {
      _performValidation(text);
    });
  }

  Future<void> _performValidation(String text) async {
    if (!mounted) return;
    
    try {
      String? error;
      if (widget.required && text.trim().isEmpty) {
        error = 'Este campo é obrigatório';
      }
      if (error == null && widget.validator != null) {
        error = widget.validator!(text);
      }
      if (error == null && widget.asyncValidator != null) {
        error = await widget.asyncValidator!(text);
      }
      
      if (!mounted) return;
      
      setState(() {
        if (error != null) {
          _validationState = ValidationState.invalid;
          _errorMessage = error;
        } else {
          _validationState = ValidationState.valid;
          _errorMessage = null;
        }
      });
      _iconAnimationController.forward();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validationState = ValidationState.error;
        _errorMessage = 'Erro na validação: $e';
      });
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<bool> validate() async {
    final text = _controller.text;
    await _performValidation(text);
    return _validationState == ValidationState.valid;
  }

  Widget _buildValidationIcon() {
    if (!_shouldShowValidationIcon) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color iconColor;

    switch (_validationState) {
      case ValidationState.validating:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GasometerDesignTokens.colorPrimary,
          ),
        );
      case ValidationState.valid:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case ValidationState.invalid:
      case ValidationState.error:
        iconData = Icons.error;
        iconColor = GasometerDesignTokens.colorError;
        break;
      case ValidationState.initial:
        return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _iconAnimation,
      child: Icon(
        iconData,
        color: iconColor,
        size: 16,
      ),
    );
  }

  Color? _getBorderColor() {
    if (!widget.enabled) return null;
    
    switch (_validationState) {
      case ValidationState.valid:
        return Colors.green;
      case ValidationState.invalid:
      case ValidationState.error:
        return GasometerDesignTokens.colorError;
      case ValidationState.validating:
        return GasometerDesignTokens.colorPrimary;
      case ValidationState.initial:
        return null;
    }
  }

  String? get _displayHelperText {
    if (_errorMessage != null) {
      return _errorMessage;
    }
    if (widget.helperText != null) {
      return widget.helperText;
    }
    if (widget.showCharacterCount && widget.maxLength != null) {
      final current = _controller.text.length;
      final max = widget.maxLength!;
      return '$current/$max caracteres';
    }
    
    return null;
  }

  Color? get _helperTextColor {
    switch (_validationState) {
      case ValidationState.invalid:
      case ValidationState.error:
        return GasometerDesignTokens.colorError;
      case ValidationState.valid:
        return Colors.green;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          obscureText: widget.obscureText,
          style: widget.textStyle,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          decoration: widget.decoration?.copyWith(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon) 
                : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildValidationIcon(),
                if (widget.suffix != null) ...[
                  const SizedBox(width: 8),
                  widget.suffix!,
                ],
                const SizedBox(width: 12),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            helperText: _displayHelperText,
            helperStyle: TextStyle(color: _helperTextColor),
            counterText: widget.showCharacterCount && widget.maxLength != null 
                ? null 
                : '', // Esconder contador padrão se não queremos
          ) ?? InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon) 
                : null,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildValidationIcon(),
                if (widget.suffix != null) ...[
                  const SizedBox(width: 8),
                  widget.suffix!,
                ],
                const SizedBox(width: 12),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            helperText: _displayHelperText,
            helperStyle: TextStyle(color: _helperTextColor),
            counterText: widget.showCharacterCount && widget.maxLength != null 
                ? null 
                : '',
          ),
        ),
        if (_validationState == ValidationState.validating)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
      ],
    );
  }
}

/// Extension para facilitar o uso de validadores comuns
extension CommonValidators on ValidatedTextField {
  /// Validador para email
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }
  
  /// Validador para valores monetários
  static String? moneyValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    final doubleValue = double.tryParse(cleanValue.replaceAll(',', '.'));
    
    if (doubleValue == null) {
      return 'Valor inválido';
    }
    
    if (doubleValue <= 0) {
      return 'Valor deve ser maior que zero';
    }
    
    return null;
  }
  
  /// Validador para números inteiros
  static String? intValidator(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) return null;
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Número inválido';
    }
    
    if (min != null && intValue < min) {
      return 'Valor deve ser pelo menos $min';
    }
    
    if (max != null && intValue > max) {
      return 'Valor deve ser no máximo $max';
    }
    
    return null;
  }
  
  /// Validador para comprimento mínimo
  static String? minLengthValidator(String? value, int minLength) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length < minLength) {
      return 'Deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }
}
