import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../providers/detalhe_praga_notifier.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import 'cultura_section_mockup_widget.dart';
import 'diagnostico_dialog_widget.dart';
import 'diagnostico_mockup_card.dart';
import 'diagnostico_mockup_tokens.dart';
import 'diagnostico_state_widgets.dart';
import 'filters_mockup_widget.dart';

/// Widget principal que implementa EXATAMENTE o design do mockup IMG_3186.PNG
/// substituindo o DiagnosticosPragaWidget original
///
/// Layout do mockup analisado:
/// - Filtros no topo (Localizar + dropdown Todas)
/// - Lista agrupada por cultura
/// - Seções cinza com ícone de folha
/// - Cards brancos com ícone verde, texto e premium icon
/// - Estados de loading, erro e vazio
///
/// Responsabilidade: orquestrar componentes mockup mantendo funcionalidade
class DiagnosticosPragaMockupWidget extends ConsumerWidget {
  final String pragaName;

  const DiagnosticosPragaMockupWidget({super.key, required this.pragaName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFiltersMockup(ref),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: SpacingTokens.xs,
                    bottom: SpacingTokens.bottomNavSpace,
                  ),
                  child: DiagnosticoStateManager(
                    builder: (diagnosticos) => Builder(
                      builder: (context) =>
                          _buildDiagnosticsMockupList(diagnosticos, context),
                    ),
                    onRetry: () => _retryLoadDiagnostics(context, ref),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filtros superiores integrados com notifier
  Widget _buildFiltersMockup(WidgetRef ref) {
    final state = ref.watch(diagnosticosPragaNotifierProvider);

    return state.when(
      data: (data) => FiltersMockupWidget(
        searchText: data.searchQuery,
        selectedFilter: data.selectedCultura,
        onSearchChanged: (value) {
          ref
              .read(diagnosticosPragaNotifierProvider.notifier)
              .updateSearchQuery(value);
        },
        onFilterChanged: (value) {
          ref
              .read(diagnosticosPragaNotifierProvider.notifier)
              .updateSelectedCultura(value);
        },
        filterOptions: data.culturas,
      ),
      loading: () => const SizedBox(height: 48),
      error: (error, _) => const SizedBox(height: 48),
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(BuildContext context, WidgetRef ref) {
    final pragaState = ref.read(detalhePragaNotifierProvider).value;

    ref.read(diagnosticosPragaNotifierProvider.notifier).clearError();
    if (pragaState?.pragaData != null &&
        pragaState!.pragaData!.idReg.isNotEmpty) {
      ref
          .read(diagnosticosPragaNotifierProvider.notifier)
          .loadDiagnosticos(pragaState.pragaData!.idReg, pragaName: pragaName);
    }
  }

  /// Constrói lista de diagnósticos agrupados por cultura usando widgets mockup
  Widget _buildDiagnosticsMockupList(
    List<DiagnosticoModel> diagnosticos,
    BuildContext context,
  ) {
    final groupedDiagnostics = _groupDiagnosticsByCulture(diagnosticos);

    return _buildGroupedMockupWidgets(groupedDiagnostics, context);
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

  /// Constrói widgets agrupados usando ListView.separated
  Widget _buildGroupedMockupWidgets(
    Map<String, List<DiagnosticoModel>> groupedDiagnostics,
    BuildContext context,
  ) {
    // Ordena culturas alfabeticamente
    final culturasOrdenadas = groupedDiagnostics.keys.toList()..sort();

    // Cria lista flat com headers e itens para ListView.separated
    final List<_ListItem> flatList = [];

    for (final cultura in culturasOrdenadas) {
      final diagnostics = groupedDiagnostics[cultura]!;

      // Ordena diagnósticos por nome do defensivo
      final diagnosticsOrdenados = List<DiagnosticoModel>.from(diagnostics)
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

      // Adiciona header da cultura
      flatList.add(_ListItem.header(cultura, diagnosticsOrdenados.length));

      // Adiciona todos os diagnósticos dessa cultura (já ordenados)
      for (final diagnostic in diagnosticsOrdenados) {
        flatList.add(_ListItem.diagnostic(diagnostic));
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
          return const SizedBox(height: 8);
        }

        // Espaçamento maior antes do próximo header
        if (nextItem != null && nextItem.isHeader) {
          return const SizedBox(height: 16);
        }

        // Divider entre cards (igual à página de defensivos)
        return const Divider(height: 1, thickness: 1);
      },
      itemBuilder: (context, index) {
        final item = flatList[index];

        if (item.isHeader) {
          return CulturaSectionMockupFactory.basic(
            cultura: item.cultura!,
            diagnosticoCount: item.count!,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: DiagnosticoMockupCardFactory.create(
            diagnostico: item.diagnostic!,
            onTap: () => _showDiagnosticoDialog(context, item.diagnostic!),
          ),
        );
      },
    );
  }

  /// Mostra modal de detalhes do diagnóstico (mantém funcionalidade original)
  void _showDiagnosticoDialog(
    BuildContext context,
    DiagnosticoModel diagnostico,
  ) {
    DiagnosticoDialogWidget.show(context, diagnostico, pragaName);
  }
}

/// Widget de transição que permite alternar entre layout original e mockup
class DiagnosticosPragaTransitionWidget extends StatefulWidget {
  final String pragaName;
  final bool useMockupLayout;

  const DiagnosticosPragaTransitionWidget({
    super.key,
    required this.pragaName,
    this.useMockupLayout = true, // Por padrão usa layout mockup
  });

  @override
  State<DiagnosticosPragaTransitionWidget> createState() =>
      _DiagnosticosPragaTransitionWidgetState();
}

class _DiagnosticosPragaTransitionWidgetState
    extends State<DiagnosticosPragaTransitionWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: DiagnosticoMockupTokens.filterAnimationDuration,
      child: widget.useMockupLayout
          ? DiagnosticosPragaMockupWidget(
              key: const ValueKey('mockup'),
              pragaName: widget.pragaName,
            )
          : DiagnosticosPragaMockupWidget(
              key: const ValueKey('original'),
              pragaName: widget.pragaName,
            ),
    );
  }
}

/// Widget com funcionalidades de debug para desenvolvimento
class DiagnosticosPragaMockupDebugWidget extends StatefulWidget {
  final String pragaName;

  const DiagnosticosPragaMockupDebugWidget({
    super.key,
    required this.pragaName,
  });

  @override
  State<DiagnosticosPragaMockupDebugWidget> createState() =>
      _DiagnosticosPragaMockupDebugWidgetState();
}

class _DiagnosticosPragaMockupDebugWidgetState
    extends State<DiagnosticosPragaMockupDebugWidget> {
  bool _showDebugInfo = false;
  bool _useMockupLayout = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showDebugInfo) _buildDebugControls(),
        Expanded(
          child: DiagnosticosPragaTransitionWidget(
            pragaName: widget.pragaName,
            useMockupLayout: _useMockupLayout,
          ),
        ),
        _buildDebugToggle(),
      ],
    );
  }

  Widget _buildDebugControls() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(diagnosticosPragaNotifierProvider);

        return state.when(
          data: (data) => Container(
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DEBUG: Diagnósticos Mockup'),
                Text('Total: ${data.diagnosticos.length}'),
                Text('Filtrados: ${data.filteredDiagnosticos.length}'),
                Text('Culturas: ${data.groupedDiagnosticos.keys.length}'),
                Row(
                  children: [
                    Checkbox(
                      value: _useMockupLayout,
                      onChanged: (value) => setState(() {
                        _useMockupLayout = value ?? true;
                      }),
                    ),
                    const Text('Layout Mockup'),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDebugToggle() {
    return GestureDetector(
      onLongPress: () => setState(() {
        _showDebugInfo = !_showDebugInfo;
      }),
      child: Container(height: 4, color: Colors.transparent),
    );
  }
}

/// Helper class para representar items na lista flat (headers ou diagnósticos)
class _ListItem {
  final bool isHeader;
  final String? cultura;
  final int? count;
  final DiagnosticoModel? diagnostic;

  _ListItem._({
    required this.isHeader,
    this.cultura,
    this.count,
    this.diagnostic,
  });

  factory _ListItem.header(String cultura, int count) {
    return _ListItem._(isHeader: true, cultura: cultura, count: count);
  }

  factory _ListItem.diagnostic(DiagnosticoModel diagnostic) {
    return _ListItem._(isHeader: false, diagnostic: diagnostic);
  }
}
