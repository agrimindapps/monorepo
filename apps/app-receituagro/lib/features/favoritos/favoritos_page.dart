import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/praga_image_widget.dart';
import 'domain/entities/favorito_entity.dart';
import 'favoritos_di.dart';
import 'models/favorito_defensivo_model.dart';
import 'models/favorito_diagnostico_model.dart';
import 'models/favorito_praga_model.dart';
import 'presentation/providers/favoritos_provider.dart';

/// Favoritos Page refatorada para usar Clean Architecture com Provider
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> 
    with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicialização será feita pelo Provider quando criado
    // Removido acesso direto ao context.read aqui para evitar race condition
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider(
      // ARCHITECTURAL FIX: Provider initialization with auto-loading
      // Fix para race condition - provider agora inicializa automaticamente
      create: (_) {
        final provider = FavoritosDI.get<FavoritosProvider>();
        // Inicializa o provider imediatamente após criação
        provider.initialize();
        return provider;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(context, isDark),
              const SizedBox(height: 20),
              _buildTabBar(),
              Expanded(
                child: Consumer<FavoritosProvider>(
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
    return Consumer<FavoritosProvider>(
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

  Widget _buildDefensivosTab(FavoritosProvider provider, bool isDark) {
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

  Widget _buildPragasTab(FavoritosProvider provider, bool isDark) {
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

  Widget _buildDiagnosticosTab(FavoritosProvider provider, bool isDark) {
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
    required FavoritosProvider provider,
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

  Widget _buildFavoritoDefensivoItem(FavoritoDefensivoEntity defensivo, FavoritosProvider provider) {
    final theme = Theme.of(context);
    
    // Converte para modelo para compatibilidade com navegação existente
    final model = FavoritoDefensivoModel(
      id: 0,
      idReg: defensivo.id,
      line1: defensivo.nomeComum,
      line2: defensivo.ingredienteAtivo ?? '',
      nomeComum: defensivo.nomeComum,
      ingredienteAtivo: defensivo.ingredienteAtivo,
      fabricante: defensivo.fabricante,
      dataCriacao: DateTime.now(),
    );
    
    return GestureDetector(
      onTap: () => _navigateToDefensivoDetails(model),
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
                  if (defensivo.ingredienteAtivo?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      defensivo.ingredienteAtivo ?? '',
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

  Widget _buildFavoritoPragaItem(FavoritoPragaEntity praga, FavoritosProvider provider) {
    final theme = Theme.of(context);
    
    // Converte para modelo para compatibilidade com navegação existente
    final model = FavoritoPragaModel(
      id: 0,
      idReg: praga.id,
      nomeComum: praga.nomeComum,
      nomeCientifico: praga.nomeCientifico,
      tipoPraga: praga.tipoPraga,
      dataCriacao: DateTime.now(),
    );
    
    return GestureDetector(
      onTap: () => _navigateToPragaDetails(model),
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

  Widget _buildFavoritoDiagnosticoItem(FavoritoDiagnosticoEntity diagnostico, FavoritosProvider provider) {
    final theme = Theme.of(context);
    
    // Converte para modelo para compatibilidade com navegação existente
    final model = FavoritoDiagnosticoModel(
      id: 0,
      idReg: diagnostico.id,
      nome: '${diagnostico.nomeDefensivo} → ${diagnostico.nomePraga}',
      cultura: diagnostico.cultura,
      dataCriacao: DateTime.now(),
    );
    
    return GestureDetector(
      onTap: () => _navigateToDiagnosticoDetails(model),
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

  // Métodos de navegação (podem ser movidos para um service futuramente)
  void _navigateToDefensivoDetails(FavoritoDefensivoModel defensivo) {
    Navigator.pushNamed(
      context, 
      '/detalhe-defensivo',
      arguments: {
        'defensivoName': defensivo.displayName,
        'fabricante': defensivo.fabricante,
      },
    );
  }

  void _navigateToPragaDetails(FavoritoPragaModel praga) {
    Navigator.pushNamed(
      context,
      '/detalhe-praga',
      arguments: {
        'pragaName': praga.nomeComum,
        'pragaScientificName': praga.nomeCientifico,
      },
    );
  }

  void _navigateToDiagnosticoDetails(FavoritoDiagnosticoModel diagnostico) {
    Navigator.pushNamed(
      context,
      '/detalhe-diagnostico',
      arguments: {
        'diagnosticoId': diagnostico.idReg,
        'nomeDefensivo': diagnostico.displayName,
        'nomePraga': diagnostico.displayName,
        'cultura': diagnostico.displayCultura,
      },
    );
  }
}