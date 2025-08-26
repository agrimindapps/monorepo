import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/modern_header_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPragaType = widget.pragaType ?? '1';
    _searchController.addListener(_onSearchChanged);

    // Carrega pragas usando GetIt diretamente para evitar erro de Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetIt.instance<PragasProvider>().loadPragasByTipo(_currentPragaType);
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Método migrado para PragasProvider

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

  void _performDebouncedSearch(String searchText) {
    final provider = GetIt.instance<PragasProvider>();
    if (searchText.trim().isEmpty) {
      provider.loadPragasByTipo(_currentPragaType);
    } else {
      provider.searchPragas(searchText.trim());
    }
  }

  // Métodos de filtragem migrados para PragasProvider

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
    });

    // Recarrega pragas do tipo atual
    GetIt.instance<PragasProvider>().loadPragasByTipo(_currentPragaType);
  }

  void _toggleViewMode(PragaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });

    // TODO: Implementar ordenação no PragasProvider
    // Por enquanto recarrega os dados
    final provider = GetIt.instance<PragasProvider>();
    if (_searchText.isEmpty) {
      provider.loadPragasByTipo(_currentPragaType);
    } else {
      provider.searchPragas(_searchText);
    }
  }

  void _handleItemTap(PragaEntity praga) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => DetalhePragaPage(
              pragaName: praga.nomeComum,
              pragaScientificName:
                  praga.nomeCientifico.isNotEmpty
                      ? praga.nomeCientifico
                      : 'Nome científico não disponível',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: GetIt.instance<PragasProvider>(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  Consumer<PragasProvider>(
                    builder: (context, provider, child) {
                      return _buildModernHeader(isDark, provider);
                    },
                  ),
                  Expanded(
                    child: Consumer<PragasProvider>(
                      builder: (context, provider, child) {
                        return _buildBody(isDark, provider);
                      },
                    ),
                  ),
                ],
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
      leftIcon: _getHeaderIcon(),
      rightIcon:
          _isAscending
              ? Icons.arrow_upward_outlined
              : Icons.arrow_downward_outlined,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
        child: _buildPragasList(isDark, provider),
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
          padding: const EdgeInsets.all(32),
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
          padding: const EdgeInsets.all(32),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      margin: const EdgeInsets.only(top: 4),
      child:
          _viewMode.isGrid
              ? _buildGridView(isDark, provider)
              : _buildListView(isDark, provider),
    );
  }

  Widget _buildGridView(bool isDark, PragasProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: provider.pragas.length,
          itemBuilder: (context, index) {
            final praga = provider.pragas[index];
            return PragaCardWidget(
              praga: praga,
              mode: PragaCardMode.grid,
              isDarkMode: isDark,
              isFavorite: false, // TODO: Implementar verificação de favoritos
              onTap: () => _handleItemTap(praga),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(bool isDark, PragasProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: provider.pragas.length,
      itemBuilder: (context, index) {
        final praga = provider.pragas[index];
        return PragaCardWidget(
          praga: praga,
          mode: PragaCardMode.list,
          isDarkMode: isDark,
          isFavorite: false, // TODO: Implementar verificação de favoritos
          onTap: () => _handleItemTap(praga),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
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

  IconData _getHeaderIcon() {
    switch (_currentPragaType) {
      case '1':
        return Icons.bug_report_outlined;
      case '2':
        return Icons.coronavirus_outlined;
      case '3':
        return Icons.grass_outlined;
      default:
        return Icons.pest_control_outlined;
    }
  }
}
