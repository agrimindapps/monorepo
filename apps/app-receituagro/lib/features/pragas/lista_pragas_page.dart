import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'domain/entities/praga_entity.dart';
import 'presentation/pages/detalhe_praga_page.dart';
import 'domain/usecases/get_pragas_usecase.dart';
import 'data/praga_view_mode.dart';
import 'presentation/providers/pragas_provider.dart';
import 'widgets/praga_card_widget.dart';
import 'widgets/praga_search_field_widget.dart';
import 'widgets/pragas_empty_state_widget.dart';
import 'widgets/pragas_loading_skeleton_widget.dart';

class ListaPragasPage extends StatefulWidget {
  final String? pragaType;

  const ListaPragasPage({super.key, this.pragaType});

  @override
  State<ListaPragasPage> createState() => _ListaPragasPageState();
}

class _ListaPragasPageState extends State<ListaPragasPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  String _searchText = '';
  late String _currentPragaType;
  late PragasProvider _pragasProvider;

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);

    // Inicializa o provider diretamente
    _pragasProvider = GetIt.instance<PragasProvider>();

    // Inicialização única e ordenada
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _pragasProvider.loadStats();
        await _pragasProvider.loadPragasByTipo(_currentPragaType);
      } catch (e) {
        // Erro será tratado pelo provider
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    // Limpa dados do provider para evitar memory leaks
    _pragasProvider.clear();

    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();

    final searchText = _searchController.text;

    setState(() {
      _searchText = searchText;
    });

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) async {
    if (searchText.trim().isEmpty) {
      await _pragasProvider.loadPragasByTipo(_currentPragaType);
    } else {
      await _pragasProvider.searchPragas(searchText.trim());
    }
  }

  // Métodos de filtragem migrados para PragasProvider

  void _clearSearch() async {
    _searchDebounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
    });

    await _pragasProvider.loadPragasByTipo(_currentPragaType);
  }

  void _toggleViewMode(PragaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleSort() async {
    setState(() {
      _isAscending = !_isAscending;
    });

    // Aplica ordenação diretamente na lista atual
    _pragasProvider.sortPragas(_isAscending);
  }

  void _handleItemTap(PragaEntity praga) {
    // Usar navegação direta do Flutter - mais confiável para páginas secundárias
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.nomeComum,
          pragaId: praga.idReg, // Use ID for better precision
          pragaScientificName: praga.nomeCientifico.isNotEmpty
              ? praga.nomeCientifico
              : 'Nome científico não disponível',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pragasProvider,
                      builder: (context, child) {
                        return _buildModernHeader(isDark, _pragasProvider);
                      },
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _pragasProvider,
                        builder: (context, child) {
                          return _buildBody(isDark, _pragasProvider);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark, PragasProvider provider) {
    return ModernHeaderWidget(
      title: _getHeaderTitle(),
      subtitle: _getHeaderSubtitle(provider),
      leftIcon: Icons.pest_control_outlined,
      rightIcon: _isAscending
          ? Icons.arrow_upward_outlined
          : Icons.arrow_downward_outlined,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      onRightIconPressed: _toggleSort,
    );
  }

  Widget _buildBody(bool isDark, PragasProvider provider) {
    return Column(
      children: [
        _buildSearchField(isDark),
        Expanded(child: _buildContent(isDark, provider)),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return PragaSearchFieldWidget(
      controller: _searchController,
      pragaType: _currentPragaType,
      isDark: isDark,
      viewMode: _viewMode,
      onViewModeChanged: _toggleViewMode,
      onClear: _clearSearch,
      onChanged: (value) {},
    );
  }

  Widget _buildContent(bool isDark, PragasProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ReceitaAgroSpacing.sm),
        Expanded(
          child: CustomScrollView(
            slivers: [
              _buildPragasSliver(isDark, provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPragasSliver(bool isDark, PragasProvider provider) {
    if (provider.isLoading) {
      return SliverToBoxAdapter(
        child: PragasLoadingSkeletonWidget(viewMode: _viewMode, isDark: isDark),
      );
    }

    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark ? Colors.red.shade400 : Colors.red.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar pragas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.pragas.isEmpty && _searchText.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: PragasEmptyStateWidget(
          pragaType: _currentPragaType,
          isDark: isDark,
        ),
      );
    }

    if (provider.pragas.isEmpty && _searchText.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum resultado encontrado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tente usar outros termos de busca',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _viewMode.isGrid
        ? _buildSliverGrid(isDark, provider)
        : _buildSliverList(isDark, provider);
  }

  Widget _buildSliverGrid(bool isDark, PragasProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.all(0),
      sliver: SliverToBoxAdapter(
        child: Card(
          elevation: ReceitaAgroElevation.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          ),
          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
          margin: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  _calculateCrossAxisCount(constraints.maxWidth);

              return CustomScrollView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: ReceitaAgroSpacing.sm,
                        mainAxisSpacing: ReceitaAgroSpacing.sm,
                      ),
                      itemCount: provider.pragas.length,
                      itemBuilder: (context, index) {
                        final praga = provider.pragas[index];
                        return PragaCardWidget(
                          praga: praga,
                          mode: PragaCardMode.grid,
                          isDarkMode: isDark,
                          onTap: () => _handleItemTap(praga),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliverList(bool isDark, PragasProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.all(0),
      sliver: SliverToBoxAdapter(
        child: Card(
          elevation: ReceitaAgroElevation.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          ),
          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
          margin: EdgeInsets.zero,
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(0),
                sliver: SliverList.separated(
                  itemCount: provider.pragas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final praga = provider.pragas[index];
                    return PragaCardWidget(
                      praga: praga,
                      mode: PragaCardMode.list,
                      isDarkMode: isDark,
                      onTap: () => _handleItemTap(praga),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_currentPragaType) {
      case '1':
        return 'Insetos';
      case '2':
        return 'Doenças';
      case '3':
        return 'Plantas Daninhas';
      default:
        return 'Pragas';
    }
  }

  String _getHeaderSubtitle(PragasProvider provider) {
    if (provider.isLoading && provider.pragas.isEmpty) {
      return 'Carregando registros...';
    }

    if (provider.errorMessage != null) {
      return 'Erro no carregamento';
    }

    // Usa as estatísticas da sessão em vez do count filtrado
    final stats = provider.stats;
    if (stats != null) {
      final totalSessao = _getTotalPorTipo(stats);
      return '$totalSessao registros na sessão';
    }

    // Fallback caso stats não esteja carregado
    return 'Carregando estatísticas...';
  }

  /// Retorna o total de registros do tipo atual baseado nas estatísticas da sessão
  int _getTotalPorTipo(PragasStats stats) {
    switch (_currentPragaType) {
      case '1': // Insetos
        return stats.insetos;
      case '2': // Doenças
        return stats.doencas;
      case '3': // Plantas Daninhas
        return stats.plantas;
      default:
        return stats.total; // Total geral
    }
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }
}
