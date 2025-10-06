import 'package:flutter/material.dart';

import 'diagnostico_mockup_tokens.dart';

/// Widget que replica EXATAMENTE o design da seção de cultura do mockup IMG_3186.PNG
/// 
/// Layout do mockup analisado:
/// - Container com background cinza claro
/// - Ícone verde de folha (🌿)
/// - Texto "Cultura (X diagnóstico/s)" em negrito
/// - Padding e margins específicos
/// 
/// Responsabilidade única: renderizar cabeçalho de agrupamento por cultura
class CulturaSectionMockupWidget extends StatelessWidget {
  final String cultura;
  final int diagnosticoCount;

  const CulturaSectionMockupWidget({
    super.key,
    required this.cultura,
    required this.diagnosticoCount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: DiagnosticoMockupTokens.sectionMargin,
        padding: DiagnosticoMockupTokens.sectionPadding,
        decoration: BoxDecoration(
          color: DiagnosticoMockupTokens.sectionBackground,
          borderRadius: BorderRadius.circular(
            DiagnosticoMockupTokens.sectionBorderRadius,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _buildText()),
          ],
        ),
      ),
    );
  }


  /// Texto da cultura com contador
  Widget _buildText() {
    final diagnosticoText = diagnosticoCount == 1 
        ? '1 diagnóstico'
        : '$diagnosticoCount diagnósticos';
    
    return Text(
      '$cultura ($diagnosticoText)',
      style: DiagnosticoMockupTokens.sectionTitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Widget expandido com funcionalidades adicionais para seção de cultura
class CulturaSectionMockupExpanded extends StatelessWidget {
  final String cultura;
  final int diagnosticoCount;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isCollapsible;
  final bool isExpanded;

  const CulturaSectionMockupExpanded({
    super.key,
    required this.cultura,
    required this.diagnosticoCount,
    this.onTap,
    this.trailing,
    this.isCollapsible = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      width: double.infinity,
      margin: DiagnosticoMockupTokens.sectionMargin,
      padding: DiagnosticoMockupTokens.sectionPadding,
      decoration: BoxDecoration(
        color: DiagnosticoMockupTokens.sectionBackground,
        borderRadius: BorderRadius.circular(
          DiagnosticoMockupTokens.sectionBorderRadius,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildText()),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (isCollapsible) ...[
            const SizedBox(width: 8),
            _buildCollapseIcon(),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return RepaintBoundary(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              DiagnosticoMockupTokens.sectionBorderRadius,
            ),
            child: child,
          ),
        ),
      );
    }

    return RepaintBoundary(child: child);
  }


  /// Texto da cultura com contador
  Widget _buildText() {
    final diagnosticoText = diagnosticoCount == 1 
        ? '1 diagnóstico'
        : '$diagnosticoCount diagnósticos';
    
    return Text(
      '$cultura ($diagnosticoText)',
      style: DiagnosticoMockupTokens.sectionTitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Ícone de colapsar/expandir (se aplicável)
  Widget _buildCollapseIcon() {
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0,
      duration: DiagnosticoMockupTokens.filterAnimationDuration,
      child: const Icon(
        Icons.keyboard_arrow_down,
        color: DiagnosticoMockupTokens.textSecondary,
        size: 20,
      ),
    );
  }
}

/// Factory para criar diferentes tipos de seção de cultura
class CulturaSectionMockupFactory {
  /// Cria seção básica como no mockup original
  static Widget basic({
    required String cultura,
    required int diagnosticoCount,
  }) {
    return CulturaSectionMockupWidget(
      cultura: cultura,
      diagnosticoCount: diagnosticoCount,
    );
  }

  /// Cria seção clicável
  static Widget clickable({
    required String cultura,
    required int diagnosticoCount,
    required VoidCallback onTap,
  }) {
    return CulturaSectionMockupExpanded(
      cultura: cultura,
      diagnosticoCount: diagnosticoCount,
      onTap: onTap,
    );
  }

  /// Cria seção colapsável
  static Widget collapsible({
    required String cultura,
    required int diagnosticoCount,
    required VoidCallback onTap,
    required bool isExpanded,
  }) {
    return CulturaSectionMockupExpanded(
      cultura: cultura,
      diagnosticoCount: diagnosticoCount,
      onTap: onTap,
      isCollapsible: true,
      isExpanded: isExpanded,
    );
  }

  /// Cria seção com widget customizado à direita
  static Widget withTrailing({
    required String cultura,
    required int diagnosticoCount,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return CulturaSectionMockupExpanded(
      cultura: cultura,
      diagnosticoCount: diagnosticoCount,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
