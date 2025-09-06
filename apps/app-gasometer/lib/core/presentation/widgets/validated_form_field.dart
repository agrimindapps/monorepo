import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../interfaces/validation_result.dart';
import '../../validation/validation_service.dart';

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
  /// Campo válido mas com aviso
  warning,
}

/// Tipos de validação predefinidos
enum ValidationType {
  none,
  required,
  email,
  phone,
  money,
  decimal,
  integer,
  licensePlate,
  chassis,
  renavam,
  odometer,
  fuelLiters,
  fuelPrice,
  length,
  custom,
}

/// Widget de campo de formulário com validação robusta e feedback visual
class ValidatedFormField extends StatefulWidget {
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
  final TextAlign textAlign;
  
  // Validação
  final ValidationType validationType;
  final String? Function(String?)? customValidator;
  final bool validateOnChange;
  final bool validateOnFocusOut;
  final bool showValidationIcon;
  final bool showCharacterCount;
  final Duration debounceDuration;
  
  // Parâmetros específicos de validação
  final double? minValue;
  final double? maxValue;
  final int? minLength;
  final int? maxLengthValidation;
  final String? pattern;
  
  // Contexto específico para validações automotivas
  final double? currentOdometer;
  final double? initialOdometer;
  final double? tankCapacity;
  
  // Callbacks
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<ValidationResult>? onValidationChanged;
  
  // Estilo
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  const ValidatedFormField({
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
    this.textAlign = TextAlign.start,
    this.validationType = ValidationType.none,
    this.customValidator,
    this.validateOnChange = false,
    this.validateOnFocusOut = true,
    this.showValidationIcon = true,
    this.showCharacterCount = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLengthValidation,
    this.pattern,
    this.currentOdometer,
    this.initialOdometer,
    this.tankCapacity,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onValidationChanged,
    this.decoration,
    this.textStyle,
  });

  @override
  State<ValidatedFormField> createState() => _ValidatedFormFieldState();
}

