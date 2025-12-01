import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../providers/detalhe_praga_notifier.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import 'diagnostico_dialog_widget.dart';
import 'diagnostico_filter_widget.dart';
import 'diagnostico_list_item_widget.dart';
import 'diagnostico_state_widgets.dart';

/// Helper class para representar items na lista flat (headers ou diagnósticos)
class _DiagnosticoListItem {
  final bool isHeader;
  final String? cultura;
  final int? count;
  final DiagnosticoModel? diagnostic;

  _DiagnosticoListItem._({
    required this.isHeader,
    this.cultura,
    this.count,
    this.diagnostic,
  });

  factory _DiagnosticoListItem.header(String cultura, int count) {
    return _DiagnosticoListItem._(
      isHeader: true,
      cultura: cultura,
      count: count,
    );
  }

  factory _DiagnosticoListItem.diagnostic(DiagnosticoModel diagnostic) {
    return _DiagnosticoListItem._(isHeader: false, diagnostic: diagnostic);
  }
}

/// Widget principal responsável por exibir diagnósticos relacionados à praga
///
/// Responsabilidade única: orquestrar componentes para exibir diagnósticos
/// - Filtros de pesquisa e cultura
/// - Lista agrupada de diagnósticos (usando ListView.separated)
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
/// - ListView.separated para melhor performance em listas longas
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

  /// Constrói lista de diagnósticos agrupados por cultura usando ListView.separated
  Widget _buildDiagnosticsList(List<DiagnosticoModel> diagnosticos) {
    final groupedDiagnostics = _groupDiagnosticsByCulture(diagnosticos);
    
    // Cria lista flat com headers e itens para ListView.separated
    final flatList = _buildFlatList(groupedDiagnostics);
    
    if (flatList.isEmpty) {
      return const DiagnosticoEmptyWidget();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flatList.length,
      separatorBuilder: (context, index) {
        final currentItem = flatList[index];
        final nextItem = index + 1 < flatList.length
            ? flatList[index + 1]
            : null;

        // Espaçamento após header
        if (currentItem.isHeader) {
          return const SizedBox(height: 2);
        }

        // Espaçamento maior antes do próximo header
        if (nextItem != null && nextItem.isHeader) {
          return const SizedBox(height: SpacingTokens.lg);
        }

        // Divider entre cards
        return const Divider(height: 1, thickness: 1);
      },
      itemBuilder: (context, index) {
        final item = flatList[index];

        if (item.isHeader) {
          return DiagnosticoCultureSectionWidget(
            cultura: item.cultura!,
            diagnosticCount: item.count!,
          );
        }

        return DiagnosticoListItemWidget(
          diagnostico: item.diagnostic!,
          onTap: () => _showDiagnosticoDialog(context, item.diagnostic!),
          isDense: true,
          hasElevation: false,
        );
      },
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
  
  /// Cria lista flat com headers e diagnósticos para ListView.separated
  List<_DiagnosticoListItem> _buildFlatList(
    Map<String, List<DiagnosticoModel>> groupedDiagnostics,
  ) {
    final flatList = <_DiagnosticoListItem>[];
    
    // Ordena culturas alfabeticamente
    final culturasOrdenadas = groupedDiagnostics.keys.toList()..sort();
    
    for (final cultura in culturasOrdenadas) {
      final diagnostics = groupedDiagnostics[cultura]!;
      
      // Ordena diagnósticos por nome do defensivo
      diagnostics.sort((a, b) => 
        a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      
      // Adiciona header da cultura
      flatList.add(_DiagnosticoListItem.header(cultura, diagnostics.length));
      
      // Adiciona todos os diagnósticos dessa cultura
      for (final diagnostic in diagnostics) {
        flatList.add(_DiagnosticoListItem.diagnostic(diagnostic));
      }
    }
    
    return flatList;
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, DiagnosticoModel diagnostico) {
    DiagnosticoDialogWidget.show(context, diagnostico, pragaName);
  }
}
