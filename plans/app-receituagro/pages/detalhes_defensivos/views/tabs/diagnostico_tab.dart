// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../constants/detalhes_defensivos_design_tokens.dart';
import '../../controller/detalhes_defensivos_controller.dart';
import '../../widgets/diagnostic_item_widget.dart';

class DiagnosticoTab extends StatefulWidget {
  final DetalhesDefensivosController controller;

  const DiagnosticoTab({
    super.key,
    required this.controller,
  });

  @override
  State<DiagnosticoTab> createState() => _DiagnosticoTabState();
}

class _DiagnosticoTabState extends State<DiagnosticoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onFocusChanged() {
    setState(() {
      // Força a reconstrução da UI quando o foco muda
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<DetalhesDefensivosController>(
      id: 'diagnostic_tab',
      builder: (controller) {
        if (controller.defensivo.value.diagnosticos.isEmpty) {
          return const Center(
            child: Text('Não há informações de diagnóstico disponíveis.'),
          );
        }

        final diagnosticos = controller.defensivo.value.diagnosticos;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSearchAndFilterRow(diagnosticos, context),
                  const SizedBox(height: 16),
                  _buildDiagnosticosList(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticCulturasList(
      List<dynamic> diagnosticos, BuildContext context) {
    // Extrair todas as culturas únicas dos diagnósticos
    final culturas = _extractCulturasFromDiagnosticos(diagnosticos);

    // Se não houver culturas, não mostrar o filtro
    if (culturas.isEmpty) {
      return const SizedBox.shrink();
    }

    // Se houver apenas uma cultura, também não mostrar o filtro
    if (culturas.length <= 1) {
      return const SizedBox.shrink();
    }

    final isDark = widget.controller.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por cultura:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GetBuilder<DetalhesDefensivosController>(
          id: 'diagnostic_tab',
          builder: (controller) => Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.searchCultura.value.isEmpty
                    ? 'Todas'
                    : controller.searchCultura.value,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                items: [
                  DropdownMenuItem<String>(
                    value: 'Todas',
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Todas as culturas',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...culturas.map((cultura) => DropdownMenuItem<String>(
                        value: cultura,
                        child: Row(
                          children: [
                            Icon(
                              Icons.eco,
                              size: 16,
                              color: isDark
                                  ? Colors.amber.shade300
                                  : Colors.amber.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cultura,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    widget.controller.updateSearchCultura(
                      value == 'Todas' ? '' : value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticosList(BuildContext context) {
    return GetBuilder<DetalhesDefensivosController>(
      id: 'diagnostic_tab',
      builder: (controller) {
        final diagnosticos = _getFilteredDiagnosticos(controller);
        
        if (diagnosticos.isEmpty) {
          return const SizedBox.shrink();
        }

        // Se nenhuma cultura específica está selecionada, agrupa por cultura
        if (controller.searchCultura.value.isEmpty) {
          final diagnosticosAgrupados = _agruparPorCultura(diagnosticos);
          final culturas = diagnosticosAgrupados.keys.toList()..sort();

          return ListView.separated(
            key: const ValueKey('diagnostics_grouped_list'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: culturas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final cultura = culturas[index];
              final diagnosticosDaCultura = diagnosticosAgrupados[cultura]!;
              return _buildCulturaSection(context, controller, cultura, diagnosticosDaCultura);
            },
          );
        } else {
          // Se uma cultura específica está selecionada, mostra apenas a lista
          return ListView.separated(
            key: const ValueKey('diagnostics_simple_list'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diagnosticos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final diagnostico = diagnosticos[index];
              return DiagnosticItemWidget(
                key: ValueKey('diagnostic_${diagnostico['idReg']}_$index'),
                diagnostico: diagnostico,
                controller: controller,
              );
            },
          );
        }
      },
    );
  }

  /// Extrai as culturas únicas dos diagnósticos com suporte a múltiplos campos
  List<String> _extractCulturasFromDiagnosticos(List<dynamic> diagnosticos) {
    final Set<String> culturasSet = {};

    for (final diagnostico in diagnosticos) {
      // Suporte a múltiplos campos de cultura
      final cultura = diagnostico['cultura'] ??
          diagnostico['nomeCultura'] ??
          diagnostico['culturaNome'] ??
          '';

      if (cultura != null &&
          cultura.toString().isNotEmpty &&
          cultura.toString() != 'null' &&
          cultura.toString() != 'Cultura não especificada') {
        culturasSet.add(cultura.toString());
      }
    }

    final culturas = culturasSet.toList();
    culturas.sort(); // Ordenar alfabeticamente
    return culturas;
  }

  List<dynamic> _getFilteredDiagnosticos(
      DetalhesDefensivosController controller) {
    List<dynamic> diagnosticos = controller.diagnosticosFiltered;

    if (_searchQuery.isEmpty) {
      return diagnosticos;
    }

    return diagnosticos.where((diagnostico) {
      final nomePraga =
          (diagnostico['nomePraga'] ?? '').toString().toLowerCase();
      final nomeCientifico =
          (diagnostico['nomeCientifico'] ?? '').toString().toLowerCase();
      final cultura = (diagnostico['cultura'] ??
              diagnostico['nomeCultura'] ??
              diagnostico['culturaNome'] ??
              '')
          .toString()
          .toLowerCase();

      return nomePraga.contains(_searchQuery) ||
          nomeCientifico.contains(_searchQuery) ||
          cultura.contains(_searchQuery);
    }).toList();
  }

  /// Agrupa diagnósticos por cultura
  Map<String, List<dynamic>> _agruparPorCultura(List<dynamic> diagnosticos) {
    final Map<String, List<dynamic>> agrupados = {};

    for (final diagnostico in diagnosticos) {
      final cultura = diagnostico['cultura'] ??
          diagnostico['nomeCultura'] ??
          diagnostico['culturaNome'] ??
          'Cultura não especificada';

      if (!agrupados.containsKey(cultura)) {
        agrupados[cultura] = [];
      }
      agrupados[cultura]!.add(diagnostico);
    }

    return agrupados;
  }

  /// Constrói uma seção de cultura com seus diagnósticos
  Widget _buildCulturaSection(
      BuildContext context,
      DetalhesDefensivosController controller,
      String cultura,
      List<dynamic> diagnosticos) {
    // Conta o número total de indicações em todos os diagnósticos desta cultura
    final totalIndicacoes = diagnosticos.fold<int>(
      0,
      (total, diagnostico) => total + ((diagnostico['indicacoes'] as List?)?.length ?? 0),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCulturaHeader(context, cultura, totalIndicacoes),
        const SizedBox(height: 12),
        _buildDiagnosticosListView(context, controller, diagnosticos),
      ],
    );
  }

  /// Constrói o cabeçalho da cultura
  Widget _buildCulturaHeader(
      BuildContext context, String cultura, int quantidade) {
    final isDark = widget.controller.isDark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco,
            size: 18,
            color: isDark ? Colors.green.shade300 : Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: cultura,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: ' ($quantidade diagnóstico${quantidade != 1 ? 's' : ''})',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de diagnósticos sem bordas
  Widget _buildDiagnosticosListView(BuildContext context,
      DetalhesDefensivosController controller, List<dynamic> diagnosticos) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diagnosticos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final diagnostico = diagnosticos[index];
        return DiagnosticItemWidget(
          key: ValueKey('diagnostic_${diagnostico['idReg']}_$index'),
          diagnostico: diagnostico,
          controller: controller,
        );
      },
    );
  }

  Widget _buildSearchAndFilterRow(
      List<dynamic> diagnosticos, BuildContext context) {
    // Extrair culturas para o filtro
    final culturas = _extractCulturasFromDiagnosticos(diagnosticos);
    final showCulturaFilter = culturas.isNotEmpty && !_searchFocusNode.hasFocus;

    return Row(
      children: [
        // Campo de pesquisa (50% quando dropdown visível, 100% quando oculto)
        Expanded(
          flex: showCulturaFilter ? 50 : 100,
          child: _buildSearchField(context),
        ),

        // Espaçamento entre os elementos - apenas quando dropdown visível
        if (showCulturaFilter) const SizedBox(width: 12),

        // Filtro de cultura (50% do espaço) - apenas se houver mais de uma cultura e o campo de pesquisa não tiver foco
        if (showCulturaFilter)
          Expanded(
            flex: 50,
            child: _buildCulturaDropdown(culturas, context),
          ),
      ],
    );
  }

  Widget _buildCulturaDropdown(List<String> culturas, BuildContext context) {
    final isDark = widget.controller.isDark;

    return GetBuilder<DetalhesDefensivosController>(
      id: 'diagnostic_tab',
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.searchCultura.value.isEmpty
                ? 'Todas'
                : controller.searchCultura.value,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            items: [
              DropdownMenuItem<String>(
                value: 'Todas',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 16,
                        color: isDark 
                            ? Colors.green.shade300 
                            : Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Todas',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...culturas.map((cultura) => DropdownMenuItem<String>(
                    value: cultura,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco,
                            size: 16,
                            color: isDark 
                                ? Colors.amber.shade300 
                                : Colors.amber.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cultura,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
            onChanged: (String? value) {
              if (value != null) {
                widget.controller.updateSearchCultura(
                  value == 'Todas' ? '' : value,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final isDark = widget.controller.isDark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Localizar',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
            ),
            prefixIcon: Icon(
              FontAwesome.magnifying_glass_solid,
              size: DetalhesDefensivosDesignTokens.smallIconSize,
              color: isDark ? Colors.green.shade300 : Colors.green.shade600,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      FontAwesome.xmark_solid,
                      size: DetalhesDefensivosDesignTokens.smallIconSize,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    tooltip: 'Limpar busca',
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
