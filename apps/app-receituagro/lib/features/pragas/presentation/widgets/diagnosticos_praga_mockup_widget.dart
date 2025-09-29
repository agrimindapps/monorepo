import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:core/core.dart';

import '../../../../core/design/spacing_tokens.dart';
import '../providers/diagnosticos_praga_provider.dart';
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
class DiagnosticosPragaMockupWidget extends StatelessWidget {
  final String pragaName;

  const DiagnosticosPragaMockupWidget({
    super.key,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filtros superiores pixel-perfect
            _buildFiltersMockup(),

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
                  onRetry: () => _retryLoadDiagnostics(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filtros superiores integrados com provider
  Widget _buildFiltersMockup() {
    return provider_lib.Consumer<DiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        return FiltersMockupWidget(
          searchText: provider.searchQuery,
          selectedFilter: provider.selectedCultura,
          onSearchChanged: provider.updateSearchQuery,
          onFilterChanged: provider.updateSelectedCultura,
          filterOptions: provider.culturas,
        );
      },
    );
  }

  /// Callback para retry quando houver erro
  void _retryLoadDiagnostics(BuildContext context) {
    final provider =
        provider_lib.Provider.of<DiagnosticosPragaProvider>(context, listen: false);
    provider.clearError();
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
          .add(SizedBox(height: DiagnosticoMockupTokens.sectionToCardSpacing));

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
    return provider_lib.Consumer<DiagnosticosPragaProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.yellow.shade100,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DEBUG: Diagnósticos Mockup'),
              Text('Total: ${provider.diagnosticos.length}'),
              Text('Filtrados: ${provider.filteredDiagnosticos.length}'),
              Text('Culturas: ${provider.groupedDiagnosticos.keys.length}'),
              Row(
                children: [
                  Checkbox(
                    value: _useMockupLayout,
                    onChanged: (value) => setState(() {
                      _useMockupLayout = value ?? true;
                    }),
                  ),
                  Text('Layout Mockup'),
                ],
              ),
            ],
          ),
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
