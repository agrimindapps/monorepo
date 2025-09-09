import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/spacing_tokens.dart';
import '../providers/detalhe_defensivo_provider.dart';
import '../providers/diagnosticos_provider_legacy.dart';
import 'diagnosticos_defensivos_components.dart';

/// Widget principal responsável por exibir diagnósticos relacionados ao defensivo
/// 
/// Responsabilidade única: orquestrar componentes para exibir diagnósticos
/// - Filtros de pesquisa e cultura
/// - Lista agrupada de diagnósticos
/// - Estados de loading, erro e vazio
/// - Modal de detalhes do diagnóstico
/// 
/// **Arquitetura Decomposta:**
/// - `DiagnosticoDefensivoFilterWidget`: Filtros de pesquisa
/// - `DiagnosticoDefensivoStateManager`: Gerenciamento de estados
/// - `DiagnosticoDefensivoListItemWidget`: Itens da lista
/// - `DiagnosticoDefensivoDialogWidget`: Modal de detalhes
/// 
/// **Performance Otimizada:**
/// - RepaintBoundary para evitar rebuilds desnecessários
/// - Componentes reutilizáveis e modulares
/// - Estados gerenciados de forma eficiente
class DiagnosticosTabWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Área de filtros
          const DiagnosticoDefensivoFilterWidget(),
          // Lista de diagnósticos com gerenciamento de estados
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: SpacingTokens.xs,
                bottom: SpacingTokens.bottomNavSpace, // Espaço para bottom nav
              ),
              child: DiagnosticoDefensivoStateManager(
                defensivoName: defensivoName,
                builder: _buildDiagnosticsList,
                onRetry: () => _retryLoadDiagnostics(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(BuildContext context) {
    // Implementação depende de como o provider é inicializado
    // Por enquanto, limpa o erro para permitir nova tentativa
    final diagnosticosProvider = Provider.of<DiagnosticosProvider>(context, listen: false);
    final defensivoProvider = Provider.of<DetalheDefensivoProvider>(context, listen: false);
    
    final idReg = defensivoProvider.defensivoData?.idReg;
    if (idReg != null) {
      diagnosticosProvider.loadDiagnosticos(idReg);
    }
  }

  /// Constrói lista de diagnósticos agrupados por cultura
  Widget _buildDiagnosticsList(List<dynamic> diagnosticos) {
    final groupedDiagnostics = _groupDiagnosticsByCulture(diagnosticos);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildGroupedWidgets(groupedDiagnostics),
    );
  }
  
  /// Agrupa diagnósticos por cultura
  Map<String, List<dynamic>> _groupDiagnosticsByCulture(
    List<dynamic> diagnosticos,
  ) {
    final grouped = <String, List<dynamic>>{};
    
    for (final diagnostic in diagnosticos) {
      String cultura;
      try {
        final nomeCultura = diagnostic.nomeCultura;
        final culturaProp = diagnostic.cultura;
        cultura = (nomeCultura?.toString() ?? culturaProp?.toString() ?? 'Não especificado');
      } catch (e) {
        cultura = 'Não especificado';
      }
      grouped.putIfAbsent(cultura, () => []).add(diagnostic);
    }
    
    return grouped;
  }
  
  /// Constrói widgets agrupados por cultura
  List<Widget> _buildGroupedWidgets(
    Map<String, List<dynamic>> groupedDiagnostics,
  ) {
    final List<Widget> widgets = [];

    groupedDiagnostics.forEach((cultura, diagnostics) {
      // Seção de cultura
      widgets.add(
        DiagnosticoDefensivoCultureSectionWidget(
          cultura: cultura,
          diagnosticCount: diagnostics.length,
        ),
      );
      widgets.add(SpacingTokens.gapLG);

      // Itens de diagnósticos
      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(
          Builder(
            builder: (context) => DiagnosticoDefensivoListItemWidget(
              diagnostico: diagnostic,
              onTap: () => _showDiagnosticoDialog(context, diagnostic),
            ),
          ),
        );
        if (i < diagnostics.length - 1) {
          widgets.add(SpacingTokens.gapMD);
        }
      }
      widgets.add(SpacingTokens.gapXL);
    });

    // Espaço já incluído no scrollPadding
    return widgets;
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, dynamic diagnostico) {
    DiagnosticoDefensivoDialogWidget.show(context, diagnostico, defensivoName);
  }
}