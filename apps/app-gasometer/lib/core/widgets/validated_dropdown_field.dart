import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Estados de validação para feedback visual
enum DropdownValidationState {
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

/// Tipo de função de validação assíncrona para dropdown
typedef DropdownAsyncValidator<T> = Future<String?> Function(T? value);

/// Item de dropdown padronizado
class ValidatedDropdownItem<T> {

  const ValidatedDropdownItem({
    required this.value,
    required this.child,
    this.enabled = true,
    this.searchText,
  });
  
  /// Factory para criar item simples com texto
  factory ValidatedDropdownItem.text(T value, String text) {
    return ValidatedDropdownItem<T>(
      value: value,
      child: Text(text),
      searchText: text,
    );
  }
  /// Valor do item
  final T value;
  
  /// Widget que representa o item visualmente
  final Widget child;
  
  /// Se o item está habilitado para seleção
  final bool enabled;
  
  /// Texto para busca (opcional - se não fornecido, extrairá do child)
  final String? searchText;
}

/// Dropdown com validação em tempo real e feedback visual padronizado
/// 
/// Segue os mesmos padrões visuais e de validação do ValidatedTextField,
/// garantindo consistência na experiência do usuário.
class ValidatedDropdownField<T> extends StatefulWidget {

  const ValidatedDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.required = false,
    this.maxHeight = 300,
    this.searchable = false,
    this.validator,
    this.asyncValidator,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.validateOnChange = true,
    this.showValidationIcon = true,
    this.onEditingComplete,
    this.decoration,
  });
  /// Lista de itens disponíveis
  final List<ValidatedDropdownItem<T>> items;
  
  /// Valor selecionado atualmente
  final T? value;
  
  /// Callback quando o valor é alterado
  final ValueChanged<T?>? onChanged;
  
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
  
  /// Altura máxima do dropdown
  final double? maxHeight;
  
  /// Se permite busca nos itens
  final bool searchable;
  
  // Validação
  /// Validador síncrono
  final String? Function(T?)? validator;
  
  /// Validador assíncrono
  final DropdownAsyncValidator<T>? asyncValidator;
  
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

  @override
  State<ValidatedDropdownField<T>> createState() => _ValidatedDropdownFieldState<T>();
}

