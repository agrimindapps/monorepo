import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';

/// Estados de validação para campos de data/hora
enum DateTimeValidationState {
  /// Campo ainda não foi validado
  initial,
  /// Validação em progresso
  validating,
  /// Campo válido
  valid,
  /// Campo inválido
  invalid,
  /// Erro de validação
  error,
}

/// Tipos de seleção de data/hora
enum DateTimePickerType {
  /// Apenas data
  date,
  /// Apenas hora
  time,
  /// Data e hora
  dateTime,
}

/// Tipo de função de validação assíncrona para data/hora
typedef DateTimeAsyncValidator = Future<String?> Function(DateTime? value);

/// Campo de data/hora com validação em tempo real
/// 
/// Segue os mesmos padrões visuais e de validação dos outros campos validados,
/// garantindo consistência na experiência do usuário.
class ValidatedDateTimeField extends StatefulWidget {
  /// Tipo de seleção (data, hora ou data+hora)
  final DateTimePickerType type;
  
  /// Valor inicial
  final DateTime? initialValue;
  
  /// Callback quando o valor é alterado
  final ValueChanged<DateTime?>? onChanged;
  
  /// Label do campo
  final String? label;
  
  /// Texto de dica quando nenhum valor está selecionado
  final String? hint;
  
  /// Texto de ajuda
  final String? helperText;
  
  /// Ícone prefixo
  final IconData? prefixIcon;
  
  /// Widget personalizado como sufixo
  final Widget? suffix;
  
  /// Se o campo está habilitado
  final bool enabled;
  
  /// Se o campo é obrigatório
  final bool required;
  
  /// Data mínima permitida (apenas para date e dateTime)
  final DateTime? firstDate;
  
  /// Data máxima permitida (apenas para date e dateTime)
  final DateTime? lastDate;
  
  /// Formato de exibição da data/hora
  final String? format;
  
  /// Usar formato 24 horas (apenas para time e dateTime)
  final bool use24HourFormat;
  
  // Validação
  /// Validador síncrono
  final String? Function(DateTime?)? validator;
  
  /// Validador assíncrono
  final DateTimeAsyncValidator? asyncValidator;
  
  /// Duração do debounce para validação
  final Duration debounceDuration;
  
  /// Se deve validar ao alterar o valor
  final bool validateOnChange;
  
  /// Se deve mostrar ícone de validação
  final bool showValidationIcon;
  
  // Callbacks
  /// Callback quando a edição é completada
  final VoidCallback? onEditingComplete;
  
  // Estilo customizado
  /// Decoração customizada
  final InputDecoration? decoration;

  const ValidatedDateTimeField({
    super.key,
    this.type = DateTimePickerType.date,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.required = false,
    this.firstDate,
    this.lastDate,
    this.format,
    this.use24HourFormat = true,
    this.validator,
    this.asyncValidator,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.validateOnChange = true,
    this.showValidationIcon = true,
    this.onEditingComplete,
    this.decoration,
  });

  @override
  State<ValidatedDateTimeField> createState() => _ValidatedDateTimeFieldState();
}

