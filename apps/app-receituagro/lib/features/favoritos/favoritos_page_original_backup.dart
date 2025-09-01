import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart';
import '../../core/interfaces/i_premium_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/praga_image_widget.dart';
import 'domain/entities/favorito_entity.dart';
import 'favoritos_di.dart';
import 'presentation/providers/favoritos_provider_simplified.dart';

/// Favoritos Page refatorada para usar Clean Architecture com Provider
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  static _FavoritosPageState? _currentState;

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();

  /// Método estático para recarregar a página quando estiver ativa
  static void reloadIfActive() {
    _currentState?._reloadFavoritos();
  }
}

class _FavoritosPageState extends State<FavoritosPage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late TabController _tabController;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FavoritosPage._currentState = this;
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // Inicialização será feita pelo Provider quando criado
    // Removido acesso direto ao context.read aqui para evitar race condition
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      // Recarrega favoritos quando o app volta ao primeiro plano
      _reloadFavoritos();
    }
  }

  @override
  void dispose() {
    if (FavoritosPage._currentState == this) {
      FavoritosPage._currentState = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _reloadFavoritos() {
    final provider = FavoritosDI.get<FavoritosProviderSimplified>();
    provider.loadAllFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    final provider = FavoritosDI.get<FavoritosProviderSimplified>();
    
    // Marca como inicializado após o primeiro build
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Inicializa de forma assíncrona
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.initialize();
      });
    }
    
    return ChangeNotifierProvider.value(
      // ARCHITECTURAL FIX: Use Provider.value to avoid race conditions
      // Provider já está instanciado e inicializado pelo DI simplificado
      value: provider,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(context, isDark),
              const SizedBox(height: 20),
              _buildTabBar(),
              Expanded(
                child: Consumer<FavoritosProviderSimplified>(
                  builder: (context, provider, child) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDefensivosTab(provider, isDark),
                        _buildPragasTab(provider, isDark),
                        _buildDiagnosticosTab(provider, isDark),
                      ],
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

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Consumer<FavoritosProviderSimplified>(
      builder: (context, provider, child) {
        return ModernHeaderWidget(
          title: 'Favoritos',
          subtitle: provider.hasAnyFavoritos 
              ? '${provider.allFavoritos.length} itens salvos'
              : 'Seus itens salvos',
          leftIcon: Icons.favorite,
          showBackButton: false,
          showActions: false,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(FontAwesomeIcons.shield),
            text: 'Defensivos',
          ),
          Tab(
            icon: Icon(FontAwesomeIcons.bug),
            text: 'Pragas',
          ),
          Tab(
            icon: Icon(FontAwesomeIcons.magnifyingGlass),
            text: 'Diagnósticos',
          ),
        ],
        labelColor: const Color(0xFF4CAF50),
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: const Color(0xFF4CAF50),
        indicatorWeight: 3.0,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDefensivosTab(FavoritosProviderSimplified provider, bool isDark) {
    return _buildTabContent(
      provider: provider,
      viewState: provider.getViewStateForType(TipoFavorito.defensivo),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.defensivo),
      count: provider.getCountForType(TipoFavorito.defensivo),
      items: provider.defensivos,
      itemBuilder: (defensivo) => _buildFavoritoDefensivoItem(defensivo, provider),
      isDark: isDark,
    );
  }

  Widget _buildPragasTab(FavoritosProviderSimplified provider, bool isDark) {
    return _buildTabContent(
      provider: provider,
      viewState: provider.getViewStateForType(TipoFavorito.praga),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.praga),
      count: provider.getCountForType(TipoFavorito.praga),
      items: provider.pragas,
      itemBuilder: (praga) => _buildFavoritoPragaItem(praga, provider),
      isDark: isDark,
    );
  }

  Widget _buildDiagnosticosTab(FavoritosProviderSimplified provider, bool isDark) {
    // Verificar se o usuário é premium para mostrar diagnósticos
    final premiumService = sl<IPremiumService>();
    final isPremium = premiumService.isPremium;
    
    if (!isPremium) {
      return _buildPremiumRequiredCard();
    }
    
    return _buildTabContent(
      provider: provider,
      viewState: provider.getViewStateForType(TipoFavorito.diagnostico),
      emptyMessage: provider.getEmptyMessageForType(TipoFavorito.diagnostico),
      count: provider.getCountForType(TipoFavorito.diagnostico),
      items: provider.diagnosticos,
      itemBuilder: (diagnostico) => _buildFavoritoDiagnosticoItem(diagnostico, provider),
      isDark: isDark,
    );
  }

  Widget _buildTabContent<T extends FavoritoEntity>({
    required FavoritosProviderSimplified provider,
    required FavoritosViewState viewState,
    required String emptyMessage,
    required int count,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required bool isDark,
  }) {
    switch (viewState) {
      case FavoritosViewState.loading:
        return const Center(child: CircularProgressIndicator());
      
      case FavoritosViewState.error:
        return Center(
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
                'Erro ao carregar favoritos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (provider.errorMessage != null) ...[
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
            ],
          ),
        );
      
      case FavoritosViewState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 64,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      
      case FavoritosViewState.loaded:
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadAllFavoritos();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length + 1, // +1 para espaço extra no final
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const SizedBox(height: 80); // Espaço para bottom navigation
              }
              
              return itemBuilder(items[index]);
            },
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFavoritoDefensivoItem(FavoritoDefensivoEntity defensivo, FavoritosProviderSimplified provider) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _navigateToDefensivoDetails(defensivo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.shield,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defensivo.nomeComum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (defensivo.ingredienteAtivo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      defensivo.ingredienteAtivo,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (defensivo.fabricante?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      defensivo.fabricante!,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await provider.toggleFavorito(TipoFavorito.defensivo, defensivo.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritoPragaItem(FavoritoPragaEntity praga, FavoritosProviderSimplified provider) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _navigateToPragaDetails(praga),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              ),
              child: PragaImageWidget(
                nomeCientifico: praga.nomeCientifico,
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    praga.nomeComum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (praga.nomeCientifico.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      praga.nomeCientifico,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (praga.tipo.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      praga.tipo,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await provider.toggleFavorito(TipoFavorito.praga, praga.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritoDiagnosticoItem(FavoritoDiagnosticoEntity diagnostico, FavoritosProviderSimplified provider) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _navigateToDiagnosticoDetails(diagnostico),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.magnifyingGlass,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${diagnostico.nomeDefensivo} → ${diagnostico.nomePraga}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (diagnostico.cultura.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cultura: ${diagnostico.cultura}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (diagnostico.dosagem.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dosagem: ${diagnostico.dosagem}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await provider.toggleFavorito(TipoFavorito.diagnostico, diagnostico.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar card de upgrade premium (específico para diagnósticos)
  Widget _buildPremiumRequiredCard() {
    return Center(
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFB74D),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond,
              size: 48,
              color: Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
            const Text(
              'Diagnósticos Favoritos não disponíveis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Este recurso está disponível apenas para assinantes do app.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFBF360C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final premiumService = sl<IPremiumService>();
                  premiumService.navigateToPremium();
                },
                icon: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Desbloquear Agora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de navegação usando apenas entidades
  void _navigateToDefensivoDetails(FavoritoDefensivoEntity defensivo) {
    Navigator.pushNamed(
      context, 
      '/detalhe-defensivo',
      arguments: {
        'defensivoName': defensivo.displayName,
        'fabricante': defensivo.fabricante,
      },
    );
  }

  void _navigateToPragaDetails(FavoritoPragaEntity praga) {
    Navigator.pushNamed(
      context,
      '/detalhe-praga',
      arguments: {
        'pragaName': praga.nomeComum,
        'pragaScientificName': praga.nomeCientifico,
      },
    );
  }

  void _navigateToDiagnosticoDetails(FavoritoDiagnosticoEntity diagnostico) {
    Navigator.pushNamed(
      context,
      '/detalhe-diagnostico',
      arguments: {
        'diagnosticoId': diagnostico.id,
        'nomeDefensivo': diagnostico.displayName,
        'nomePraga': diagnostico.nomePraga,
        'cultura': diagnostico.displayCultura,
      },
    );
  }
}