class _ValidatedDropdownFieldState<T> extends State<ValidatedDropdownField<T>>
    with SingleTickerProviderStateMixin {
  
  DropdownValidationState _validationState = DropdownValidationState.initial;
  String? _errorMessage;
  Timer? _debounceTimer;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  
  // Overlay controls
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isExpanded = false;
  
  // Search controls
  final TextEditingController _searchController = TextEditingController();
  List<ValidatedDropdownItem<T>> _filteredItems = [];

  bool get _shouldShowValidationIcon =>
      widget.showValidationIcon &&
      _validationState != DropdownValidationState.initial &&
      widget.value != null;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    
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
  void didUpdateWidget(ValidatedDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
    if (oldWidget.value != widget.value && widget.validateOnChange) {
      _validateValue(widget.value);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _iconAnimationController.dispose();
    _closeDropdown();
    _searchController.dispose();
    super.dispose();
  }

  void _onValueChanged(T? value) {
    widget.onChanged?.call(value);
    
    if (widget.validateOnChange) {
      // Cancelar timer anterior se existir
      _debounceTimer?.cancel();
      
      if (value == null) {
        setState(() {
          _validationState = DropdownValidationState.initial;
          _errorMessage = null;
        });
        return;
      }
      
      // Mostrar estado de validação
      setState(() {
        _validationState = DropdownValidationState.validating;
        _errorMessage = null;
      });
      
      // Configurar debounce
      _debounceTimer = Timer(widget.debounceDuration, () {
        _validateValue(value);
      });
    }
  }

  Future<void> _validateValue(T? value) async {
    if (!mounted) return;
    
    try {
      String? error;
      
      // Validação obrigatória para campos required
      if (widget.required && value == null) {
        error = 'Este campo é obrigatório';
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
          _validationState = DropdownValidationState.invalid;
          _errorMessage = error;
        } else {
          _validationState = DropdownValidationState.valid;
          _errorMessage = null;
        }
      });
      
      // Animar ícone
      await _iconAnimationController.forward();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _validationState = DropdownValidationState.error;
        _errorMessage = 'Erro na validação: $e';
      });
    }
  }

  /// Força validação imediata (útil para validação no submit)
  Future<bool> validate() async {
    await _validateValue(widget.value);
    return _validationState == DropdownValidationState.valid;
  }

  Widget _buildValidationIcon() {
    if (!_shouldShowValidationIcon) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color iconColor;

    switch (_validationState) {
      case DropdownValidationState.validating:
        return const SizedBox(
          width: GasometerDesignTokens.iconSizeXs,
          height: GasometerDesignTokens.iconSizeXs,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GasometerDesignTokens.colorPrimary,
          ),
        );
      case DropdownValidationState.valid:
        iconData = Icons.check_circle;
        iconColor = GasometerDesignTokens.colorSuccess;
        break;
      case DropdownValidationState.invalid:
      case DropdownValidationState.error:
        iconData = Icons.error;
        iconColor = GasometerDesignTokens.colorError;
        break;
      case DropdownValidationState.initial:
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
      case DropdownValidationState.valid:
        return GasometerDesignTokens.colorSuccess;
      case DropdownValidationState.invalid:
      case DropdownValidationState.error:
        return GasometerDesignTokens.colorError;
      case DropdownValidationState.validating:
        return GasometerDesignTokens.colorPrimary;
      case DropdownValidationState.initial:
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
      case DropdownValidationState.invalid:
      case DropdownValidationState.error:
        return GasometerDesignTokens.colorError;
      case DropdownValidationState.valid:
        return GasometerDesignTokens.colorSuccess;
      default:
        return null;
    }
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled || widget.items.isEmpty) return;
    
    setState(() {
      _isExpanded = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isExpanded) return;
    
    setState(() {
      _isExpanded = false;
    });

    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredItems = widget.items;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + GasometerDesignTokens.spacingXs),
          child: Material(
            elevation: GasometerDesignTokens.elevationDialog,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusLg),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight!,
              ),
              decoration: BoxDecoration(
                color: GasometerDesignTokens.colorSurface,
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusLg),
                border: Border.all(
                  color: GasometerDesignTokens.colorNeutral200,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.searchable) _buildSearchField(),
                  Flexible(
                    child: _buildItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: const Icon(Icons.search, size: GasometerDesignTokens.iconSizeSm),
          contentPadding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingSm),
          border: OutlineInputBorder(
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
            borderSide: const BorderSide(
              color: GasometerDesignTokens.colorNeutral300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusMd),
            borderSide: const BorderSide(
              color: GasometerDesignTokens.colorPrimary,
            ),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildItemsList() {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXxl),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: GasometerDesignTokens.iconSizeXl,
              color: GasometerDesignTokens.colorNeutral400,
            ),
            SizedBox(height: GasometerDesignTokens.spacingSm),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(
                color: GasometerDesignTokens.colorTextSecondary,
                fontSize: GasometerDesignTokens.fontSizeBody,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingXs),
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = item.value == widget.value;

        return InkWell(
          onTap: item.enabled ? () {
            _onValueChanged(item.value);
            _closeDropdown();
          } : null,
          child: Container(
            padding: GasometerDesignTokens.paddingHorizontal(GasometerDesignTokens.spacingLg)
                .add(GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingMd)),
            decoration: BoxDecoration(
              color: isSelected
                  ? GasometerDesignTokens.colorPrimary.withValues(alpha: 0.1)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: !item.enabled
                          ? GasometerDesignTokens.colorTextSecondary
                          : isSelected
                              ? GasometerDesignTokens.colorPrimary
                              : GasometerDesignTokens.colorTextPrimary,
                      fontWeight: isSelected 
                          ? GasometerDesignTokens.fontWeightMedium 
                          : GasometerDesignTokens.fontWeightRegular,
                      fontSize: GasometerDesignTokens.fontSizeBody,
                    ),
                    child: item.child,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    size: GasometerDesignTokens.iconSizeSm,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {});
    
    if (query.isEmpty) {
      _filteredItems = widget.items;
    } else {
      _filteredItems = widget.items.where((item) {
        final searchText = item.searchText ?? _extractTextFromWidget(item.child);
        return searchText.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    
    // Update overlay
    _overlayEntry?.markNeedsBuild();
  }

  String _extractTextFromWidget(Widget widget) {
    if (widget is Text) {
      return widget.data ?? '';
    } else if (widget is RichText) {
      return widget.text.toPlainText();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    final selectedItem = widget.value != null 
        ? widget.items.where((item) => item.value == widget.value).firstOrNull
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: GasometerDesignTokens.spacingSm),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                  color: GasometerDesignTokens.colorTextPrimary,
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
          ),
        
        // Campo dropdown
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: widget.enabled ? _toggleDropdown : null,
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
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      color: widget.enabled
                          ? GasometerDesignTokens.colorTextSecondary
                          : GasometerDesignTokens.colorNeutral400,
                      size: GasometerDesignTokens.iconSizeSm,
                    ),
                    const SizedBox(width: GasometerDesignTokens.spacingMd),
                  ],
                  Expanded(
                    child: selectedItem != null
                        ? DefaultTextStyle(
                            style: TextStyle(
                              color: widget.enabled
                                  ? GasometerDesignTokens.colorTextPrimary
                                  : GasometerDesignTokens.colorTextSecondary,
                              fontSize: GasometerDesignTokens.fontSizeBody,
                            ),
                            child: selectedItem.child,
                          )
                        : Text(
                            widget.hint ?? 'Selecione uma opção',
                            style: const TextStyle(
                              color: GasometerDesignTokens.colorTextSecondary,
                              fontSize: GasometerDesignTokens.fontSizeBody,
                            ),
                          ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildValidationIcon(),
                      if (widget.suffix != null) ...[
                        const SizedBox(width: GasometerDesignTokens.spacingSm),
                        widget.suffix!,
                      ],
                      const SizedBox(width: GasometerDesignTokens.spacingSm),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
        ),
        
        // Helper text
        if (_displayHelperText != null)
          Padding(
            padding: const EdgeInsets.only(
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
        if (_validationState == DropdownValidationState.validating)
          Padding(
            padding: const EdgeInsets.only(top: GasometerDesignTokens.spacingXs),
            child: LinearProgressIndicator(
              color: GasometerDesignTokens.colorPrimary,
              backgroundColor: GasometerDesignTokens.colorPrimary.withValues(alpha: 0.2),
            ),
          ),
      ],
    );
  }
}

/// Extension para facilitar o uso de validadores comuns para dropdown
class CommonDropdownValidators {
  /// Validador para campos obrigatórios
  static String? requiredValidator<T>(T? value) {
    if (value == null) {
      return 'Este campo é obrigatório';
    }
    return null;
  }
  
  /// Validador para garantir que está na lista de valores válidos
  static String? Function(T?) inListValidator<T>(List<T> validValues) {
    return (T? value) {
      if (value == null) return null;
      
      if (!validValues.contains(value)) {
        return 'Valor inválido selecionado';
      }
      return null;
    };
  }
}