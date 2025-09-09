import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/design/design_tokens.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../favoritos/domain/entities/favorito_entity.dart';
import 'detalhe_praga_page.dart';
import 'domain/entities/praga_entity.dart';
import 'models/praga_view_mode.dart';
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
  late FavoritosRepositorySimplified _favoritosRepository;

  // Cache local para status de favoritos
  final Map<String, bool> _favoritesCache = {};

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);

    // Inicializa o provider diretamente
    _pragasProvider = GetIt.instance<PragasProvider>();
    _favoritosRepository = GetIt.instance<FavoritosRepositorySimplified>();

    // Carrega favoritos iniciais
    _loadFavoritesStatus();
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
    // Recarrega favoritos após busca
    await _loadFavoritesStatus();
  }

  // Métodos de filtragem migrados para PragasProvider

  void _clearSearch() async {
    _searchDebounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
    });

    await _pragasProvider.loadPragasByTipo(_currentPragaType);
    // Recarrega favoritos após limpar busca
    await _loadFavoritesStatus();
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

    // TODO: Implementar ordenação no PragasProvider
    // Por enquanto recarrega os dados
    if (_searchText.isEmpty) {
      await _pragasProvider.loadPragasByTipo(_currentPragaType);
    } else {
      await _pragasProvider.searchPragas(_searchText);
    }
    // Recarrega favoritos após ordenação
    await _loadFavoritesStatus();
  }

  void _handleItemTap(PragaEntity praga) {
    // Usar navegação direta do Flutter - mais confiável para páginas secundárias
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.nomeComum,
          pragaScientificName: praga.nomeCientifico.isNotEmpty
              ? praga.nomeCientifico
              : 'Nome científico não disponível',
        ),
      ),
    );
  }

  /// Carrega o status de favoritos para as pragas atuais
  Future<void> _loadFavoritesStatus() async {
    if (_pragasProvider.pragas.isEmpty) return;

    for (final praga in _pragasProvider.pragas) {
      try {
        final isFavorite = await _favoritosRepository.isFavorito(
            TipoFavorito.praga, praga.idReg);
        _favoritesCache[praga.idReg] = isFavorite;
      } catch (e) {
        _favoritesCache[praga.idReg] = false;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Alterna o status de favorito para uma praga
  Future<void> _toggleFavorite(PragaEntity praga) async {
    try {
      final result = await _favoritosRepository.toggleFavorito(
          TipoFavorito.praga, praga.idReg);

      if (result) {
        // Atualiza cache local
        final currentStatus = _favoritesCache[praga.idReg] ?? false;
        _favoritesCache[praga.idReg] = !currentStatus;

        if (mounted) {
          setState(() {});
        }

        // Mostra feedback visual
        final newStatus = _favoritesCache[praga.idReg] ?? false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? '${praga.nomeComum} adicionada aos favoritos'
                    : '${praga.nomeComum} removida dos favoritos',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar favorito: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Verifica se uma praga é favorita
  bool _isFavorite(PragaEntity praga) {
    return _favoritesCache[praga.idReg] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize provider data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _pragasProvider.loadPragasByTipo(_currentPragaType);
      // Carrega favoritos após carregar as pragas
      await _loadFavoritesStatus();
    });

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: ReceitaAgroSpacing.sm),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPragasList(isDark, provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPragasList(bool isDark, PragasProvider provider) {
    if (provider.isLoading) {
      return PragasLoadingSkeletonWidget(viewMode: _viewMode, isDark: isDark);
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
      );
    }

    if (provider.pragas.isEmpty && _searchText.isEmpty) {
      return PragasEmptyStateWidget(
        pragaType: _currentPragaType,
        isDark: isDark,
      );
    }

    if (provider.pragas.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
      );
    }

    return Card(
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: EdgeInsets.zero,
      child: _viewMode.isGrid
          ? _buildGridView(isDark, provider)
          : _buildListView(isDark, provider),
    );
  }

  Widget _buildGridView(bool isDark, PragasProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        // Calcula quantas linhas teremos
        final rowCount = (provider.pragas.length / crossAxisCount).ceil();
        final itemHeight = constraints.maxWidth /
            crossAxisCount *
            (1 / 0.85); // childAspectRatio inverse
        final totalHeight = (rowCount * itemHeight) +
            ((rowCount - 1) * ReceitaAgroSpacing.sm) +
            (ReceitaAgroSpacing.sm * 2); // spacing + vertical padding only

        return SizedBox(
          height: totalHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(vertical: ReceitaAgroSpacing.sm),
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
                isFavorite: _isFavorite(praga),
                onTap: () => _handleItemTap(praga),
                onFavoriteToggle: () => _toggleFavorite(praga),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(bool isDark, PragasProvider provider) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: ReceitaAgroSpacing.xs),
      itemCount: provider.pragas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final praga = provider.pragas[index];
        return PragaCardWidget(
          praga: praga,
          mode: PragaCardMode.list,
          isDarkMode: isDark,
          isFavorite: _isFavorite(praga),
          onTap: () => _handleItemTap(praga),
          onFavoriteToggle: () => _toggleFavorite(praga),
        );
      },
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
    final total = provider.pragas.length;

    if (provider.isLoading && total == 0) {
      return 'Carregando registros...';
    }

    if (provider.errorMessage != null) {
      return 'Erro no carregamento';
    }

    return '$total registros disponíveis';
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }
}
