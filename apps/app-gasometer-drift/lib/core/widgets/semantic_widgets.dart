import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Widget semântico padronizado para cards interativos
/// 
/// Segue WCAG 2.1 guidelines e fornece suporte completo para screen readers
class SemanticCard extends StatelessWidget {
  
  const SemanticCard({
    super.key,
    required this.semanticLabel,
    required this.child,
    this.semanticHint,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.focusable = true,
    this.enabled = true,
  });
  /// Label descritivo para screen readers
  final String semanticLabel;
  
  /// Hint opcional sobre as ações disponíveis
  final String? semanticHint;
  
  /// Widget filho do card
  final Widget child;
  
  /// Callback para toque simples
  final VoidCallback? onTap;
  
  /// Callback para pressão longa
  final VoidCallback? onLongPress;
  
  /// Margem externa do card
  final EdgeInsets? margin;
  
  /// Padding interno do card
  final EdgeInsets? padding;
  
  /// Se deve ser focusável para navegação por teclado
  final bool focusable;
  
  /// Se está habilitado para interação
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = Card(
      margin: margin ?? const EdgeInsets.only(
        bottom: GasometerDesignTokens.spacingMd,
      ),
      child: Container(
        padding: padding ?? GasometerDesignTokens.paddingAll(
          GasometerDesignTokens.spacingLg,
        ),
        child: child,
      ),
    );
    if (onTap == null && onLongPress == null) {
      return Semantics(
        label: semanticLabel,
        hint: semanticHint,
        enabled: enabled,
        readOnly: true,
        child: cardContent,
      );
    }
    return Semantics(
      label: semanticLabel,
      hint: semanticHint ?? _getDefaultHint(),
      enabled: enabled,
      button: true,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: Focus(
        canRequestFocus: focusable && enabled,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          child: cardContent,
        ),
      ),
    );
  }

  String _getDefaultHint() {
    if (onTap != null && onLongPress != null) {
      return 'Toque para ver detalhes, mantenha pressionado para mais opções';
    } else if (onTap != null) {
      return 'Toque para interagir';
    } else if (onLongPress != null) {
      return 'Mantenha pressionado para opções';
    }
    return '';
  }
}

/// Button semântico padronizado com acessibilidade integrada
class SemanticButton extends StatelessWidget {

  const SemanticButton({
    super.key,
    required this.semanticLabel,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.type = ButtonType.elevated,
    this.style,
    this.enabled = true,
  });

  /// Construtor para FloatingActionButton
  const SemanticButton.fab({
    super.key,
    required this.semanticLabel,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.style,
    this.enabled = true,
  }) : type = ButtonType.fab;

  /// Construtor para IconButton
  const SemanticButton.icon({
    super.key,
    required this.semanticLabel,
    required this.child,
    required this.onPressed,
    this.semanticHint,
    this.style,
    this.enabled = true,
  }) : type = ButtonType.icon;
  /// Label descritivo para screen readers
  final String semanticLabel;
  
  /// Hint sobre a ação do botão
  final String? semanticHint;
  
  /// Callback quando pressionado
  final VoidCallback? onPressed;
  
  /// Widget filho (ícone, texto, etc.)
  final Widget child;
  
  /// Tipo de botão (elevated, text, icon, etc.)
  final ButtonType type;
  
  /// Estilo personalizado
  final ButtonStyle? style;
  
  /// Se está habilitado
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    
    Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: child,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: child,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: child,
        );
        break;
      case ButtonType.icon:
        button = IconButton(
          onPressed: effectiveOnPressed,
          style: style,
          icon: child,
        );
        break;
      case ButtonType.fab:
        button = FloatingActionButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint ?? _getDefaultButtonHint(),
      enabled: enabled,
      button: true,
      onTap: effectiveOnPressed,
      excludeSemantics: true,
      child: button,
    );
  }

  String _getDefaultButtonHint() {
    return type == ButtonType.fab 
        ? 'Botão de ação principal'
        : 'Pressione para executar ação';
  }
}

/// Enum para tipos de botão
enum ButtonType {
  elevated,
  text,
  outlined,
  icon,
  fab,
}

/// Text widget semântico com roles apropriados
class SemanticText extends StatelessWidget {

  const SemanticText(
    this.text, {
    super.key,
    this.role = TextRole.body,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Construtor para cabeçalhos
  const SemanticText.heading(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = TextRole.heading;

  /// Construtor para subtítulos
  const SemanticText.subtitle(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = TextRole.subtitle;

  /// Construtor para labels
  const SemanticText.label(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = TextRole.label;
  /// Texto a ser exibido
  final String text;
  
  /// Tipo semântico do texto
  final TextRole role;
  
  /// Estilo do texto
  final TextStyle? style;
  
  /// Alinhamento do texto
  final TextAlign? textAlign;
  
  /// Número máximo de linhas
  final int? maxLines;
  
  /// Comportamento de overflow
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      header: role == TextRole.heading,
      excludeSemantics: true,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Enum para roles de texto
enum TextRole {
  heading,
  subtitle,
  body,
  label,
  caption,
}

/// Widget para formulários semânticos
class SemanticFormField extends StatelessWidget {

  const SemanticFormField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.required = false,
    this.errorText,
  });
  /// Label do campo
  final String label;
  
  /// Hint de ajuda
  final String? hint;
  
  /// Se é obrigatório
  final bool required;
  
  /// Widget do campo
  final Widget child;
  
  /// Mensagem de erro
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = required ? '$label (obrigatório)' : label;
    final semanticHint = [
      if (hint != null) hint!,
      if (errorText != null) 'Erro: $errorText',
    ].join('. ');

    return Semantics(
      label: semanticLabel,
      hint: semanticHint.isNotEmpty ? semanticHint : null,
      textField: true,
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Widget para navegação semântica
class SemanticNavigation extends StatelessWidget {

  const SemanticNavigation({
    super.key,
    required this.navigationLabel,
    required this.children,
    this.isMainNavigation = false,
  });
  /// Label da área de navegação
  final String navigationLabel;
  
  /// Lista de items de navegação
  final List<Widget> children;
  
  /// Se é navegação principal
  final bool isMainNavigation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: navigationLabel,
      container: true,
      explicitChildNodes: true,
      child: Column(
        children: children,
      ),
    );
  }
}

/// Widget para status indicators semânticos
class SemanticStatusIndicator extends StatelessWidget {

  const SemanticStatusIndicator({
    super.key,
    required this.status,
    required this.description,
    required this.child,
    this.isError = false,
    this.isSuccess = false,
  });
  /// Status atual
  final String status;
  
  /// Descrição do status
  final String description;
  
  /// Widget visual do indicator
  final Widget child;
  
  /// Se é um status de erro
  final bool isError;
  
  /// Se é um status de sucesso
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $status',
      hint: description,
      liveRegion: true,
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Mixin para adicionar suporte a acessibilidade em widgets personalizados
mixin SemanticsMixin {
  /// Cria semantics básico para um widget
  Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    bool button = false,
    bool textField = false,
    bool header = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      button: button,
      textField: textField,
      header: header,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Cria um wrapper focusável para navegação por teclado
  Widget withFocus({
    required Widget child,
    bool canRequestFocus = true,
    FocusNode? focusNode,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      canRequestFocus: canRequestFocus,
      focusNode: focusNode,
      onFocusChange: onFocusChange != null 
          ? (bool hasFocus) => onFocusChange()
          : null,
      child: child,
    );
  }
}
