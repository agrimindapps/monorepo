import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';
import '../providers/detalhe_defensivo_notifier.dart';
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
/// Migrated to Riverpod - uses ConsumerWidget
class DiagnosticosTabWidget extends ConsumerWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({super.key, required this.defensivoName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DiagnosticoDefensivoFilterWidget(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: SpacingTokens.xs,
                bottom: SpacingTokens.bottomNavSpace, // Espaço para bottom nav
              ),
              child: DiagnosticoDefensivoStateManager(
                defensivoName: defensivoName,
                builder: _buildDiagnosticsList,
                onRetry: () => _retryLoadDiagnostics(ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(WidgetRef ref) {
    final defensivoState = ref.read(detalheDefensivoNotifierProvider);
    defensivoState.whenData((data) {
      final idReg = data.defensivoData?.idReg;
      final nomeDefensivo = data.defensivoData?.nomeComum;
      if (idReg != null) {
        ref
            .read(diagnosticosNotifierProvider.notifier)
            .getDiagnosticosByDefensivo(idReg, nomeDefensivo: nomeDefensivo);
      }
    });
  }

  /// Constrói lista de diagnósticos agrupados por cultura
  Widget _buildDiagnosticsList(List<dynamic> diagnosticos) {
    return FutureBuilder<Map<String, List<dynamic>>>(
      future: _groupDiagnosticsByCulture(diagnosticos),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final groupedDiagnostics = snapshot.data ?? {};

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildGroupedWidgets(groupedDiagnostics),
        );
      },
    );
  }

  /// Agrupa diagnósticos por cultura usando dados reais do repositório
  Future<Map<String, List<dynamic>>> _groupDiagnosticsByCulture(
    List<dynamic> diagnosticos,
  ) async {
    final grouped = <String, List<dynamic>>{};
    final culturaRepository = sl<CulturaHiveRepository>();

    for (final diagnostic in diagnosticos) {
      String culturaNome = 'Não especificado';

      try {
        final idCultura = _getPropertyFromDiagnostic(diagnostic, 'idCultura');
        if (idCultura != null) {
          final culturaData = await culturaRepository.getById(idCultura);
          if (culturaData != null) {
            culturaNome = culturaData.cultura;
          }
        }
        if (culturaNome == 'Não especificado') {
          final nomeCultura = _getPropertyFromDiagnostic(
            diagnostic,
            'nomeCultura',
          );
          final culturaProp = _getPropertyFromDiagnostic(diagnostic, 'cultura');
          culturaNome = nomeCultura ?? culturaProp ?? 'Não especificado';
        }
      } catch (e) {
        culturaNome = 'Não especificado';
      }

      grouped.putIfAbsent(culturaNome, () => []).add(diagnostic);
    }

    return grouped;
  }

  /// Helper para extrair propriedades de um diagnóstico
  String? _getPropertyFromDiagnostic(dynamic diagnostic, String property) {
    try {
      if (diagnostic is Map<String, dynamic>) {
        return diagnostic[property]?.toString();
      } else {
        switch (property) {
          case 'idCultura':
            return diagnostic.idCultura?.toString();
          case 'nomeCultura':
            return diagnostic.nomeCultura?.toString();
          case 'cultura':
            return diagnostic.cultura?.toString();
          default:
            return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  /// Constrói widgets agrupados por cultura
  List<Widget> _buildGroupedWidgets(
    Map<String, List<dynamic>> groupedDiagnostics,
  ) {
    final List<Widget> widgets = [];

    groupedDiagnostics.forEach((cultura, diagnostics) {
      widgets.add(
        DiagnosticoDefensivoCultureSectionWidget(
          cultura: cultura,
          diagnosticCount: diagnostics.length,
          diagnosticos: diagnostics,
        ),
      );
      widgets.add(SpacingTokens.gapLG);
      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(
          Builder(
            builder:
                (context) => DiagnosticoDefensivoListItemWidget(
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
  void _showDiagnosticoDialog(BuildContext context, dynamic diagnostico) {
    DiagnosticoDefensivoDialogWidget.show(context, diagnostico, defensivoName);
  }
}
