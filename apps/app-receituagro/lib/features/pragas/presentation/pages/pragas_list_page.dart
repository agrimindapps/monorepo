import 'dart:async';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:core/core.dart';

import '../providers/pragas_provider.dart';

/// Página de listagem de pragas (Presentation Layer)
/// Princípio: Single Responsibility - Apenas exibe lista de pragas
class PragasListPage extends StatelessWidget {
  final String? filtroTipo;
  final String? culturaId;

  const PragasListPage({
    super.key,
    this.filtroTipo,
    this.culturaId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.instance<PragasProvider>(),
      child: PragasListView(
        filtroTipo: filtroTipo,
        culturaId: culturaId,
      ),
    );
  }
}

class PragasListView extends StatefulWidget {
  final String? filtroTipo;
  final String? culturaId;

  const PragasListView({
    super.key,
    this.filtroTipo,
    this.culturaId,
  });

  @override
  State<PragasListView> createState() => _PragasListViewState();
}

class _PragasListViewState extends State<PragasListView> {
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = '';
  Timer? _debounceTimer;
  String _lastSearchTerm = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filtroTipo ?? '';
    
    // Inicia o loading imediatamente para evitar flash do empty state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PragasProvider>();
      provider.startInitialLoading();
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<PragasProvider>();
    
    try {
      if (widget.culturaId != null) {
        await provider.loadPragasByCultura(widget.culturaId!);
      } else if (widget.filtroTipo != null) {
        await provider.loadPragasByTipo(widget.filtroTipo!);
      } else {
        await provider.loadAllPragas();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  void _onSearchChanged(String searchTerm) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set loading state immediately for better UX
    if (searchTerm.trim() != _lastSearchTerm) {
      setState(() {
        _isSearching = searchTerm.trim().isNotEmpty;
      });
    }
    
    // Debounce the search with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(searchTerm);
    });
  }
  
  Future<void> _executeSearch(String searchTerm) async {
    final trimmedTerm = searchTerm.trim();
    
    // Skip if the search term hasn't changed
    if (trimmedTerm == _lastSearchTerm) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    
    _lastSearchTerm = trimmedTerm;
    final provider = context.read<PragasProvider>();
    
    try {
      if (trimmedTerm.isEmpty) {
        // Clear search and reload initial data
        await _loadInitialData();
      } else {
        // Perform search with error handling
        await provider.searchPragas(trimmedTerm);
      }
    } catch (e) {
      // Error is handled by provider, just log it
      debugPrint('Search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _onFilterChanged(String filter) async {
    setState(() {
      _currentFilter = filter;
      _isSearching = false;
    });
    
    // Cancel any pending search
    _debounceTimer?.cancel();
    _lastSearchTerm = '';
    
    final provider = context.read<PragasProvider>();
    _searchController.clear();
    
    try {
      if (filter.isEmpty) {
        await provider.loadAllPragas();
      } else {
        await provider.loadPragasByTipo(filter);
      }
    } catch (e) {
      debugPrint('Error changing filter: $e');
    }
  }

  void _onPragaSelected(String pragaId) {
    // Navegar para página de detalhes
    Navigator.pushNamed(
      context,
      '/praga-details',
      arguments: pragaId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cabeçalho com busca e filtros
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search field with loading indicator
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar pragas...',
                    prefixIcon: _isSearching 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.culturaId == null) // Só mostra filtros se não é por cultura
                  _buildFilterChips(),
              ],
            ),
          ),
          
          // Lista de pragas
          Expanded(
            child: Consumer<PragasProvider>(
              builder: (context, provider, child) {
                return _buildPragasList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPragasList(PragasProvider provider) {
    // Show search loading overlay if searching
    if (_isSearching && provider.viewState != PragasViewState.loading) {
      return Stack(
        children: [
          _buildPragasContent(provider),
          ColoredBox(
            color: Colors.white.withValues(alpha: 0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }
    
    return _buildPragasContent(provider);
  }
  
  Widget _buildPragasContent(PragasProvider provider) {
    switch (provider.viewState) {
      case PragasViewState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
        
      case PragasViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar pragas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  provider.clearError();
                  await _loadInitialData();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
        
      case PragasViewState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _getEmptyMessage(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Tente ajustar os filtros ou busca',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
        
      case PragasViewState.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            await _loadInitialData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.pragas.length,
            itemBuilder: (context, index) {
              final praga = provider.pragas[index];
              // TODO: Implementar widget PragaListItem
              return ListTile(
                title: Text(praga.nomeComum),
                subtitle: Text(praga.nomeCientifico),
                onTap: () => _onPragaSelected(praga.idReg),
              );
            },
          ),
        );
        
      case PragasViewState.initial:
        return const SizedBox.shrink();
    }
  }

  String _getPageTitle() {
    if (widget.culturaId != null) {
      return 'Pragas da Cultura';
    }
    
    switch (widget.filtroTipo) {
      case '1': return 'Insetos';
      case '2': return 'Doenças';
      case '3': return 'Plantas Daninhas';
      default: return 'Pragas';
    }
  }

  String _getEmptyMessage() {
    if (_searchController.text.trim().isNotEmpty) {
      return 'Nenhuma praga encontrada';
    }
    
    switch (_currentFilter) {
      case '1': return 'Nenhum inseto encontrado';
      case '2': return 'Nenhuma doença encontrada';
      case '3': return 'Nenhuma planta daninha encontrada';
      default: return 'Nenhuma praga encontrada';
    }
  }
  
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Todos', 'value': ''},
      {'label': 'Insetos', 'value': '1'},
      {'label': 'Doenças', 'value': '2'},
      {'label': 'Plantas Daninhas', 'value': '3'},
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _currentFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onFilterChanged(filter['value']!);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}