import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../database/repositories/culturas_repository.dart';
import '../../../../../core/data/repositories/pragas_legacy_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/spacing_tokens.dart';
import '../../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';
import '../../providers/detalhe_defensivo_notifier.dart';
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
    final diagnosticosAsync = ref.watch(diagnosticosNotifierProvider);

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Passa culturas disponíveis do agrupamento para o filtro
          diagnosticosAsync.when(
            data: (state) {
              return FutureBuilder<Map<String, List<dynamic>>>(
                future: _groupDiagnosticsByCulture(
                  state.searchQuery.isNotEmpty
                      ? state.searchResults
                      : state.filteredDiagnosticos,
                ),
                builder: (context, snapshot) {
                  final culturas = snapshot.data?.keys.toList() ?? [];
                  return DiagnosticoDefensivoFilterWidget(
                    availableCulturas: culturas,
                  );
                },
              );
            },
            loading: () => const DiagnosticoDefensivoFilterWidget(),
            error: (_, __) => const DiagnosticoDefensivoFilterWidget(),
          ),
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
      final idReg = data.defensivoData?.idDefensivo;
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

        // Usa FutureBuilder aninhado para ordenação assíncrona
        return FutureBuilder<Widget>(
          future: _buildGroupedWidgets(groupedDiagnostics),
          builder: (context, widgetSnapshot) {
            if (widgetSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widgetSnapshot.hasError) {
              return Center(
                child: Text('Erro ao ordenar: ${widgetSnapshot.error}'),
              );
            }

            return widgetSnapshot.data ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  /// Agrupa diagnósticos por cultura usando dados reais do repositório
  Future<Map<String, List<dynamic>>> _groupDiagnosticsByCulture(
    List<dynamic> diagnosticos,
  ) async {
    final grouped = <String, List<dynamic>>{};
    final culturaRepository = sl<CulturasRepository>();

    for (final diagnostic in diagnosticos) {
      String culturaNome = 'Não especificado';

      try {
        final idCulturaStr = _getPropertyFromDiagnostic(diagnostic, 'idCultura');
        if (idCulturaStr != null) {
          final idCultura = int.tryParse(idCulturaStr);
          if (idCultura != null) {
            final culturaData = await culturaRepository.findById(idCultura);
            if (culturaData != null) {
              culturaNome = culturaData.nome;
            }
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

  /// Constrói widgets agrupados por cultura usando ListView.separated
  Future<Widget> _buildGroupedWidgets(
    Map<String, List<dynamic>> groupedDiagnostics,
  ) async {
    // Ordena culturas alfabeticamente
    final culturasOrdenadas = groupedDiagnostics.keys.toList()..sort();

    // Cria lista flat com headers e itens para ListView.separated
    final List<_DiagnosticoListItem> flatList = [];

    for (final cultura in culturasOrdenadas) {
      final diagnostics = groupedDiagnostics[cultura]!;

      // Ordena diagnósticos por nome comum da praga usando ordenação assíncrona
      // Precisamos buscar os nomes das pragas do repositório para ordenar corretamente
      final diagnosticsComNomes = <MapEntry<dynamic, String>>[];
      final pragaRepository = sl<PragasLegacyRepository>();

      for (final diagnostic in diagnostics) {
        String nomePraga = '';

        if (diagnostic is Map<String, dynamic>) {
          nomePraga = (diagnostic['nomePraga'] ?? diagnostic['grupo'] ?? '')
              .toString();
        } else {
          try {
            nomePraga =
                diagnostic.nomePraga?.toString() ??
                diagnostic.grupo?.toString() ??
                '';
          } catch (e) {
            nomePraga = '';
          }
        }

        // Se nomePraga estiver vazio ou for "Não especificado", busca do repositório
        if (nomePraga.isEmpty || nomePraga == 'Não especificado') {
          String? fkIdPraga;
          if (diagnostic is Map<String, dynamic>) {
            fkIdPraga = diagnostic['fkIdPraga']?.toString();
          } else {
            try {
              fkIdPraga = diagnostic.fkIdPraga?.toString();
            } catch (e) {
              // ignore
            }
          }

          if (fkIdPraga != null && fkIdPraga.isNotEmpty) {
            final pragaData = await pragaRepository.getById(fkIdPraga);
            if (pragaData != null) {
              final nomeComum = pragaData.nomeComum;
              // Extrai primeiro nome se houver vírgula ou ponto-e-vírgula
              if (nomeComum.contains(',')) {
                nomePraga = nomeComum.split(',').first.trim();
              } else if (nomeComum.contains(';')) {
                nomePraga = nomeComum.split(';').first.trim();
              } else {
                nomePraga = nomeComum;
              }
            }
          }
        }

        diagnosticsComNomes.add(MapEntry(diagnostic, nomePraga));
      }

      // Ordena por nome
      diagnosticsComNomes.sort(
        (a, b) => a.value.toLowerCase().trim().compareTo(
          b.value.toLowerCase().trim(),
        ),
      );

      // Extrai apenas os diagnósticos ordenados
      final diagnosticsOrdenados = diagnosticsComNomes
          .map((e) => e.key)
          .toList();

      // Adiciona header da cultura
      flatList.add(
        _DiagnosticoListItem.header(
          cultura,
          diagnosticsOrdenados.length,
          diagnosticsOrdenados,
        ),
      );

      // Adiciona todos os diagnósticos dessa cultura (já ordenados)
      for (final diagnostic in diagnosticsOrdenados) {
        flatList.add(_DiagnosticoListItem.diagnostic(diagnostic));
      }
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
          return const SizedBox(height: 2);
        }

        // Divider entre cards
        return const Divider(height: 1, thickness: 1);
      },
      itemBuilder: (context, index) {
        final item = flatList[index];

        if (item.isHeader) {
          return DiagnosticoDefensivoCultureSectionWidget(
            cultura: item.cultura!,
            diagnosticCount: item.count!,
            diagnosticos: item.diagnosticos!,
          );
        }

        return Builder(
          builder: (context) => DiagnosticoDefensivoListItemWidget(
            diagnostico: item.diagnostic!,
            onTap: () => _showDiagnosticoDialog(context, item.diagnostic!),
            isDense: true,
            hasElevation: false,
          ),
        );
      },
    );
  }

  /// Mostra modal de detalhes do diagnóstico
  void _showDiagnosticoDialog(BuildContext context, dynamic diagnostico) {
    DiagnosticoDefensivoDialogWidget.show(context, diagnostico, defensivoName);
  }
}

/// Helper class para representar items na lista flat (headers ou diagnósticos)
class _DiagnosticoListItem {
  final bool isHeader;
  final String? cultura;
  final int? count;
  final List<dynamic>? diagnosticos;
  final dynamic diagnostic;

  _DiagnosticoListItem._({
    required this.isHeader,
    this.cultura,
    this.count,
    this.diagnosticos,
    this.diagnostic,
  });

  factory _DiagnosticoListItem.header(
    String cultura,
    int count,
    List<dynamic> diagnosticos,
  ) {
    return _DiagnosticoListItem._(
      isHeader: true,
      cultura: cultura,
      count: count,
      diagnosticos: diagnosticos,
    );
  }

  factory _DiagnosticoListItem.diagnostic(dynamic diagnostic) {
    return _DiagnosticoListItem._(isHeader: false, diagnostic: diagnostic);
  }
}
