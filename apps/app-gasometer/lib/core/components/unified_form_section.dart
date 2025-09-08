import 'package:flutter/material.dart';

import '../design/unified_design_tokens.dart';

/// Componente para organizar campos de formulário em seções padronizadas
/// 
/// Características:
/// - Header com ícone e título
/// - Suporte a seções expansíveis/colapsáveis
/// - Espaçamento consistente entre campos
/// - Design responsivo
/// - Estados visuais claros
/// - Factory constructors para padrões comuns
class UnifiedFormSection extends StatelessWidget {
  const UnifiedFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.padding,
    this.expanded = true,
    this.onTap,
    this.required = false,
    this.enabled = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool expanded;
  final VoidCallback? onTap;
  final bool required;
  final bool enabled;
  final Color? backgroundColor;
  
  // Factory constructors para padrões comuns
  
  /// Seção básica não colapsável
  static UnifiedFormSection basic({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
    bool required = false,
    bool enabled = true,
  }) {
    return UnifiedFormSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      children: children,
      required: required,
      enabled: enabled,
    );
  }
  
  /// Seção colapsável/expansível
  static UnifiedFormSection collapsible({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
    bool expanded = true,
    required VoidCallback onTap,
    bool required = false,
    bool enabled = true,
  }) {
    return UnifiedFormSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      children: children,
      expanded: expanded,
      onTap: onTap,
      required: required,
      enabled: enabled,
    );
  }
  
  /// Seção com background destacado
  static UnifiedFormSection highlighted({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
    Color? backgroundColor,
    bool required = false,
    bool enabled = true,
  }) {
    return UnifiedFormSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      children: children,
      backgroundColor: backgroundColor,
      required: required,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCollapsible = onTap != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: UnifiedDesignTokens.spacingSection),
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor!.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusLG),
              border: Border.all(
                color: backgroundColor!.withValues(alpha: 0.2),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(context, theme, isCollapsible),
          
          // Section Content
          if (expanded) _buildSectionContent(context, theme),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, ThemeData theme, bool isCollapsible) {
    final headerChild = Padding(
      padding: backgroundColor != null
          ? const EdgeInsets.all(UnifiedDesignTokens.spacingMD)
          : const EdgeInsets.symmetric(vertical: UnifiedDesignTokens.spacingSM),
      child: Row(
        children: [
          // Ícone da seção
          Container(
            padding: const EdgeInsets.all(UnifiedDesignTokens.spacingSM),
            decoration: BoxDecoration(
              color: enabled
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusSM),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              size: 20,
            ),
          ),
          const SizedBox(width: UnifiedDesignTokens.spacingMD),
          
          // Título e subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: UnifiedDesignTokens.fontWeightSemiBold,
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                    children: [
                      if (required)
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
                if (subtitle != null) ...[
                  const SizedBox(height: UnifiedDesignTokens.spacingXS),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Ícone de expansão/colapso
          if (isCollapsible)
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: enabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              size: 24,
            ),
        ],
      ),
    );
    
    if (isCollapsible) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusMD),
          child: headerChild,
        ),
      );
    }
    
    return headerChild;
  }
  
  Widget _buildSectionContent(BuildContext context, ThemeData theme) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final contentPadding = padding ?? EdgeInsets.only(
      left: backgroundColor != null
          ? UnifiedDesignTokens.spacingMD
          : UnifiedDesignTokens.spacingXXXL,
      right: backgroundColor != null
          ? UnifiedDesignTokens.spacingMD
          : 0,
      bottom: backgroundColor != null
          ? UnifiedDesignTokens.spacingMD
          : 0,
    );
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildChildrenWithSpacing(),
        ),
      ),
    );
  }
  
  List<Widget> _buildChildrenWithSpacing() {
    if (children.isEmpty) return [];
    
    final spacedChildren = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      
      // Adicionar espaçamento entre os children (exceto o último)
      if (i < children.length - 1) {
        spacedChildren.add(
          const SizedBox(height: UnifiedDesignTokens.spacingFormField),
        );
      }
    }
    
    return spacedChildren;
  }
}

/// Widget para criar separadores entre seções
class UnifiedFormSectionDivider extends StatelessWidget {
  const UnifiedFormSectionDivider({
    super.key,
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  });

  final double? height;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: UnifiedDesignTokens.spacingLG),
      child: Divider(
        height: height ?? 1,
        thickness: thickness ?? 1,
        color: color ?? theme.colorScheme.outline.withValues(alpha: 0.2),
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}

/// Extension para facilitar o uso de UnifiedFormSection
extension UnifiedFormSectionExtension on List<Widget> {
  /// Converte uma lista de widgets em seções de formulário com espaçamento automático
  List<Widget> toUnifiedSections() {
    if (isEmpty) return [];
    
    final sections = <Widget>[];
    
    for (int i = 0; i < length; i++) {
      sections.add(this[i]);
      
      // Adicionar espaçamento entre seções (exceto a última)
      if (i < length - 1 && this[i] is UnifiedFormSection) {
        sections.add(const SizedBox(height: UnifiedDesignTokens.spacingSection));
      }
    }
    
    return sections;
  }
}