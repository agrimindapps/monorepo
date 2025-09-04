import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Design tokens específicos para acessibilidade seguindo WCAG 2.1
class AccessibilityTokens {
  AccessibilityTokens._();

  // WCAG Contrast Ratios
  static const double _normalTextContrast = 4.5;
  static const double _largeTextContrast = 3.0;

  // Touch Target Sizes (Material Design + WCAG)
  static const double minTouchTargetSize = 44.0;
  static const double recommendedTouchTargetSize = 48.0;
  static const double largeTouchTargetSize = 56.0;

  // Spacing for touch targets
  static const double minTouchSpacing = 8.0;
  static const double recommendedTouchSpacing = 16.0;

  // Font Sizes (scaled for accessibility)
  static const double minReadableTextSize = 16.0;
  static const double largeTextThreshold = 18.0;
  static const double maxScaleFactor = 3.0;

  // Animation Durations (respecting reduced motion)
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration noAnimation = Duration.zero;

  // Focus Management
  static const double focusStrokeWidth = 2.0;
  static const Color focusColor = Colors.blue;
  static const double focusBorderRadius = 4.0;

  // Semantic Labels (Portuguese)
  static const Map<String, String> semanticLabels = {
    // Navigation
    'back_button': 'Voltar para a tela anterior',
    'menu_button': 'Abrir menu de navegação',
    'close_button': 'Fechar',
    'next_button': 'Próximo',
    'previous_button': 'Anterior',
    
    // Actions
    'save_button': 'Salvar alterações',
    'delete_button': 'Excluir item',
    'edit_button': 'Editar',
    'complete_button': 'Marcar como concluído',
    'add_button': 'Adicionar novo item',
    'refresh_button': 'Atualizar conteúdo',
    
    // Forms
    'required_field': 'Campo obrigatório',
    'optional_field': 'Campo opcional',
    'password_field': 'Campo de senha',
    'email_field': 'Campo de e-mail',
    'search_field': 'Campo de pesquisa',
    'show_password': 'Mostrar senha',
    'hide_password': 'Ocultar senha',
    
    // Loading states
    'loading': 'Carregando conteúdo',
    'refreshing': 'Atualizando conteúdo',
    'processing': 'Processando solicitação',
    
    // Content
    'image': 'Imagem',
    'plant_image': 'Foto da planta',
    'profile_image': 'Foto do perfil',
    'empty_list': 'Lista vazia',
    
    // Plants specific
    'plant_card': 'Cartão da planta',
    'task_card': 'Cartão de tarefa',
    'watering_task': 'Tarefa de rega',
    'fertilizing_task': 'Tarefa de adubação',
    'pruning_task': 'Tarefa de poda',
    'care_reminder': 'Lembrete de cuidado',
  };

  // Screen Reader Announcements
  static const Map<String, String> announcements = {
    'task_completed': 'Tarefa marcada como concluída',
    'plant_added': 'Nova planta adicionada',
    'login_success': 'Login realizado com sucesso',
    'logout_success': 'Logout realizado com sucesso',
    'error_occurred': 'Ocorreu um erro',
    'network_error': 'Erro de conexão com a internet',
    'validation_error': 'Por favor, corrija os campos com erro',
  };

  // Haptic Feedback Patterns
  static const Map<String, String> hapticPatterns = {
    'light': 'light',
    'medium': 'medium',
    'heavy': 'heavy',
    'selection': 'selection',
    'vibrate': 'vibrate',
  };

  /// Calcula se um contraste é adequado para WCAG
  static bool isContrastCompliant(Color foreground, Color background, {bool isLargeText = false}) {
    final contrast = _calculateContrast(foreground, background);
    final requiredContrast = isLargeText ? _largeTextContrast : _normalTextContrast;
    return contrast >= requiredContrast;
  }

