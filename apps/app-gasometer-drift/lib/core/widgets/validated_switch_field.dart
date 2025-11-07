import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Estados de validação para switches
enum SwitchValidationState {
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

/// Tipo de função de validação assíncrona para switch
typedef SwitchAsyncValidator = Future<String?> Function(bool value);

/// Switch com validação e feedback visual padronizado
///
/// Segue os mesmos padrões visuais dos outros campos validados,
/// garantindo consistência na experiência do usuário.
class ValidatedSwitchField extends StatefulWidget {
  const ValidatedSwitchField({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.asyncValidator,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.validateOnChange = true,
    this.showValidationIcon = true,
    this.onEditingComplete,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.labelPosition = SwitchLabelPosition.start,
  });

  /// Valor inicial do switch
  final bool value;

  /// Callback quando o valor é alterado
  final ValueChanged<bool>? onChanged;

  /// Label do campo
  final String? label;

  /// Descrição adicional
  final String? description;

  /// Texto de ajuda
  final String? helperText;

  /// Se o campo está habilitado
  final bool enabled;

  /// Se o campo é obrigatório (deve estar ativo)
  final bool required;

  /// Validador síncrono
  final String? Function(bool)? validator;

  /// Validador assíncrono
  final SwitchAsyncValidator? asyncValidator;

  /// Duração do debounce para validação
  final Duration debounceDuration;

  /// Se deve validar ao alterar o valor
  final bool validateOnChange;

  /// Se deve mostrar ícone de validação
  final bool showValidationIcon;

  /// Callback quando a edição é completada
  final VoidCallback? onEditingComplete;

  /// Cor personalizada para o switch ativo
  final Color? activeColor;

  /// Cor personalizada para o track ativo
  final Color? activeTrackColor;

  /// Cor personalizada para o switch inativo
  final Color? inactiveThumbColor;

  /// Cor personalizada para o track inativo
  final Color? inactiveTrackColor;

  /// Layout da label em relação ao switch
  final SwitchLabelPosition labelPosition;

  @override
  State<ValidatedSwitchField> createState() => _ValidatedSwitchFieldState();
}

/// Posição da label em relação ao switch
enum SwitchLabelPosition {
  /// Label no início (à esquerda do switch)
  start,

  /// Label no final (à direita do switch)
  end,