class _ValidatedDateTimeFieldState extends State<ValidatedDateTimeField>
    with SingleTickerProviderStateMixin {
  
  DateTime? _selectedValue;
  DateTimeValidationState _validationState = DateTimeValidationState.initial;
  String? _errorMessage;
  Timer? _debounceTimer;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  late DateFormat _dateFormatter;

  bool get _shouldShowValidationIcon =>
      widget.showValidationIcon &&
      _validationState != DateTimeValidationState.initial &&
      _selectedValue != null;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _setupFormatter();
    
    // Configurar animação para ícones de validação
    _iconAnimationController = AnimationController(
      duration: GasometerDesignTokens.animationFast,
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(ValidatedDateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selectedValue = widget.initialValue;
    }
    if (oldWidget.format != widget.format || oldWidget.type != widget.type) {
      _setupFormatter();
    }
    if (oldWidget.initialValue != widget.initialValue && widget.validateOnChange) {
      _validateValue(_selectedValue);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _setupFormatter() {
    switch (widget.type) {
      case DateTimePickerType.date:
        _dateFormatter = DateFormat(widget.format ?? 'dd/MM/yyyy', 'pt_BR');
        break;
      case DateTimePickerType.time:
        _dateFormatter = DateFormat(
          widget.format ?? (widget.use24HourFormat ? 'HH:mm' : 'hh:mm a'), 
          'pt_BR'
        );
        break;
      case DateTimePickerType.dateTime:
        _dateFormatter = DateFormat(
          widget.format ?? (widget.use24HourFormat ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy hh:mm a'), 
          'pt_BR'
        );
        break;
    }
  }

  void _onValueChanged(DateTime? value) {
    setState(() {
      _selectedValue = value;
    });
    
    widget.onChanged?.call(value);
    widget.onEditingComplete?.call();
    
    if (widget.validateOnChange) {
      // Cancelar timer anterior se existir
      _debounceTimer?.cancel();
      
      if (value == null) {
        setState(() {
          _validationState = DateTimeValidationState.initial;
          _errorMessage = null;
        });
        return;
      }
      
      // Mostrar estado de validação
      setState(() {
        _validationState = DateTimeValidationState.validating;
        _errorMessage = null;
      });
      
      // Configurar debounce
      _debounceTimer = Timer(widget.debounceDuration, () {
        _validateValue(value);
      });
    }
  }

  Future<void> _validateValue(DateTime? value) async {
    if (!mounted) return;
    
    try {
      String? error;
      
      // Validação obrigatória para campos required
      if (widget.required && value == null) {
        error = 'Este campo é obrigatório';
      }
      
      // Validação de intervalo para campos de data
      if (error == null && value != null && 
          (widget.type == DateTimePickerType.date || widget.type == DateTimePickerType.dateTime)) {
        if (widget.firstDate != null && value.isBefore(widget.firstDate!)) {
          error = 'Data deve ser posterior a ${_dateFormatter.format(widget.firstDate!)}';
        }
        if (widget.lastDate != null && value.isAfter(widget.lastDate!)) {
          error = 'Data deve ser anterior a ${_dateFormatter.format(widget.lastDate!)}';
        }
      }
      
      // Validação síncrona
      if (error == null && widget.validator != null) {
        error = widget.validator!(value);
      }
      
      // Validação assíncrona
      if (error == null && widget.asyncValidator != null) {
        error = await widget.asyncValidator!(value);
      }
      
      if (!mounted) return;
      
      setState(() {
        if (error != null) {
          _validationState = DateTimeValidationState.invalid;
          _errorMessage = error;
        } else {
          _validationState = DateTimeValidationState.valid;
          _errorMessage = null;
        }
      });
      
      // Animar ícone
      await _iconAnimationController.forward();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validationState = DateTimeValidationState.error;
        _errorMessage = 'Erro na validação: $e';
      });
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<bool> validate() async {
    await _validateValue(_selectedValue);
    return _validationState == DateTimeValidationState.valid;
  }

  Widget _buildValidationIcon() {
    if (!_shouldShowValidationIcon) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color iconColor;

    switch (_validationState) {
      case DateTimeValidationState.validating:
        return SizedBox(
          width: GasometerDesignTokens.iconSizeXs,
          height: GasometerDesignTokens.iconSizeXs,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GasometerDesignTokens.colorPrimary,
          ),
        );
      case DateTimeValidationState.valid:
        iconData = Icons.check_circle;
        iconColor = GasometerDesignTokens.colorSuccess;
        break;
      case DateTimeValidationState.invalid:
      case DateTimeValidationState.error:
        iconData = Icons.error;
        iconColor = GasometerDesignTokens.colorError;
        break;
      case DateTimeValidationState.initial:
        return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _iconAnimation,
      child: Icon(
        iconData,
        color: iconColor,
        size: GasometerDesignTokens.iconSizeXs,
      ),
    );
  }

  Color? _getBorderColor() {
    if (!widget.enabled) return null;
    
    switch (_validationState) {
      case DateTimeValidationState.valid:
        return GasometerDesignTokens.colorSuccess;
      case DateTimeValidationState.invalid:
      case DateTimeValidationState.error:
        return GasometerDesignTokens.colorError;
      case DateTimeValidationState.validating:
        return GasometerDesignTokens.colorPrimary;
      case DateTimeValidationState.initial:
        return null;
    }
  }

  String? get _displayHelperText {
    // Priorizar mensagem de erro
    if (_errorMessage != null) {
      return _errorMessage;
    }
    
    // Mensagem de helper padrão
    return widget.helperText;
  }

  Color? get _helperTextColor {
    switch (_validationState) {
      case DateTimeValidationState.invalid:
      case DateTimeValidationState.error:
        return GasometerDesignTokens.colorError;
      case DateTimeValidationState.valid:
        return GasometerDesignTokens.colorSuccess;
      default:
        return null;
    }
  }

  Future<void> _selectDateTime() async {
    if (!widget.enabled) return;

    DateTime? result;

    switch (widget.type) {
      case DateTimePickerType.date:
        result = await _selectDate();
        break;
      case DateTimePickerType.time:
        result = await _selectTime();
        break;
      case DateTimePickerType.dateTime:
        result = await _selectDateAndTime();
        break;
    }

    if (result != null) {
      _onValueChanged(result);
    }
  }

  Future<DateTime?> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedValue ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    return date;
  }

  Future<DateTime?> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedValue != null 
          ? TimeOfDay.fromDateTime(_selectedValue!) 
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    return null;
  }

  Future<DateTime?> _selectDateAndTime() async {
    // Primeiro selecionar a data
    final date = await _selectDate();
    if (date == null || !mounted) return null;
    
    // Depois selecionar o horário
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedValue != null
          ? TimeOfDay.fromDateTime(_selectedValue!)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time == null) return date; // Retorna só a data se cancelar o horário
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String get _displayText {
    if (_selectedValue == null) return '';
    return _dateFormatter.format(_selectedValue!);
  }

  String get _hintText {
    if (widget.hint != null) return widget.hint!;
    
    switch (widget.type) {
      case DateTimePickerType.date:
        return 'Selecionar data';
      case DateTimePickerType.time:
        return 'Selecionar horário';
      case DateTimePickerType.dateTime:
        return 'Selecionar data e horário';
    }
  }

  IconData get _suffixIcon {
    switch (widget.type) {
      case DateTimePickerType.date:
      case DateTimePickerType.dateTime:
        return Icons.calendar_today;
      case DateTimePickerType.time:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: GasometerDesignTokens.spacingSm),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: TextStyle(
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                  color: GasometerDesignTokens.colorTextPrimary,
                  fontSize: GasometerDesignTokens.fontSizeBody,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: GasometerDesignTokens.colorError,
                        fontWeight: GasometerDesignTokens.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        
        // Campo de seleção
        InkWell(
          onTap: widget.enabled ? _selectDateTime : null,
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
          child: Container(
            padding: GasometerDesignTokens.paddingHorizontal(GasometerDesignTokens.spacingLg)
                .add(GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingLg)),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? GasometerDesignTokens.colorSurface
                  : GasometerDesignTokens.colorNeutral100,
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
              border: Border.all(
                color: borderColor ?? GasometerDesignTokens.colorNeutral300,
                width: borderColor != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Ícone prefixo
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: widget.enabled
                        ? GasometerDesignTokens.colorTextSecondary
                        : GasometerDesignTokens.colorNeutral400,
                    size: GasometerDesignTokens.iconSizeSm,
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingMd),
                ],
                
                // Texto da data/hora
                Expanded(
                  child: Text(
                    _displayText.isEmpty ? _hintText : _displayText,
                    style: TextStyle(
                      color: _displayText.isEmpty
                          ? GasometerDesignTokens.colorTextSecondary
                          : (widget.enabled
                              ? GasometerDesignTokens.colorTextPrimary
                              : GasometerDesignTokens.colorTextSecondary),
                      fontSize: GasometerDesignTokens.fontSizeBody,
                    ),
                  ),
                ),
                
                // Ícones e sufixos
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildValidationIcon(),
                    if (widget.suffix != null) ...[
                      SizedBox(width: GasometerDesignTokens.spacingSm),
                      widget.suffix!,
                    ],
                    SizedBox(width: GasometerDesignTokens.spacingSm),
                    Icon(
                      _suffixIcon,
                      color: widget.enabled
                          ? GasometerDesignTokens.colorTextSecondary
                          : GasometerDesignTokens.colorNeutral400,
                      size: GasometerDesignTokens.iconSizeSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Helper text
        if (_displayHelperText != null)
          Padding(
            padding: EdgeInsets.only(
              top: GasometerDesignTokens.spacingXs,
              left: GasometerDesignTokens.spacingLg,
            ),
            child: Text(
              _displayHelperText!,
              style: TextStyle(
                color: _helperTextColor ?? GasometerDesignTokens.colorTextSecondary,
                fontSize: GasometerDesignTokens.fontSizeCaption,
              ),
            ),
          ),
        
        // Indicador de progresso para validação
        if (_validationState == DateTimeValidationState.validating)
          Padding(
            padding: EdgeInsets.only(top: GasometerDesignTokens.spacingXs),
            child: LinearProgressIndicator(
              color: GasometerDesignTokens.colorPrimary,
              backgroundColor: GasometerDesignTokens.colorPrimary.withValues(alpha: 0.2),
            ),
          ),
      ],
    );
  }
}

