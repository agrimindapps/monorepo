// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../constants/detalhes_pragas_design_tokens.dart';
import '../../controller/detalhes_pragas_controller.dart';
import '../../widgets/praga_diagnostic_item_widget.dart';

/// Tab de diagnóstico da praga com interface melhorada
/// Baseada no padrão visual superior de detalhes_defensivos
class DiagnosticoTab extends StatefulWidget {
  const DiagnosticoTab({super.key});

  @override
  State<DiagnosticoTab> createState() => _DiagnosticoTabState();
}

class _DiagnosticoTabState extends State<DiagnosticoTab>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';
  bool _isSearchFocused = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    // Aplicar filtro no controller
    Get.find<DetalhesPragasController>().filterDiagnostico(_searchQuery);
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    Get.find<DetalhesPragasController>().filterDiagnostico('');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return GestureDetector(
      onTap: () {
        // Remove foco quando toca fora do campo
        FocusScope.of(context).unfocus();
      },
      child: GetBuilder<ThemeController>(
        builder: (themeController) => GetBuilder<DetalhesPragasController>(
          id: 'theme',
          builder: (controller) {
            final isDark = themeController.isDark.value;
            return Container(
              padding: DetalhesPragasDesignTokens.sectionPadding,
              child: Column(
                children: [
                  _buildSearchAndFilterSection(context, controller, isDark),
                  const SizedBox(height: DetalhesPragasDesignTokens.largeSpacing),
                  Expanded(
                    child: _buildDiagnosticsList(context, controller, isDark),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Constrói a seção de busca e filtros
  Widget _buildSearchAndFilterSection(
      BuildContext context, DetalhesPragasController controller, bool isDark) {
    return GetBuilder<DetalhesPragasController>(
      id: 'diagnosticos',
      builder: (controller) {
        final diagnosticos = controller.diagnosticosFiltered;
        final culturas = _extractCulturasFromDiagnosticos(diagnosticos);

        return _buildSearchAndFilterRow(context, controller, culturas, isDark);
      },
    );
  }

  /// Constrói a linha de busca e filtros
  Widget _buildSearchAndFilterRow(BuildContext context,
      DetalhesPragasController controller, List<String> culturas, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 50,
          child: _buildSearchField(context, isDark),
        ),
        if (culturas.length > 1 && !_isSearchFocused) ...[
          const SizedBox(width: DetalhesPragasDesignTokens.mediumSpacing),
          Expanded(
            flex: 50,
            child: _buildCulturaDropdown(context, controller, culturas, isDark),
          ),
        ],
      ],
    );
  }

  /// Constrói o campo de busca avançado
  Widget _buildSearchField(BuildContext context, bool isDark) {
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
              size: DetalhesPragasDesignTokens.smallIconSize,
              color: isDark ? Colors.green.shade300 : Colors.green.shade600,
            ),
            suffixIcon: _searchQuery.isNotEmpty ? _buildClearButton(context) : null,
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

  /// Constrói o botão de limpar busca
  Widget _buildClearButton(BuildContext context) {
    return IconButton(
      onPressed: _clearSearch,
      icon: Icon(
        Icons.close,
        size: DetalhesPragasDesignTokens.smallIconSize,
        color: DetalhesPragasDesignTokens.getSubtitleColor(context),
      ),
      tooltip: 'Limpar busca',
    );
  }

  /// Constrói o dropdown de culturas
  Widget _buildCulturaDropdown(BuildContext context,
      DetalhesPragasController controller, List<String> culturas, bool isDark) {
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.searchCultura.isEmpty
              ? 'Todas'
              : controller.searchCultura,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
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
            controller.filterByCultura(value == 'Todas' ? '' : value ?? '');
          },
        ),
      ),
    );
  }

  /// Constrói a lista de diagnósticos agrupados por cultura
  Widget _buildDiagnosticsList(
      BuildContext context, DetalhesPragasController controller, bool isDark) {
    return GetBuilder<DetalhesPragasController>(
      id: 'diagnosticos',
      builder: (controller) {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final diagnosticos = controller.diagnosticosFiltered;

        if (diagnosticos.isEmpty) {
          return _buildEmptyState(context, controller);
        }

        return _buildDiagnosticosGroupedView(context, controller, diagnosticos, isDark);
      },
    );
  }

  /// Constrói o estado de carregamento
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              DetalhesPragasDesignTokens.primaryColor,
            ),
          ),
          const SizedBox(height: DetalhesPragasDesignTokens.largeSpacing),
          Text(
            'Carregando diagnósticos...',
            style: DetalhesPragasDesignTokens.cardSubtitleStyle.copyWith(
              color: DetalhesPragasDesignTokens.getSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado vazio
  Widget _buildEmptyState(
      BuildContext context, DetalhesPragasController controller) {
    final isFiltered =
        _searchQuery.isNotEmpty || controller.searchCultura.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered
                ? FontAwesome.magnifying_glass_solid
                : FontAwesome.list_solid,
            size: 64,
            color: DetalhesPragasDesignTokens.getSubtitleColor(context),
          ),
          const SizedBox(height: DetalhesPragasDesignTokens.largeSpacing),
          Text(
            isFiltered
                ? 'Nenhum diagnóstico encontrado'
                : 'Nenhum diagnóstico disponível',
            style: DetalhesPragasDesignTokens.cardTitleStyle.copyWith(
              color: DetalhesPragasDesignTokens.getSubtitleColor(context),
            ),
          ),
          const SizedBox(height: DetalhesPragasDesignTokens.defaultSpacing),
          Text(
            isFiltered
                ? 'Tente utilizar outros termos de busca'
                : 'Os diagnósticos aparecerão aqui quando disponíveis',
            style: DetalhesPragasDesignTokens.bodySmallStyle.copyWith(
              color: DetalhesPragasDesignTokens.getSubtitleColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            const SizedBox(height: DetalhesPragasDesignTokens.largeSpacing),
            OutlinedButton.icon(
              onPressed: () {
                _clearSearch();
                controller.filterByCultura('');
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpar filtros'),
              style: DetalhesPragasDesignTokens.outlinedButtonStyle(context),
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói a lista de diagnósticos agrupados por cultura
  Widget _buildDiagnosticosGroupedView(BuildContext context,
      DetalhesPragasController controller, List<dynamic> diagnosticos, bool isDark) {
    final diagnosticosAgrupados = _agruparPorCultura(diagnosticos);
    final culturas = diagnosticosAgrupados.keys.toList()..sort();

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: culturas.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: DetalhesPragasDesignTokens.largeSpacing),
      itemBuilder: (context, index) {
        final cultura = culturas[index];
        final diagnosticosDaCultura = diagnosticosAgrupados[cultura]!;
        return _buildCulturaSection(
            context, controller, cultura, diagnosticosDaCultura, isDark);
      },
    );
  }

  /// Agrupa diagnósticos por cultura
  Map<String, List<dynamic>> _agruparPorCultura(List<dynamic> diagnosticos) {
    final Map<String, List<dynamic>> agrupados = {};

    for (final diagnostico in diagnosticos) {
      final cultura = diagnostico['nomeCultura'] ??
          diagnostico['cultura'] ??
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
      DetalhesPragasController controller,
      String cultura,
      List<dynamic> diagnosticos,
      bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCulturaHeader(context, cultura, diagnosticos.length, isDark),
        const SizedBox(height: DetalhesPragasDesignTokens.defaultSpacing),
        _buildDiagnosticosListView(context, controller, diagnosticos, isDark),
      ],
    );
  }

  /// Constrói o cabeçalho da cultura
  Widget _buildCulturaHeader(
      BuildContext context, String cultura, int quantidade, bool isDark) {
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
      DetalhesPragasController controller, List<dynamic> diagnosticos, bool isDark) {
    // Ordena os diagnósticos alfabeticamente pelo nome do defensivo
    final diagnosticosOrdenados = List<dynamic>.from(diagnosticos);
    diagnosticosOrdenados.sort((a, b) {
      final nomeA = a['nomeDefensivo'] ?? a['defensivo'] ?? a['produto'] ?? '';
      final nomeB = b['nomeDefensivo'] ?? b['defensivo'] ?? b['produto'] ?? '';
      return nomeA.toString().toLowerCase().compareTo(nomeB.toString().toLowerCase());
    });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: diagnosticosOrdenados.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final diagnostico = diagnosticosOrdenados[index];
        return PragaDiagnosticItemWidget(
          diagnostico: diagnostico,
          controller: controller,
          isDark: isDark,
        );
      },
    );
  }

  /// Extrai as culturas únicas dos diagnósticos
  List<String> _extractCulturasFromDiagnosticos(List<dynamic> diagnosticos) {
    final culturas = <String>{};

    for (final diagnostico in diagnosticos) {
      final cultura = diagnostico['nomeCultura'] ??
          diagnostico['cultura'] ??
          diagnostico['culturaNome'] ??
          '';

      if (cultura.isNotEmpty) {
        culturas.add(cultura);
      }
    }

    final culturasList = culturas.toList();
    culturasList.sort(); // Ordenar alfabeticamente
    return culturasList;
  }
}
