// ignore_for_file: library_private_types_in_public_api, dangling_library_doc_comments

/// EXEMPLO DE INTEGRAÇÃO - Sistema de Favoritos Refatorado
/// Este arquivo demonstra como usar todos os componentes melhorados

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports dos novos componentes
import '../events/favorito_event_bus.dart';
import '../events/favorito_events.dart';
import '../presentation/providers/favoritos_provider_optimized.dart';
import '../providers/specialized_providers.dart';
import '../widgets/enhanced_favorite_button.dart';
import '../widgets/enhanced_loading_states.dart';

/// EXEMPLO 1: Página de Favoritos Otimizada
class ExampleFavoritosPageOptimized extends StatefulWidget {
  const ExampleFavoritosPageOptimized({super.key});

  @override
  State<ExampleFavoritosPageOptimized> createState() => _ExampleFavoritosPageOptimizedState();
}

class _ExampleFavoritosPageOptimizedState extends State<ExampleFavoritosPageOptimized>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late FavoritosProviderOptimized _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializa provider otimizado
    _provider = FavoritosProviderOptimized(
      repository: context.read(), // Assume DI configurado
    );
    
    // Inicializa performance manager
    _provider.initPerformanceManager(context.read());
    
    // Carrega dados iniciais
    _provider.initialize();
    
    // Escuta mudanças de tab
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    const tabs = ['defensivos', 'pragas', 'diagnosticos'];
    final newTab = tabs[_tabController.index];
    
    _provider.changeTab(newTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favoritos'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Defensivos'),
              Tab(text: 'Pragas'),
              Tab(text: 'Diagnósticos'),
            ],
          ),
        ),
        body: Consumer<FavoritosProviderOptimized>(
          builder: (context, provider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('defensivos', provider),
                _buildTabContent('pragas', provider),
                _buildTabContent('diagnosticos', provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(String tipo, FavoritosProviderOptimized provider) {
    // Usa enhanced loading states com transições suaves
    return FavoritoLoadingStates.stateTransitionBuilder(
      isLoading: provider.isLoadingType(tipo),
      hasError: provider.getErrorForType(tipo) != null,
      isEmpty: !provider.hasTypeWithFavoritos(tipo),
      
      // Loading skeleton específico
      loadingWidget: FavoritoLoadingStates.favoritoListSkeleton(
        itemCount: 3,
      ),
      
      // Error state com retry
      errorWidget: FavoritoLoadingStates.enhancedErrorState(
        title: 'Erro ao carregar favoritos',
        subtitle: provider.getErrorForType(tipo) ?? 'Erro desconhecido',
        onRetry: () => provider.reloadType(tipo),
      ),
      
      // Empty state animado
      emptyWidget: FavoritoLoadingStates.enhancedEmptyState(
        title: 'Nenhum favorito ainda',
        subtitle: 'Items favoritos aparecerão aqui',
        icon: Icons.favorite_border,
      ),
      
      // Conteúdo principal
      contentWidget: RefreshIndicator(
        onRefresh: () => provider.reloadType(tipo),
        child: ListView.builder(
          itemCount: provider.getFavoritosByTipo(tipo).length,
          itemBuilder: (context, index) {
            final favorito = provider.getFavoritosByTipo(tipo)[index];
            // Converte para Map para compatibilidade com o card
            final favoritoMap = {
              'id': favorito.id,
              'tipo': favorito.tipo,
              'nomeDisplay': favorito.nomeDisplay,
            };
            return _buildFavoritoCard(favoritoMap, provider);
          },
        ),
      ),
    );
  }

  Widget _buildFavoritoCard(Map<String, dynamic> favorito, FavoritosProviderOptimized provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.shield), // Ícone baseado no tipo
        title: Text(favorito['nomeDisplay']?.toString() ?? 'Sem nome'),
        subtitle: Text('Adicionado em ${DateTime.now().toString()}'), // Exemplo
        trailing: FavoriteListButton(
          isFavorite: true, // Sempre true na lista de favoritos
          itemName: favorito['nomeDisplay']?.toString() ?? 'Item',
          onPressed: () => _removeFavorite(favorito, provider),
        ),
        onTap: () => _navigateToDetails(favorito),
      ),
    );
  }

  void _removeFavorite(Map<String, dynamic> favorito, FavoritosProviderOptimized provider) async {
    final success = await provider.removeFavorito(favorito['tipo']?.toString() ?? '', favorito['id']?.toString() ?? '');
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${favorito['nomeDisplay']?.toString() ?? 'Item'} removido dos favoritos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToDetails(Map<String, dynamic> favorito) {
    // Navegar para página de detalhes
  }
}

/// EXEMPLO 2: Página de Detalhes com Provider Especializado
class ExampleDetalhePragaPage extends StatefulWidget {
  final String pragaId;
  final String pragaName;

  const ExampleDetalhePragaPage({
    super.key,
    required this.pragaId,
    required this.pragaName,
  });

  @override
  State<ExampleDetalhePragaPage> createState() => _ExampleDetalhePragaPageState();
}

class _ExampleDetalhePragaPageState extends State<ExampleDetalhePragaPage> {
  late PragaFavoritoProvider _favoritoProvider;