/// Extension para facilitar o uso de validadores comuns para data/hora
extension CommonDateTimeValidators on DateTime {
  /// Validador para campos obrigatórios
  static String? requiredValidator(DateTime? value) {
    if (value == null) {
      return 'Este campo é obrigatório';
    }
    return null;
  }
  
  /// Validador para data no futuro
  static String? futureValidator(DateTime? value) {
    if (value == null) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final valueDate = DateTime(value.year, value.month, value.day);
    
    if (valueDate.isBefore(today)) {
      return 'Data deve ser no futuro';
    }
    return null;
  }
  
  /// Validador para data no passado
  static String? pastValidator(DateTime? value) {
    if (value == null) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final valueDate = DateTime(value.year, value.month, value.day);
    
    if (valueDate.isAfter(today)) {
      return 'Data deve ser no passado';
    }
    return null;
  }
  
  /// Validador para horário comercial (8h às 18h)
  static String? businessHoursValidator(DateTime? value) {
    if (value == null) return null;
    
    final hour = value.hour;
    if (hour < 8 || hour >= 18) {
      return 'Horário deve ser entre 08:00 e 18:00';
    }
    return null;
  }
  
  /// Validador personalizado para intervalo de datas
  static String? Function(DateTime?) dateRangeValidator(
    DateTime startDate, 
    DateTime endDate, 
    [String? message]
  ) {
    return (DateTime? value) {
      if (value == null) return null;
      
      if (value.isBefore(startDate) || value.isAfter(endDate)) {
        final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
        return message ?? 
            'Data deve estar entre ${formatter.format(startDate)} e ${formatter.format(endDate)}';
      }
      return null;
    };
  }
}