class _ValidatedFormFieldState extends State<ValidatedFormField> 
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late ValidationService _validationService;
  
  ValidationState _validationState = ValidationState.initial;
  ValidationResult _lastValidationResult = ValidationResult.success();
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
    _validationService = ValidationService();
    
    // Configurar animação para ícones de validação
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
    
    // Listener para mudanças no texto
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
    final text = _controller.text;
    
    // Chamar callback imediatamente
    widget.onChanged?.call(text);
    
    // Se validação onChange estiver desabilitada, apenas limpar estado se campo vazio
    if (!widget.validateOnChange) {
      if (text.isEmpty) {
        setState(() {
          _validationState = ValidationState.initial;
          _lastValidationResult = ValidationResult.success();
        });
        widget.onValidationChanged?.call(_lastValidationResult);
      }
      return;
    }
    
    // Cancelar timer anterior se existir
    _debounceTimer?.cancel();
    
    // Validação com debounce
    if (text.isEmpty && !widget.required) {
      setState(() {
        _validationState = ValidationState.initial;
        _lastValidationResult = ValidationResult.success();
      });
      widget.onValidationChanged?.call(_lastValidationResult);
      return;
    }
    
    // Mostrar estado de validação
    setState(() {
      _validationState = ValidationState.validating;
    });
    
    // Configurar debounce
    _debounceTimer = Timer(widget.debounceDuration, () {
      _performValidation(text);
    });
  }

  Future<void> _performValidation(String text) async {
    if (!mounted) return;
    
    try {
      ValidationResult result;
      
      // Validação customizada tem prioridade
      if (widget.customValidator != null) {
        final error = widget.customValidator!(text);
        result = error != null 
            ? ValidationResult.error(error)
            : ValidationResult.success();
      } else {
        // Usar validação predefinida baseada no tipo
        result = _getValidationForType(text);
      }
      
      if (!mounted) return;
      
      setState(() {
        _lastValidationResult = result;
        if (!result.isValid) {
          _validationState = ValidationState.invalid;
        } else if (result.isWarning) {
          _validationState = ValidationState.warning;
        } else {
          _validationState = ValidationState.valid;
        }
      });
      
      // Notificar mudança de validação
      widget.onValidationChanged?.call(result);
      
      // Animar ícone
      _iconAnimationController.forward();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validationState = ValidationState.invalid;
        _lastValidationResult = ValidationResult.error('Erro na validação: $e');
      });
      
      widget.onValidationChanged?.call(_lastValidationResult);
    }
  }

  ValidationResult _getValidationForType(String text) {
    switch (widget.validationType) {
      case ValidationType.none:
        return ValidationResult.success();
        
      case ValidationType.required:
        return _validationService.validateRequired(text, widget.label ?? 'Campo');
        
      case ValidationType.email:
        return _validationService.validateEmail(text);
        
      case ValidationType.phone:
        return _validationService.validatePhone(text);
        
      case ValidationType.money:
        return _validationService.validateMoney(
          text, 
          widget.label ?? 'Valor',
          min: widget.minValue ?? 0.0,
          max: widget.maxValue ?? 999999.99,
          required: widget.required,
        );
        
      case ValidationType.decimal:
        return _validationService.validateDecimal(
          text,
          widget.label ?? 'Número',
          min: widget.minValue,
          max: widget.maxValue,
          required: widget.required,
        );
        
      case ValidationType.integer:
        return _validationService.validateInteger(
          text,
          widget.label ?? 'Número',
          min: widget.minValue?.toInt(),
          max: widget.maxValue?.toInt(),
          required: widget.required,
        );
        
      case ValidationType.licensePlate:
        return _validationService.validateLicensePlate(text);
        
      case ValidationType.chassis:
        return _validationService.validateChassis(text);
        
      case ValidationType.renavam:
        return _validationService.validateRenavam(text);
        
      case ValidationType.odometer:
        return _validationService.validateOdometer(
          text,
          currentOdometer: widget.currentOdometer,
          initialOdometer: widget.initialOdometer,
          required: widget.required,
        );
        
      case ValidationType.fuelLiters:
        return _validationService.validateFuelLiters(
          text,
          tankCapacity: widget.tankCapacity,
          required: widget.required,
        );
        
      case ValidationType.fuelPrice:
        return _validationService.validateFuelPrice(text, required: widget.required);
        
      case ValidationType.length:
        return _validationService.validateLength(
          text,
          widget.label ?? 'Campo',
          minLength: widget.minLength ?? 0,
          maxLength: widget.maxLengthValidation ?? 255,
        );
        
      case ValidationType.custom:
        return ValidationResult.success(); // Será tratado pelo customValidator
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<ValidationResult> validate() async {
    final text = _controller.text;
    await _performValidation(text);
    return _lastValidationResult;
  }

  /// Limpa validação
  void clearValidation() {
    setState(() {
      _validationState = ValidationState.initial;
      _lastValidationResult = ValidationResult.success();
    });
    widget.onValidationChanged?.call(_lastValidationResult);
  }

  Widget _buildValidationIcon() {
    if (!_shouldShowValidationIcon) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color iconColor;

    switch (_validationState) {
      case ValidationState.validating:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case ValidationState.valid:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case ValidationState.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case ValidationState.invalid:
        iconData = Icons.error;
        iconColor = Theme.of(context).colorScheme.error;
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
      case ValidationState.warning:
        return Colors.orange;
      case ValidationState.invalid:
        return Theme.of(context).colorScheme.error;
      case ValidationState.validating:
        return Theme.of(context).colorScheme.primary;
      case ValidationState.initial:
        return null;
    }
  }

  String? get _displayHelperText {
    // Priorizar mensagem de validação
    if (_lastValidationResult.hasMessage) {
      return _lastValidationResult.message;
    }
    
    // Mensagem de helper padrão
    if (widget.helperText != null) {
      return widget.helperText;
    }
    
    // Contador de caracteres se habilitado
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
        return Theme.of(context).colorScheme.error;
      case ValidationState.warning:
        return Colors.orange;
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
          textAlign: widget.textAlign,
          style: widget.textStyle,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          onTap: () {
            // Reset validation state quando campo ganha foco se não está validando em tempo real
            if (!widget.validateOnChange && _validationState == ValidationState.invalid) {
              setState(() {
                _validationState = ValidationState.initial;
                _lastValidationResult = ValidationResult.success();
              });
            }
          },
          onTapOutside: (_) {
            // Validar quando campo perde foco
            if (widget.validateOnFocusOut) {
              final text = _controller.text;
              _performValidation(text);
            }
          },
          // Validação no FormField é delegada ao nosso sistema
          validator: (_) => _lastValidationResult.isValid ? null : _lastValidationResult.message,
          decoration: widget.decoration?.copyWith(
            labelText: widget.required && widget.label != null 
                ? '${widget.label} *' 
                : widget.label,
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
            enabledBorder: borderColor != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  )
                : null,
            focusedBorder: borderColor != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  )
                : null,
            helperText: _displayHelperText,
            helperStyle: TextStyle(color: _helperTextColor),
            counterText: widget.showCharacterCount && widget.maxLength != null 
                ? null 
                : '', // Esconder contador padrão se não queremos
          ) ?? InputDecoration(
            labelText: widget.required && widget.label != null 
                ? '${widget.label} *' 
                : widget.label,
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
            ),
            enabledBorder: borderColor != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
            focusedBorder: borderColor != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            helperText: _displayHelperText,
            helperStyle: TextStyle(color: _helperTextColor),
            counterText: widget.showCharacterCount && widget.maxLength != null 
                ? null 
                : '',
          ),
        ),
        
        // Indicador de progresso para validação
        if (_validationState == ValidationState.validating)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
      ],
    );
  }
}

