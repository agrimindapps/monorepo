import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'data/praga_view_mode.dart';
import 'domain/entities/praga_entity.dart';
import 'presentation/pages/detalhe_praga_page.dart';
import 'presentation/providers/pragas_notifier.dart';
import 'presentation/providers/pragas_state.dart';
import 'widgets/praga_card_widget.dart';
import 'widgets/praga_search_field_widget.dart';
import 'widgets/pragas_empty_state_widget.dart';
import 'widgets/pragas_loading_skeleton_widget.dart';

class ListaPragasPage extends ConsumerStatefulWidget {
  final String? pragaType;

  const ListaPragasPage({super.key, this.pragaType});

  @override
  ConsumerState<ListaPragasPage> createState() => _ListaPragasPageState();
}

class _ListaPragasPageState extends ConsumerState<ListaPragasPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  bool _isAscending = true;
  PragaViewMode _viewMode = PragaViewMode.grid;
  String _searchText = '';
  late String _currentPragaType;

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(pragasProvider.notifier);
      try {
        await notifier.loadStats();
        await notifier.loadPragasByTipo(_currentPragaType);
      } catch (e) {
        // Erro já é tratado pelo notifier - não precisamos fazer nada aqui
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();

    final searchText = _searchController.text;

    setState(() {
      _searchText = searchText;
    });

    _searchDebounceTimer = Timer(const Duration(milliseconds: 700), () {
      _performDebouncedSearch(searchText);
    });
  }

  void _performDebouncedSearch(String searchText) async {
    final notifier = ref.read(pragasProvider.notifier);
    if (searchText.trim().isEmpty) {
      await notifier.loadPragasByTipo(_currentPragaType);
    } else {
      await notifier.searchPragas(searchText.trim());
    }
  }

  void _clearSearch() async {
    _searchDebounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
    });

    final notifier = ref.read(pragasProvider.notifier);
    await notifier.loadPragasByTipo(_currentPragaType);
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
    final notifier = ref.read(pragasProvider.notifier);
    notifier.sortPragas(_isAscending);
  }

  void _handleItemTap(PragaEntity praga) {
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
    final pragasState = ref.watch(pragasProvider);

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: pragasState.when(
                  data: (state) => Column(
                    children: [
                      _buildModernHeader(isDark, state),
                      Expanded(child: _buildBody(isDark, state)),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Erro: $error')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark, PragasState state) {
    return ModernHeaderWidget(
      title: _getHeaderTitle(),
      subtitle: _getHeaderSubtitle(state),
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

  Widget _buildBody(bool isDark, PragasState state) {
    return Column(
      children: [
        _buildSearchField(isDark),
        Expanded(child: _buildContent(isDark, state)),
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

  Widget _buildContent(bool isDark, PragasState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ReceitaAgroSpacing.sm),
        Expanded(
          // CustomScrollView com slivers permite virtual scroll nativo
          // Os itens são renderizados apenas quando visíveis na viewport
          child: CustomScrollView(
            // Melhora performance de scroll
            physics: const BouncingScrollPhysics(),
            slivers: [_buildPragasSliver(isDark, state)],
          ),
        ),
      ],
    );
  }

  Widget _buildPragasSliver(bool isDark, PragasState state) {
    if (state.isLoading) {
      return SliverToBoxAdapter(
        child: PragasLoadingSkeletonWidget(viewMode: _viewMode, isDark: isDark),
      );
    }

    if (state.errorMessage != null) {
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
                  state.errorMessage!,
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

    if (state.pragas.isEmpty && _searchText.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: PragasEmptyStateWidget(
          pragaType: _currentPragaType,
          isDark: isDark,
        ),
      );
    }

    if (state.pragas.isEmpty && _searchText.isNotEmpty) {
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
        ? _buildVirtualGrid(isDark, state)
        : _buildVirtualList(isDark, state);
  }
  
  /// Grid virtualizado - renderiza apenas itens visíveis
  Widget _buildVirtualGrid(bool isDark, PragasState state) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.crossAxisExtent);
        
        return SliverPadding(
          padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: ReceitaAgroSpacing.sm,
              mainAxisSpacing: ReceitaAgroSpacing.sm,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final praga = state.pragas[index];
                return RepaintBoundary(
                  child: PragaCardWidget(
                    key: ValueKey('praga_${praga.idReg}_vgrid'),
                    praga: praga,
                    mode: PragaCardMode.grid,
                    isDarkMode: isDark,
                    onTap: () => _handleItemTap(praga),
                  ),
                );
              },
              childCount: state.pragas.length,
              // Adiciona extent para otimização do layout
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false, // Já adicionamos manualmente
            ),
          ),
        );
      },
    );
  }
  
  /// Lista virtualizada - renderiza apenas itens visíveis
  Widget _buildVirtualList(bool isDark, PragasState state) {
    const itemHeight = 96.0; // Altura aproximada do card em modo lista
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: ReceitaAgroSpacing.sm),
      sliver: SliverFixedExtentList(
        itemExtent: itemHeight,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final praga = state.pragas[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RepaintBoundary(
                child: PragaCardWidget(
                  key: ValueKey('praga_${praga.idReg}_vlist'),
                  praga: praga,
                  mode: PragaCardMode.list,
                  isDarkMode: isDark,
                  onTap: () => _handleItemTap(praga),
                ),
              ),
            );
          },
          childCount: state.pragas.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
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

  String _getHeaderSubtitle(PragasState state) {
    if (state.isLoading && state.pragas.isEmpty) {
      return 'Carregando registros...';
    }

    if (state.errorMessage != null) {
      return 'Erro no carregamento';
    }

    return '${state.pragas.length} registros encontrados';
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }
}
