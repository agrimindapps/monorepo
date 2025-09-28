import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/unified_design_tokens.dart';
import '../services/unified_formatters.dart';
import '../services/unified_validators.dart';

/// Componente de formulário unificado que substitui todos os outros campos
/// 
/// Características:
/// - Validação em tempo real com debounce
/// - Formatação automática baseada no tipo
/// - Design consistente usando UnifiedDesignTokens
/// - Estados visuais claros (loading, success, warning, error)
/// - Suporte responsivo
/// - Rate limiting integrado
class UnifiedFormField extends StatefulWidget {
  const UnifiedFormField({
    super.key,
    required this.label,
    required this.validationType,
    this.hint,
    this.controller,
    this.required = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.validationContext,
    this.onValidationChanged,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String? hint;
  final UnifiedValidationType validationType;
  final TextEditingController? controller;
  final bool required;
  final Duration debounceDuration;
  final Map<String, dynamic>? validationContext;
  final ValueChanged<UnifiedValidationResult>? onValidationChanged;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<UnifiedFormField> createState() => _UnifiedFormFieldState();
}

class _UnifiedFormFieldState extends State<UnifiedFormField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  UnifiedValidationResult _validationResult = UnifiedValidationResult.initial();
  Timer? _debounceTimer;
  
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // Configurar animação para ícones de validação
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
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
    
    // Cancelar timer anterior se existir
    _debounceTimer?.cancel();
    
    // Se campo vazio e não obrigatório, resetar validação
    if (text.isEmpty && !widget.required) {
      setState(() {
        _validationResult = UnifiedValidationResult.initial();
      });
      widget.onValidationChanged?.call(_validationResult);
      return;
    }
    
    // Mostrar estado de validação em progresso
    setState(() {
      _validationResult = UnifiedValidationResult.validating();
    });
    
    // Configurar debounce para validação
    _debounceTimer = Timer(widget.debounceDuration, () {
      _performValidation(text);
    });
  }

  Future<void> _performValidation(String text) async {
    if (!mounted) return;
    
    try {
      final validator = UnifiedValidators.getValidator(
        widget.validationType,
        context: widget.validationContext,
      );
      
      final result = validator.validate(text, required: widget.required);
      
      if (!mounted) return;
      
      setState(() {
        _validationResult = result;
      });
      
      // Notificar mudança de validação
      widget.onValidationChanged?.call(result);
      
      // Animar ícone se houver mudança de estado
      if (result.status != ValidationStatus.initial && 
          result.status != ValidationStatus.validating) {
        _iconAnimationController.forward();
      }
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validationResult = UnifiedValidationResult.error('Erro na validação: $e');
      });
      
      widget.onValidationChanged?.call(_validationResult);
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<UnifiedValidationResult> validate() async {
    final text = _controller.text;
    await _performValidation(text);
    return _validationResult;
  }

  /// Limpa validação
  void clearValidation() {
    setState(() {
      _validationResult = UnifiedValidationResult.initial();
    });
    widget.onValidationChanged?.call(_validationResult);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with Required Indicator
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: UnifiedDesignTokens.spacingSM,
            ),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: UnifiedDesignTokens.fontWeightMedium,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: UnifiedDesignTokens.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        
        // Input Field
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType ?? _getKeyboardType(),
          inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: widget.enabled 
                ? theme.colorScheme.surface
                : UnifiedDesignTokens.colorSurfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UnifiedDesignTokens.spacingLG,
              vertical: UnifiedDesignTokens.spacingMD,
            ),
          ),
          // Não usar validação nativa do FormField - usar nosso sistema
          validator: null,
        ),
        
        // Validation Message
        if (_validationResult.message != null)
          Padding(
            padding: const EdgeInsets.only(
              top: UnifiedDesignTokens.spacingSM,
              left: UnifiedDesignTokens.spacingMD,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getValidationIcon(),
                  size: 16,
                  color: _getValidationColor(),
                ),
                const SizedBox(width: UnifiedDesignTokens.spacingSM),
                Expanded(
                  child: Text(
                    _validationResult.message!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getValidationColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      // Se há um suffixIcon customizado, combinar com o ícone de validação
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildValidationIcon(),
          const SizedBox(width: UnifiedDesignTokens.spacingSM),
          widget.suffixIcon!,
          const SizedBox(width: UnifiedDesignTokens.spacingSM),
        ],
      );
    }
    
    return _buildValidationIcon();
  }
  
  Widget _buildValidationIcon() {
    if (_validationResult.status == ValidationStatus.initial) {
      return const SizedBox.shrink();
    }
    
    switch (_validationResult.status) {
      case ValidationStatus.validating:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              UnifiedDesignTokens.colorInfo,
            ),
          ),
        );
      case ValidationStatus.valid:
        return FadeTransition(
          opacity: _iconAnimation,
          child: const Icon(
            Icons.check_circle,
            color: UnifiedDesignTokens.colorSuccess,
            size: 20,
          ),
        );
      case ValidationStatus.warning:
        return FadeTransition(
          opacity: _iconAnimation,
          child: const Icon(
            Icons.warning,
            color: UnifiedDesignTokens.colorWarning,
            size: 20,
          ),
        );
      case ValidationStatus.error:
        return FadeTransition(
          opacity: _iconAnimation,
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Color _getBorderColor() {
    final theme = Theme.of(context);
    
    if (!widget.enabled) {
      return theme.colorScheme.outline.withValues(alpha: 0.5);
    }
    
    switch (_validationResult.status) {
      case ValidationStatus.valid:
        return UnifiedDesignTokens.colorSuccess;
      case ValidationStatus.warning:
        return UnifiedDesignTokens.colorWarning;
      case ValidationStatus.error:
        return theme.colorScheme.error;
      case ValidationStatus.validating:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.outline;
    }
  }
  
  Color _getValidationColor() {
    final theme = Theme.of(context);
    switch (_validationResult.status) {
      case ValidationStatus.valid:
        return UnifiedDesignTokens.colorSuccess;
      case ValidationStatus.warning:
        return UnifiedDesignTokens.colorWarning;
      case ValidationStatus.error:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
  
  IconData _getValidationIcon() {
    switch (_validationResult.status) {
      case ValidationStatus.valid:
        return Icons.check_circle;
      case ValidationStatus.warning:
        return Icons.warning;
      case ValidationStatus.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }
  
  TextInputType _getKeyboardType() {
    switch (widget.validationType) {
      case UnifiedValidationType.email:
        return TextInputType.emailAddress;
      case UnifiedValidationType.number:
      case UnifiedValidationType.decimal:
      case UnifiedValidationType.currency:
      case UnifiedValidationType.odometer:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
  
  List<TextInputFormatter> _getInputFormatters() {
    return UnifiedFormatters.getFormatters(widget.validationType);
  }
}