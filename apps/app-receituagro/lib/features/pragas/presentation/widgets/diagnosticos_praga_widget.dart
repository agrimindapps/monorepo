import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/diagnosticos_praga_provider.dart';
import 'diagnostico_dialog_widget.dart';
import 'diagnostico_filter_widget.dart';
import 'diagnostico_list_item_widget.dart';
import 'diagnostico_state_widgets.dart';

/// Widget principal responsável por exibir diagnósticos relacionados à praga
/// 
/// Responsabilidade única: orquestrar componentes para exibir diagnósticos
/// - Filtros de pesquisa e cultura
/// - Lista agrupada de diagnósticos
/// - Estados de loading, erro e vazio
/// - Modal de detalhes do diagnóstico
/// 
/// **Arquitetura Decomposta:**
/// - `DiagnosticoFilterWidget`: Filtros de pesquisa
/// - `DiagnosticoStateManager`: Gerenciamento de estados
/// - `DiagnosticoListItemWidget`: Itens da lista
/// - `DiagnosticoDialogWidget`: Modal de detalhes
/// 
/// **Performance Otimizada:**
/// - RepaintBoundary para evitar rebuilds desnecessários
/// - Componentes reutilizáveis e modulares
/// - Estados gerenciados de forma eficiente
class DiagnosticosPragaWidget extends StatelessWidget {
  final String pragaName;

  const DiagnosticosPragaWidget({
    super.key,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Área de filtros
          const DiagnosticoFilterWidget(),
          // Lista de diagnósticos com gerenciamento de estados
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: DiagnosticoStateManager(
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
    final provider = Provider.of<DiagnosticosPragaProvider>(context, listen: false);
    provider.clearError();
  }

  /// Constrói lista de diagnósticos agrupados por cultura
  Widget _buildDiagnosticsList(List<DiagnosticoModel> diagnosticos) {
    final groupedDiagnostics = _groupDiagnosticsByCulture(diagnosticos);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildGroupedWidgets(groupedDiagnostics),
    );
  }
  
  /// Agrupa diagnósticos por cultura
  Map<String, List<DiagnosticoModel>> _groupDiagnosticsByCulture(
    List<DiagnosticoModel> diagnosticos,
  ) {
    final grouped = <String, List<DiagnosticoModel>>{};
    
    for (final diagnostic in diagnosticos) {
      grouped.putIfAbsent(diagnostic.cultura, () => []).add(diagnostic);
    }
    
    return grouped;
  }
  
  /// Constrói widgets agrupados por cultura
  List<Widget> _buildGroupedWidgets(
    Map<String, List<DiagnosticoModel>> groupedDiagnostics,
  ) {
    final List<Widget> widgets = [];

    groupedDiagnostics.forEach((cultura, diagnostics) {
      // Seção de cultura
      widgets.add(
        DiagnosticoCultureSectionWidget(
          cultura: cultura,
          diagnosticCount: diagnostics.length,
        ),
      );
      widgets.add(const SizedBox(height: 16));

      // Itens de diagnósticos
      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(
          Builder(
            builder: (context) => DiagnosticoListItemWidget(
              diagnostico: diagnostic,
              onTap: () => _showDiagnosticoDialog(context, diagnostic),
            ),
          ),
        );
        if (i < diagnostics.length - 1) {
          widgets.add(const SizedBox(height: 12));
        }
      }
      widgets.add(const SizedBox(height: 24));
    });

    widgets.add(const SizedBox(height: 80));
    return widgets;
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, DiagnosticoModel diagnostico) {
    DiagnosticoDialogWidget.show(context, diagnostico, pragaName);
  }
}