  /// Calcula a razão de contraste entre duas cores
  static double _calculateContrast(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lightest + 0.05) / (darkest + 0.05);
  }

  /// Retorna uma cor com contraste adequado para o background
  static Color getAccessibleColor(Color color, Color background, {bool isLargeText = false}) {
    if (isContrastCompliant(color, background, isLargeText: isLargeText)) {
      return color;
    }

    // Se o contraste não é adequado, retorna preto ou branco baseado no background
    final backgroundLuminance = background.computeLuminance();
    return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Retorna o tamanho de fonte baseado nas configurações de acessibilidade
  static double getAccessibleFontSize(BuildContext context, double baseFontSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(1.0);
    final scaledSize = baseFontSize * textScaleFactor;
    
    // Garante um tamanho mínimo legível
    const minSize = minReadableTextSize;
    final maxSize = baseFontSize * maxScaleFactor;
    
    return scaledSize.clamp(minSize, maxSize);
  }

  /// Retorna duração de animação baseada nas preferências do usuário
  static Duration getAccessibleAnimationDuration(BuildContext context, Duration baseDuration) {
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion = mediaQuery.disableAnimations;
    
    return reduceMotion ? noAnimation : baseDuration;
  }

  /// Executa feedback háptico se habilitado
  static void performHapticFeedback(String pattern) {
    switch (pattern) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
      case 'vibrate':
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Anuncia texto para screen readers
  static void announceForAccessibility(BuildContext context, String message) {
    final announcement = announcements[message] ?? message;
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  /// Retorna label semântica traduzida
  static String getSemanticLabel(String key, [String? fallback]) {
    return semanticLabels[key] ?? fallback ?? key;
  }
}

/// Extension para facilitar uso de acessibilidade em Widgets
extension AccessibilityExtension on Widget {
  /// Adiciona semântica básica ao widget
  Widget withAccessibility({
    String? label,
    String? hint,
    bool? button,
    bool? enabled,
    VoidCallback? onTap,
    bool focusable = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      enabled: enabled,
      onTap: onTap,
      focusable: focusable,
      child: this,
    );
  }

  /// Adiciona focus management ao widget
  Widget withFocus({
    FocusNode? focusNode,
    bool autofocus = false,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange != null ? (hasFocus) {
        if (hasFocus) onFocusChange();
      } : null,
      child: this,
    );
  }

  /// Adiciona touch target mínimo ao widget
  Widget withMinimumTouchTarget({double? minSize}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize ?? AccessibilityTokens.minTouchTargetSize,
        minHeight: minSize ?? AccessibilityTokens.minTouchTargetSize,
      ),
      child: this,
    );
  }
}

/// Mixin para gerenciar focus nodes em StatefulWidgets
mixin AccessibilityFocusMixin<T extends StatefulWidget> on State<T> {
  final Map<String, FocusNode> _focusNodes = {};

  FocusNode getFocusNode(String key) {
    return _focusNodes.putIfAbsent(key, () => FocusNode(
      debugLabel: key,
      canRequestFocus: true,
      descendantsAreFocusable: true,
      descendantsAreTraversable: true,
    ));
  }

  void requestFocus(String key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Critical: Multiple mounted checks to prevent race conditions
      if (mounted) {
        final node = _focusNodes[key];
        if (node != null && mounted && node.canRequestFocus) {
          try {
            node.requestFocus();
          } catch (e) {
            // Silently handle focus errors in web environment
          }
        }
      }
    });
  }

  void unfocus(String key) {
    if (mounted) {
      final node = _focusNodes[key];
      if (node != null && mounted && node.hasFocus) {
        try {
          node.unfocus();
        } catch (e) {
          // Silently handle unfocus errors in web environment
        }
      }
    }
  }

  void nextFocus(String currentKey, String nextKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Critical: Enhanced mounted checks for focus traversal
      if (mounted) {
        final nextNode = _focusNodes[nextKey];
        if (nextNode != null && mounted && nextNode.canRequestFocus) {
          try {
            nextNode.requestFocus();
          } catch (e) {
            // Silently handle focus traversal errors in web environment
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Critical: Safe disposal of focus nodes to prevent race conditions
    for (final node in _focusNodes.values) {
      try {
        if (node.hasFocus) {
          node.unfocus();
        }
        node.dispose();
      } catch (e) {
        // Silently handle disposal errors
      }
    }
    _focusNodes.clear();
    super.dispose();
  }
}

/// Helper para criar botões acessíveis
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.focusNode,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumSize,
    this.padding,
    this.shape,
    this.hapticPattern = 'light',
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;
  final String hapticPattern;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? semanticLabel ?? '',
      child: ElevatedButton(
        onPressed: onPressed == null ? null : () {
          AccessibilityTokens.performHapticFeedback(hapticPattern);
          onPressed!();
        },
        focusNode: focusNode,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: minimumSize ?? 
              const Size(AccessibilityTokens.minTouchTargetSize, AccessibilityTokens.minTouchTargetSize),
          padding: padding,
          shape: shape,
        ),
        child: Semantics(
          label: semanticLabel,
          button: true,
          enabled: onPressed != null,
          child: child,
        ),
      ),
    );
  }
}

/// Helper para campos de texto acessíveis
class AccessibleTextField extends StatelessWidget {
  const AccessibleTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.nextFocusNode,
    required this.labelText,
    this.hintText,
    this.semanticLabel,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String labelText;
  final String? hintText;
  final String? semanticLabel;
  final bool isRequired;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? 
        '$labelText${isRequired ? ', campo obrigatório' : ', campo opcional'}';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          label: effectiveLabel,
          textField: true,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? 
                (nextFocusNode != null ? TextInputAction.next : TextInputAction.done),
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: (value) {
              if (nextFocusNode != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  nextFocusNode!.requestFocus();
                });
              } else {
                focusNode?.unfocus();
              }
              onSubmitted?.call(value);
            },
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
            ),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}