  @override
  void initState() {
    super.initState();
    
    // Inicializa provider especializado
    _favoritoProvider = PragaFavoritoProvider();
    _favoritoProvider.initialize(widget.pragaId, {
      'nome': widget.pragaName,
      'tipo': 'praga',
    });
  }

  @override
  void dispose() {
    _favoritoProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _favoritoProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pragaName),
          actions: [
            Consumer<PragaFavoritoProvider>(
              builder: (context, provider, child) {
                return FavoriteDetailButton(
                  isFavorite: provider.isFavorited,
                  isLoading: provider.isLoading,
                  itemName: widget.pragaName,
                  onPressed: _toggleFavorite,
                );
              },
            ),
          ],
        ),
        body: Consumer<PragaFavoritoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Conteúdo principal da página
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Detalhes da praga aqui
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Text('Detalhes da praga: ${widget.pragaName}'),
                        ),
                        
                        // Outros widgets...
                      ],
                    ),
                  ),
                ),
                
                // Botão de ação principal
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: FavoriteFAB(
                    isFavorite: provider.isFavorited,
                    isLoading: provider.isLoading,
                    label: provider.isFavorited ? 'Remover dos Favoritos' : 'Adicionar aos Favoritos',
                    onPressed: _toggleFavorite,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleFavorite() async {
    final success = await _favoritoProvider.toggleFavorito();
    
    if (success && mounted) {
      final message = _favoritoProvider.isFavorited
          ? 'Adicionado aos favoritos'
          : 'Removido dos favoritos';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_favoritoProvider.errorMessage ?? 'Erro ao alterar favorito'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// EXEMPLO 3: Provider com Restrição Premium
class ExampleDiagnosticoDetailsPage extends StatefulWidget {
  final String diagnosticoId;
  final String diagnosticoName;

  const ExampleDiagnosticoDetailsPage({
    super.key,
    required this.diagnosticoId,
    required this.diagnosticoName,
  });

  @override
  State<ExampleDiagnosticoDetailsPage> createState() => _ExampleDiagnosticoDetailsPageState();
}

class _ExampleDiagnosticoDetailsPageState extends State<ExampleDiagnosticoDetailsPage> {
  late DiagnosticoFavoritoProvider _favoritoProvider;

  @override
  void initState() {
    super.initState();
    
    _favoritoProvider = DiagnosticoFavoritoProvider();
    _favoritoProvider.initialize(widget.diagnosticoId, {
      'nome': widget.diagnosticoName,
      'tipo': 'diagnostico',
    });
  }

  @override
  void dispose() {
    _favoritoProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _favoritoProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.diagnosticoName),
          actions: [
            Consumer<DiagnosticoFavoritoProvider>(
              builder: (context, provider, child) {
                // Só mostra botão se é premium
                if (!provider.canFavorite()) {
                  return IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: () => _showPremiumDialog(),
                    tooltip: 'Requer Premium',
                  );
                }

                return FavoriteDetailButton(
                  isFavorite: provider.isFavorited,
                  isLoading: provider.isLoading,
                  itemName: widget.diagnosticoName,
                  onPressed: _toggleFavorite,
                );
              },
            ),
          ],
        ),
        body: Consumer<DiagnosticoFavoritoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Premium banner se necessário
                if (!provider.isPremium)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.amber.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Favoritar diagnósticos é exclusivo para usuários Premium',
                            style: TextStyle(color: Colors.amber.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Conteúdo principal
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Detalhes do diagnóstico: ${widget.diagnosticoName}'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleFavorite() async {
    final success = await _favoritoProvider.toggleFavorito();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorito atualizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPremiumDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: const Text('Favoritar diagnósticos é uma funcionalidade exclusiva para usuários Premium.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para tela de upgrade
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

/// EXEMPLO 4: Event Listener Global
class GlobalFavoritoListener extends StatefulWidget {
  final Widget child;

  const GlobalFavoritoListener({super.key, required this.child});

  @override
  State<GlobalFavoritoListener> createState() => _GlobalFavoritoListenerState();
}

class _GlobalFavoritoListenerState extends State<GlobalFavoritoListener>
    with FavoritoEventListener {

  @override
  void initState() {
    super.initState();
    
    // Escuta eventos globais para analytics, notificações, etc.
    listenToFavoritoEvents((event) {
      if (event is FavoritoAdded) {
        debugPrint('📊 [Analytics] Favorito adicionado: ${event.tipo}:${event.itemId}');
        // Enviar para analytics
      } else if (event is FavoritoRemoved) {
        debugPrint('📊 [Analytics] Favorito removido: ${event.tipo}:${event.itemId}');
        // Enviar para analytics
      } else if (event is FavoritoError) {
        debugPrint('⚠️ [Monitoring] Erro de favorito: ${event.errorMessage}');
        // Enviar para monitoring/crashlytics
      }
    });
  }

  @override
  void dispose() {
    disposeEventListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// EXEMPLO DE INICIALIZAÇÃO NO MAIN
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GlobalFavoritoListener(
        child: ExampleFavoritosPageOptimized(),
      ),
    );
  }
}