  /// Label acima do switch
  top,
}

class _ValidatedSwitchFieldState extends State<ValidatedSwitchField>
    with SingleTickerProviderStateMixin {
  SwitchValidationState _validationState = SwitchValidationState.initial;
  String? _errorMessage;
  Timer? _debounceTimer;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;

  bool get _shouldShowValidationIcon =>
      widget.showValidationIcon &&
      _validationState != SwitchValidationState.initial;

  @override
  void initState() {
    super.initState();
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
    if (widget.validateOnChange) {
      _validateValue(widget.value);
    }
  }

  @override
  void didUpdateWidget(ValidatedSwitchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.validateOnChange) {
      _validateValue(widget.value);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onValueChanged(bool value) {
    widget.onChanged?.call(value);
    widget.onEditingComplete?.call();

    if (widget.validateOnChange) {
      _debounceTimer?.cancel();
      setState(() {
        _validationState = SwitchValidationState.validating;
        _errorMessage = null;
      });
      _debounceTimer = Timer(widget.debounceDuration, () {
        _validateValue(value);
      });
    }
  }

  Future<void> _validateValue(bool value) async {
    if (!mounted) return;

    try {
      String? error;
      if (widget.required && !value) {
        error = 'Esta opção deve estar ativa';
      }
      if (error == null && widget.validator != null) {
        error = widget.validator!(value);
      }
      if (error == null && widget.asyncValidator != null) {
        error = await widget.asyncValidator!(value);
      }

      if (!mounted) return;

      setState(() {
        if (error != null) {
          _validationState = SwitchValidationState.invalid;
          _errorMessage = error;
        } else {
          _validationState = SwitchValidationState.valid;
          _errorMessage = null;
        }
      });
      await _iconAnimationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _validationState = SwitchValidationState.error;
        _errorMessage = 'Erro na validação: $e';
      });
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<bool> validate() async {
    await _validateValue(widget.value);
    return _validationState == SwitchValidationState.valid ||
        _validationState == SwitchValidationState.initial;
  }

  Widget _buildValidationIcon() {
    if (!_shouldShowValidationIcon) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color iconColor;

    switch (_validationState) {
      case SwitchValidationState.validating:
        return const SizedBox(
          width: GasometerDesignTokens.iconSizeXs,
          height: GasometerDesignTokens.iconSizeXs,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GasometerDesignTokens.colorPrimary,
          ),
        );
      case SwitchValidationState.valid:
        iconData = Icons.check_circle;
        iconColor = GasometerDesignTokens.colorSuccess;
        break;
      case SwitchValidationState.invalid:
      case SwitchValidationState.error:
        iconData = Icons.error;
        iconColor = GasometerDesignTokens.colorError;
        break;
      case SwitchValidationState.initial:
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

  String? get _displayHelperText {
    if (_errorMessage != null) {
      return _errorMessage;
    }
    return widget.helperText;
  }

  Color? get _helperTextColor {
    switch (_validationState) {
      case SwitchValidationState.invalid:
      case SwitchValidationState.error:
        return GasometerDesignTokens.colorError;
      case SwitchValidationState.valid:
        return GasometerDesignTokens.colorSuccess;
      default:
        return null;
    }
  }

  Widget _buildSwitch() {
    return Switch(
      value: widget.value,
      onChanged: widget.enabled ? _onValueChanged : null,
      activeThumbColor:
          widget.activeColor ?? GasometerDesignTokens.colorPrimary,
      activeTrackColor:
          widget.activeTrackColor ??
          GasometerDesignTokens.colorPrimary.withValues(alpha: 0.3),
      inactiveThumbColor:
          widget.inactiveThumbColor ?? GasometerDesignTokens.colorNeutral400,
      inactiveTrackColor:
          widget.inactiveTrackColor ?? GasometerDesignTokens.colorNeutral200,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildLabelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          RichText(
            text: TextSpan(
              text: widget.label,
              style: TextStyle(
                fontWeight: GasometerDesignTokens.fontWeightMedium,
                color: widget.enabled
                    ? GasometerDesignTokens.colorTextPrimary
                    : GasometerDesignTokens.colorTextSecondary,
                fontSize: GasometerDesignTokens.fontSizeBody,
              ),
              children: [
                if (widget.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: GasometerDesignTokens.colorError,
                      fontWeight: GasometerDesignTokens.fontWeightMedium,
                    ),
                  ),
              ],
            ),
          ),
        if (widget.description != null) ...[
          const SizedBox(height: GasometerDesignTokens.spacingXs),
          Text(
            widget.description!,
            style: TextStyle(
              color: widget.enabled
                  ? GasometerDesignTokens.colorTextSecondary
                  : GasometerDesignTokens.colorNeutral400,
              fontSize: GasometerDesignTokens.fontSizeCaption,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow() {
    final switchWidget = _buildSwitch();
    final labelWidget = Expanded(child: _buildLabelContent());
    final validationIcon = _buildValidationIcon();

    switch (widget.labelPosition) {
      case SwitchLabelPosition.start:
        return Row(
          children: [
            labelWidget,
            const SizedBox(width: GasometerDesignTokens.spacingMd),
            validationIcon,
            if (_shouldShowValidationIcon)
              const SizedBox(width: GasometerDesignTokens.spacingSm),
            switchWidget,
          ],
        );
      case SwitchLabelPosition.end:
        return Row(
          children: [
            switchWidget,
            const SizedBox(width: GasometerDesignTokens.spacingMd),
            validationIcon,
            if (_shouldShowValidationIcon)
              const SizedBox(width: GasometerDesignTokens.spacingSm),
            labelWidget,
          ],
        );
      case SwitchLabelPosition.top:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabelContent(),
            const SizedBox(height: GasometerDesignTokens.spacingSm),
            Row(
              children: [
                switchWidget,
                const SizedBox(width: GasometerDesignTokens.spacingMd),
                validationIcon,
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.enabled ? () => _onValueChanged(!widget.value) : null,
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusMd,
          ),
          child: Padding(
            padding: GasometerDesignTokens.paddingAll(
              GasometerDesignTokens.spacingXs,
            ),
            child: _buildSwitchRow(),
          ),
        ),
        if (_displayHelperText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: GasometerDesignTokens.spacingXs,
              left: GasometerDesignTokens.spacingXs,
            ),
            child: Text(
              _displayHelperText!,
              style: TextStyle(
                color:
                    _helperTextColor ??
                    GasometerDesignTokens.colorTextSecondary,
                fontSize: GasometerDesignTokens.fontSizeCaption,
              ),
            ),
          ),
        if (_validationState == SwitchValidationState.validating)
          Padding(
            padding: const EdgeInsets.only(
              top: GasometerDesignTokens.spacingXs,
            ),
            child: LinearProgressIndicator(
              color: GasometerDesignTokens.colorPrimary,
              backgroundColor: GasometerDesignTokens.colorPrimary.withValues(
                alpha: 0.2,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para grupo de switches relacionados
class ValidatedSwitchGroup extends StatefulWidget {
  const ValidatedSwitchGroup({
    super.key,
    required this.items,
    this.title,
    this.subtitle,
    this.allowMultiple = true,
    this.selectedValues,
    this.selectedValue,
    this.onMultipleChanged,
    this.onSingleChanged,
    this.enabled = true,
  });

  /// Lista de switches no grupo
  final List<ValidatedSwitchGroupItem> items;

  /// Título do grupo
  final String? title;

  /// Subtítulo do grupo
  final String? subtitle;

  /// Se permite múltiplas seleções (checkbox style)
  final bool allowMultiple;

  /// Valores selecionados (para allowMultiple = true)
  final Set<String>? selectedValues;

  /// Valor selecionado (para allowMultiple = false)
  final String? selectedValue;

  /// Callback para múltiplas seleções
  final ValueChanged<Set<String>>? onMultipleChanged;

  /// Callback para seleção única
  final ValueChanged<String?>? onSingleChanged;

  /// Se o grupo está habilitado
  final bool enabled;

  @override
  State<ValidatedSwitchGroup> createState() => _ValidatedSwitchGroupState();
}

class _ValidatedSwitchGroupState extends State<ValidatedSwitchGroup> {
  late Set<String> _selectedValues;
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues ?? <String>{};
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(ValidatedSwitchGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValues != widget.selectedValues) {
      _selectedValues = widget.selectedValues ?? <String>{};
    }
    if (oldWidget.selectedValue != widget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  void _onItemChanged(String key, bool value) {
    if (widget.allowMultiple) {
      setState(() {
        if (value) {
          _selectedValues.add(key);
        } else {
          _selectedValues.remove(key);
        }
      });
      widget.onMultipleChanged?.call(_selectedValues);
    } else {
      setState(() {
        _selectedValue = value ? key : null;
      });
      widget.onSingleChanged?.call(_selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: GasometerDesignTokens.spacingXs,
            ),
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontWeight: GasometerDesignTokens.fontWeightMedium,
                color: GasometerDesignTokens.colorTextPrimary,
                fontSize: GasometerDesignTokens.fontSizeBodyLarge,
              ),
            ),
          ),
        if (widget.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: GasometerDesignTokens.spacingSm,
            ),
            child: Text(
              widget.subtitle!,
              style: const TextStyle(
                color: GasometerDesignTokens.colorTextSecondary,
                fontSize: GasometerDesignTokens.fontSizeCaption,
              ),
            ),
          ),
        Column(
          children: widget.items.map((item) {
            final isSelected = widget.allowMultiple
                ? _selectedValues.contains(item.key)
                : _selectedValue == item.key;

            return ValidatedSwitchField(
              value: isSelected,
              onChanged: widget.enabled
                  ? (value) => _onItemChanged(item.key, value)
                  : null,
              label: item.label,
              description: item.description,
              enabled: widget.enabled && item.enabled,
              labelPosition: SwitchLabelPosition.start,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Item para grupo de switches
class ValidatedSwitchGroupItem {
  const ValidatedSwitchGroupItem({
    required this.key,
    required this.label,
    this.description,
    this.enabled = true,
  });

  /// Chave única do item
  final String key;

  /// Label do switch
  final String label;

  /// Descrição opcional
  final String? description;

  /// Se o item está habilitado
  final bool enabled;
}

/// Extension para facilitar o uso de validadores comuns para switches
class CommonSwitchValidators {
  /// Validador para campos obrigatórios (deve estar ativo)
  static String? requiredTrueValidator(bool value) {
    if (!value) {
      return 'Esta opção deve estar ativa';
    }
    return null;
  }

  /// Validador para aceite de termos
  static String? termsValidator(bool value) {
    if (!value) {
      return 'Você deve aceitar os termos e condições';
    }
    return null;
  }

  /// Validador para confirmação de idade
  static String? ageConfirmationValidator(bool value) {
    if (!value) {
      return 'Você deve confirmar que é maior de idade';
    }
    return null;
  }
}
