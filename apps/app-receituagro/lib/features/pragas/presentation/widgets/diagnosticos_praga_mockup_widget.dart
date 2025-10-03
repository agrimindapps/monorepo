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

  const DiagnosticosPragaMockupWidget({
    super.key,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filtros superiores pixel-perfect
            _buildFiltersMockup(ref),

            // Lista de diagnósticos com gerenciamento de estados
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
          ref.read(diagnosticosPragaNotifierProvider.notifier).updateSearchQuery(value);
        },
        onFilterChanged: (value) {
          ref.read(diagnosticosPragaNotifierProvider.notifier).updateSelectedCultura(value);
        },
        filterOptions: data.culturas,
      ),
      loading: () => const SizedBox(height: 48),
      error: (error, _) => const SizedBox(height: 48),
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(BuildContext context, WidgetRef ref) {
    final diagnosticosState = ref.read(diagnosticosPragaNotifierProvider).value;
    final pragaState = ref.read(detalhePragaNotifierProvider).value;

    ref.read(diagnosticosPragaNotifierProvider.notifier).clearError();

    // Recarregar diagnósticos se temos os dados da praga
    if (pragaState?.pragaData != null && pragaState!.pragaData!.idReg.isNotEmpty) {
      ref.read(diagnosticosPragaNotifierProvider.notifier).loadDiagnosticos(
        pragaState.pragaData!.idReg,
        pragaName: pragaName,
      );
    }
  }

  /// Constrói lista de diagnósticos agrupados por cultura usando widgets mockup
  Widget _buildDiagnosticsMockupList(
      List<DiagnosticoModel> diagnosticos, BuildContext context) {
    final groupedDiagnostics = _groupDiagnosticsByCulture(diagnosticos);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildGroupedMockupWidgets(groupedDiagnostics, context),
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

  /// Constrói widgets agrupados usando componentes mockup
  List<Widget> _buildGroupedMockupWidgets(
    Map<String, List<DiagnosticoModel>> groupedDiagnostics,
    BuildContext context,
  ) {
    final List<Widget> widgets = [];

    groupedDiagnostics.forEach((cultura, diagnostics) {
      // Seção de cultura mockup
      widgets.add(
        CulturaSectionMockupFactory.basic(
          cultura: cultura,
          diagnosticoCount: diagnostics.length,
        ),
      );

      // Espaçamento após seção
      widgets
          .add(const SizedBox(height: DiagnosticoMockupTokens.sectionToCardSpacing));

      // Cards de diagnósticos mockup
      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DiagnosticoMockupCardFactory.create(
              diagnostico: diagnostic,
              onTap: () => _showDiagnosticoDialog(context, diagnostic),
            ),
          ),
        );
      }

      // Espaçamento entre grupos de cultura
      widgets.add(const SizedBox(height: 24));
    });

    return widgets;
  }

  /// Mostra modal de detalhes do diagnóstico (mantém funcionalidade original)
  void _showDiagnosticoDialog(
      BuildContext context, DiagnosticoModel diagnostico) {
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
        // Debug controls
        if (_showDebugInfo) _buildDebugControls(),

        // Main widget
        Expanded(
          child: DiagnosticosPragaTransitionWidget(
            pragaName: widget.pragaName,
            useMockupLayout: _useMockupLayout,
          ),
        ),

        // Debug toggle
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
      child: Container(
        height: 4,
        color: Colors.transparent,
      ),
    );
  }
}
