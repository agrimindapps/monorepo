import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/cultura_hive.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../pragas/lista_pragas_por_cultura_page.dart';
import 'domain/entities/cultura_entity.dart';
import 'models/cultura_view_mode.dart';
import 'presentation/providers/culturas_provider.dart';
import 'widgets/cultura_item_widget.dart';
import 'widgets/cultura_search_field.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/loading_skeleton_widget.dart';

class ListaCulturasPage extends StatefulWidget {
  const ListaCulturasPage({super.key});

  @override
  State<ListaCulturasPage> createState() => _ListaCulturasPageState();
}

class _ListaCulturasPageState extends State<ListaCulturasPage> {
  final TextEditingController _searchController = TextEditingController();
  // ARCHITECTURAL FIX: Removed direct repository access, using Provider pattern
  // Fix para conflito arquitetural - substituído acesso direto por Provider
  bool _isAscending = true;
  CulturaViewMode _viewMode = CulturaViewMode.list;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // ARCHITECTURAL FIX: Initialize provider using Clean Architecture pattern
    // Inicialização seguindo padrão Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CulturasProvider>().loadActiveCulturas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ARCHITECTURAL FIX: Removed direct repository method
  // Método removido - dados agora vêm via Provider

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    
    final searchText = _searchController.text;
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // ARCHITECTURAL FIX: Using Provider pattern for search
      // Usando Provider para busca ao invés de manipulação local
      final provider = context.read<CulturasProvider>();
      if (searchText.trim().isEmpty) {
        provider.loadActiveCulturas();
      } else {
        provider.searchByPattern(searchText.trim());
      }
    });
  }

  // ARCHITECTURAL FIX: Removed performSearch method
  // Método removido - busca agora via Provider

  void _clearSearch() {
    _searchController.clear();
    // ARCHITECTURAL FIX: Using Provider to clear search
    // Usando Provider para limpar busca
    context.read<CulturasProvider>().loadActiveCulturas();
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });
    // ARCHITECTURAL FIX: Sorting handled by provider
    // TODO: Implement sorting in CulturasProvider
    // Por enquanto recarrega os dados
    if (_searchController.text.isEmpty) {
      context.read<CulturasProvider>().loadActiveCulturas();
    } else {
      context.read<CulturasProvider>().searchByPattern(_searchController.text);
    }
  }

  void _toggleViewMode(CulturaViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _onCulturaTap(CulturaEntity cultura) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ListaPragasPorCulturaPage(
          culturaId: cultura.id,
          culturaNome: cultura.nome,
        ),
      ),
    );
  }

  String _getHeaderSubtitle(CulturasProvider provider) {
    final total = provider.culturas.length;

    if (provider.isLoading && total == 0) {
      return 'Carregando culturas...';
    }
    
    if (provider.hasError) {
      return 'Erro no carregamento';
    }

    return '$total culturas disponíveis';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ARCHITECTURAL FIX: Using Provider pattern with ChangeNotifierProvider
    // Implementação seguindo padrão Provider estabelecido
    return ChangeNotifierProvider.value(
      value: sl<CulturasProvider>(),
      child: Scaffold(
        body: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Consumer<CulturasProvider>(
                  builder: (context, provider, child) {
                    return ModernHeaderWidget(
                      title: 'Culturas',
                      subtitle: _getHeaderSubtitle(provider),
                      leftIcon: Icons.agriculture_outlined,
                      rightIcon: _isAscending
                          ? Icons.arrow_upward_outlined
                          : Icons.arrow_downward_outlined,
                      isDark: isDark,
                      showBackButton: true,
                      showActions: true,
                      onBackPressed: () => Navigator.of(context).pop(),
                      onRightIconPressed: _toggleSort,
                    );
                  },
                ),
                CulturaSearchField(
                  controller: _searchController,
                  isDark: isDark,
                  viewMode: _viewMode,
                  onViewModeChanged: _toggleViewMode,
                  isSearching: false, // Controlled by provider now
                  onClear: _clearSearch,
                  onSubmitted: () {
                    final provider = context.read<CulturasProvider>();
                    provider.searchByPattern(_searchController.text);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Card(
                      elevation: 2,
                      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Consumer<CulturasProvider>(
                        builder: (context, provider, child) {
                          return _buildContent(isDark, provider);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, CulturasProvider provider) {
    // ARCHITECTURAL FIX: Using provider state instead of local state
    if (provider.isLoading) {
      return LoadingSkeletonWidget(isDark: isDark);
    } else if (provider.hasError) {
      return EmptyStateWidget(
        isDark: isDark,
        message: 'Erro ao carregar culturas',
        subtitle: provider.errorMessage,
      );
    } else if (provider.culturas.isEmpty) {
      return EmptyStateWidget(
        isDark: isDark,
        message: _searchController.text.isNotEmpty
            ? 'Nenhuma cultura encontrada'
            : 'Nenhuma cultura disponível',
        subtitle: _searchController.text.isNotEmpty
            ? 'Tente ajustar os termos da busca'
            : 'Verifique se os dados foram carregados',
      );
    } else {
      return _viewMode.isGrid
          ? _buildGridView(isDark, provider)
          : _buildListView(isDark, provider);
    }
  }

  Widget _buildListView(bool isDark, CulturasProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.culturas.length,
      itemBuilder: (context, index) {
        final cultura = provider.culturas[index];
        // ARCHITECTURAL FIX: Need to convert CulturaEntity to CulturaHive for widget compatibility
        // TODO: Update CulturaItemWidget to work with CulturaEntity or create adapter
        return CulturaItemWidget(
          cultura: _convertEntityToHive(cultura),
          isDark: isDark,
          mode: CulturaItemMode.list,
          onTap: () => _onCulturaTap(cultura),
        );
      },
    );
  }

  Widget _buildGridView(bool isDark, CulturasProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: provider.culturas.length,
          itemBuilder: (context, index) {
            final cultura = provider.culturas[index];
            return CulturaItemWidget(
              cultura: _convertEntityToHive(cultura),
              isDark: isDark,
              mode: CulturaItemMode.grid,
              onTap: () => _onCulturaTap(cultura),
            );
          },
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

  // ARCHITECTURAL FIX: Temporary adapter method
  // Método adaptador temporário para compatibilidade com widgets existentes
  CulturaHive _convertEntityToHive(CulturaEntity entity) {
    return CulturaHive(
      objectId: entity.id,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idReg: entity.id,
      cultura: entity.nome,
    );
  }
}