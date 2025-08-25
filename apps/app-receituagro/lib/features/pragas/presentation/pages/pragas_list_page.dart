import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../providers/pragas_provider.dart';
// TODO: Criar widgets de UI quando necessário
// import '../widgets/praga_list_item.dart';
// import '../widgets/pragas_search_field.dart';
// import '../widgets/pragas_filter_chips.dart';

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

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filtroTipo ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<PragasProvider>();
    
    if (widget.culturaId != null) {
      provider.loadPragasByCultura(widget.culturaId!);
    } else if (widget.filtroTipo != null) {
      provider.loadPragasByTipo(widget.filtroTipo!);
    } else {
      provider.loadAllPragas();
    }
  }

  void _onSearchChanged(String searchTerm) {
    final provider = context.read<PragasProvider>();
    
    if (searchTerm.trim().isEmpty) {
      _loadInitialData();
    } else {
      provider.searchPragas(searchTerm);
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _currentFilter = filter;
    });
    
    final provider = context.read<PragasProvider>();
    _searchController.clear();
    
    if (filter.isEmpty) {
      provider.loadAllPragas();
    } else {
      provider.loadPragasByTipo(filter);
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // TODO: Implementar widgets de busca e filtro
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Buscar pragas...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.culturaId == null) // Só mostra filtros se não é por cultura
                  // TODO: Implementar chips de filtro
                  const SizedBox.shrink(),
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
                onPressed: () {
                  provider.clearError();
                  _loadInitialData();
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
            _loadInitialData();
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
}