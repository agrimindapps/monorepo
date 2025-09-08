import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/defensivo_agrupado_item_model.dart';
import '../../models/defensivos_agrupados_view_mode.dart';
import '../providers/lista_defensivos_agrupados_provider.dart';
import '../widgets/defensivos_agrupados_header_widget.dart';
import '../widgets/defensivos_agrupados_list_widget.dart';
import '../widgets/defensivos_agrupados_search_widget.dart';

/// Clean Page para Lista de Defensivos Agrupados
/// Segue padrão das refatorações bem-sucedidas (6x)
/// Focada em performance e responsividade
class ListaDefensivosAgrupadosCleanPage extends StatefulWidget {
  final String tipoAgrupamento;
  final String? textoFiltro;

  const ListaDefensivosAgrupadosCleanPage({
    super.key,
    required this.tipoAgrupamento,
    this.textoFiltro,
  });

  @override
  State<ListaDefensivosAgrupadosCleanPage> createState() => 
      _ListaDefensivosAgrupadosCleanPageState();
}

class _ListaDefensivosAgrupadosCleanPageState 
    extends State<ListaDefensivosAgrupadosCleanPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _configureStatusBar();
    _searchController.addListener(_onSearchChanged);
    
    // Initialize provider after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
          context, 
          listen: false,
        );
        final isDark = Theme.of(context).brightness == Brightness.dark;
        provider.initialize(widget.tipoAgrupamento, isDark);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _configureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _onSearchChanged() {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    provider.updateSearchText(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    provider.clearSearch();
  }

  void _toggleViewMode(DefensivosAgrupadosViewMode mode) {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    provider.toggleViewMode(mode);
  }

  void _toggleSort() {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    provider.toggleSort();
  }


  void _handleItemTap(DefensivoAgrupadoItemModel item) {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    
    if (item.isDefensivo) {
      // Navigate to defensivo details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando para detalhes: ${item.displayTitle}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      provider.handleItemTap(item);
    }
  }

  bool _canNavigateBack() {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    return provider.canNavigateBack;
  }

  void _navigateBack() {
    final provider = Provider.of<ListaDefensivosAgrupadosProvider>(
      context, 
      listen: false,
    );
    if (provider.canNavigateBack) {
      provider.navigateBack();
      // Clear search when navigating back
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListaDefensivosAgrupadosProvider>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: provider.navigationLevel == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (_canNavigateBack()) {
                _navigateBack();
              } else if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(ListaDefensivosAgrupadosProvider provider) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              DefensivosAgrupadosHeaderWidget(
                title: provider.title.isNotEmpty ? provider.title : provider.getDefaultTitle(),
                subtitle: provider.getSubtitle(),
                leftIcon: provider.category.icon,
                rightIcon: provider.isAscending 
                    ? Icons.keyboard_arrow_up 
                    : Icons.keyboard_arrow_down,
                isDark: provider.isDark,
                showBackButton: true,
                showActions: true,
                canNavigateBack: provider.canNavigateBack,
                onBackPressed: () {
                  if (_canNavigateBack()) {
                    _navigateBack();
                  } else if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                onRightIconPressed: _toggleSort,
              ),
              DefensivosAgrupadosSearchWidget(
                controller: _searchController,
                isDark: provider.isDark,
                isSearching: provider.isSearching,
                selectedViewMode: provider.selectedViewMode,
                searchHint: provider.getSearchHint(),
                onToggleViewMode: _toggleViewMode,
                onClear: _clearSearch,
              ),
              DefensivosAgrupadosListWidget(
                state: provider.state,
                category: provider.category,
                scrollController: _scrollController,
                onItemTap: _handleItemTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}