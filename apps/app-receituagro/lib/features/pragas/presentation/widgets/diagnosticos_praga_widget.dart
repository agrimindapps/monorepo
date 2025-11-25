import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../providers/detalhe_praga_notifier.dart';
import '../providers/diagnosticos_praga_notifier.dart';
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
class DiagnosticosPragaWidget extends ConsumerWidget {
  final String pragaName;

  const DiagnosticosPragaWidget({
    super.key,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DiagnosticoFilterWidget(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: SpacingTokens.xs,
                bottom: SpacingTokens.bottomNavSpace, // Espaço para bottom nav
              ),
              child: DiagnosticoStateManager(
                builder: _buildDiagnosticsList,
                onRetry: () => _retryLoadDiagnostics(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(BuildContext context, WidgetRef ref) {
    final pragaState = ref.read(detalhePragaProvider).value;

    ref.read(diagnosticosPragaProvider.notifier).clearError();
    // MIGRATION NOTE: Drift Praga uses idPraga instead of idReg
    if (pragaState?.pragaData != null && pragaState!.pragaData!.idPraga.isNotEmpty) {
      ref.read(diagnosticosPragaProvider.notifier).loadDiagnosticos(
        pragaState.pragaData!.idPraga,
        pragaName: pragaName,
      );
    }
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
      widgets.add(
        DiagnosticoCultureSectionWidget(
          cultura: cultura,
          diagnosticCount: diagnostics.length,
        ),
      );
      widgets.add(SpacingTokens.gapLG);
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
          widgets.add(SpacingTokens.gapMD);
        }
      }
      widgets.add(SpacingTokens.gapXL);
    });
    return widgets;
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, DiagnosticoModel diagnostico) {
    DiagnosticoDialogWidget.show(context, diagnostico, pragaName);
  }
}