/// Extension para uso fácil de validações comuns
extension ValidatedFormFieldExtensions on ValidatedFormField {
  /// Factory para campo de email
  static ValidatedFormField email({
    Key? key,
    TextEditingController? controller,
    String? label = 'Email',
    String? hint = 'exemplo@email.com',
    bool required = false,
    ValueChanged<String>? onChanged,
    ValueChanged<ValidationResult>? onValidationChanged,
  }) {
    return ValidatedFormField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      required: required,
      validationType: ValidationType.email,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      onValidationChanged: onValidationChanged,
    );
  }

  /// Factory para campo de placa
  static ValidatedFormField licensePlate({
    Key? key,
    TextEditingController? controller,
    String? label = 'Placa',
    String? hint = 'ABC1234 ou ABC1D23',
    ValueChanged<String>? onChanged,
    ValueChanged<ValidationResult>? onValidationChanged,
  }) {
    return ValidatedFormField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      required: true,
      validationType: ValidationType.licensePlate,
      maxLength: 7,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        LengthLimitingTextInputFormatter(7),
        UpperCaseTextFormatter(),
      ],
      onChanged: onChanged,
      onValidationChanged: onValidationChanged,
    );
  }

  /// Factory para campo de odômetro
  static ValidatedFormField odometer({
    Key? key,
    TextEditingController? controller,
    String? label = 'Odômetro',
    String? hint = '0,0',
    double? currentOdometer,
    double? initialOdometer,
    bool required = true,
    ValueChanged<String>? onChanged,
    ValueChanged<ValidationResult>? onValidationChanged,
  }) {
    return ValidatedFormField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      required: required,
      validationType: ValidationType.odometer,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      currentOdometer: currentOdometer,
      initialOdometer: initialOdometer,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      onChanged: onChanged,
      onValidationChanged: onValidationChanged,
    );
  }

  /// Factory para campo de valor monetário
  static ValidatedFormField money({
    Key? key,
    TextEditingController? controller,
    String? label = 'Valor',
    String? hint = '0,00',
    double? minValue,
    double? maxValue,
    bool required = true,
    ValueChanged<String>? onChanged,
    ValueChanged<ValidationResult>? onValidationChanged,
  }) {
    return ValidatedFormField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      required: required,
      validationType: ValidationType.money,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      minValue: minValue,
      maxValue: maxValue,
      decoration: const InputDecoration(
        prefixText: 'R\$ ',
      ),
      onChanged: onChanged,
      onValidationChanged: onValidationChanged,
    );
  }
}

/// Formatter para converter para maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}