import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/modern_header_widget.dart';
import 'models/favorito_defensivo_model.dart';
import 'models/favorito_praga_model.dart';
import 'models/favorito_diagnostico_model.dart';
import 'services/mock_favoritos_repository.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../pragas/detalhe_praga_page.dart';
import '../DetalheDiagnostico/detalhe_diagnostico_page.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> 
    with TickerProviderStateMixin {

  late TabController _tabController;
  
  // Favoritos data
  final MockFavoritosRepository _favoritosRepository = MockFavoritosRepository();
  List<FavoritoDefensivoModel> _favoritosDefensivos = [];
  List<FavoritoPragaModel> _favoritosPragas = [];
  List<FavoritoDiagnosticoModel> _favoritosDiagnosticos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavoritos();
  }

  void _loadFavoritos() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final defensivos = await _favoritosRepository.getFavoritosDefensivos();
      final pragas = await _favoritosRepository.getFavoritosPragas();
      final diagnosticos = await _favoritosRepository.getFavoritosDiagnosticos();
      
      if (mounted) {
        setState(() {
          _favoritosDefensivos = defensivos;
          _favoritosPragas = pragas;
          _favoritosDiagnosticos = diagnosticos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(context, isDark),
            const SizedBox(height: 20),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDefensivosTab(),
                  _buildPragasTab(),
                  _buildDiagnosticosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Favoritos',
      subtitle: 'Seus itens salvos',
      leftIcon: Icons.favorite,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      rightIcon: Icons.filter_list,
      onRightIconPressed: () => _showFilterOptions(context),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.primary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 16),
                SizedBox(width: 6),
                Text('Defensivos'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bug_report, size: 16),
                SizedBox(width: 6),
                Text('Pragas'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 16),
                SizedBox(width: 6),
                Text('Diagnóstico'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefensivosTab() {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_favoritosDefensivos.isEmpty) {
      return _buildEmptyState(
        'Nenhum defensivo favorito',
        'Você ainda não possui defensivos favoritos.',
        Icons.shield_outlined,
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFavoritosSection(
            'Defensivos Favoritos',
            FontAwesomeIcons.sprayCan,
            _favoritosDefensivos.map((defensivo) => _buildFavoritoDefensivoItem(defensivo)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPragasTab() {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_favoritosPragas.isEmpty) {
      return _buildEmptyState(
        'Nenhuma praga favoritada',
        'Você ainda não possui pragas favoritas.',
        Icons.bug_report,
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFavoritosSection(
            'Pragas Favoritas',
            FontAwesomeIcons.bug,
            _favoritosPragas.map((praga) => _buildFavoritoPragaItem(praga)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticosTab() {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_favoritosDiagnosticos.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange[300]!, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Diagnósticos não disponíveis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Este recurso está disponível apenas para assinantes do app.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPremiumDialog(),
                  icon: const Icon(Icons.diamond, color: Colors.white),
                  label: const Text(
                    'Desbloquear Agora',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFavoritosSection(
            'Diagnósticos Favoritos',
            FontAwesomeIcons.microscope,
            _favoritosDiagnosticos.map((diagnostico) => _buildFavoritoDiagnosticoItem(diagnostico)).toList(),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    // Don't show premium dialog for anonymous users
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Funcionalidade Premium'),
        content: const Text(
          'Os diagnósticos estão disponíveis apenas para usuários premium. '
          'Assine agora para ter acesso completo ao app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Favoritos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Defensivos'),
              trailing: Icon(Icons.check),
            ),
            ListTile(
              leading: Icon(Icons.pest_control),
              title: Text('Pragas'),
              trailing: Icon(Icons.check),
            ),
            ListTile(
              leading: Icon(Icons.medical_services_outlined),
              title: Text('Diagnósticos'),
              trailing: Icon(Icons.check),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritosSection(String title, IconData icon, List<Widget> items) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFavoritoDefensivoItem(FavoritoDefensivoModel defensivo) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _navigateToDefensivoDetails(defensivo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defensivo.nomeComum ?? 'Nome não disponível',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    defensivo.ingredienteAtivo ?? 'Ingrediente não disponível',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${defensivo.fabricante} • ${defensivo.classeAgronomica}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                // Remover dos favoritos
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritoPragaItem(FavoritoPragaModel praga) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _navigateToPragaDetails(praga),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                praga.tipoPraga == '1' ? Icons.bug_report : Icons.coronavirus,
                color: theme.colorScheme.secondary,
                size: 20,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (praga.nomeCientifico != null)
                    Text(
                      praga.nomeCientifico!,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    praga.tipoPraga == '1' ? 'Inseto' : praga.tipoPraga == '2' ? 'Doença' : 'Planta Daninha',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                // Remover dos favoritos
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritoDiagnosticoItem(FavoritoDiagnosticoModel diagnostico) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _navigateToDiagnosticoDetails(diagnostico),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostico.nome ?? 'Nome não disponível',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    diagnostico.cultura ?? 'Cultura não disponível',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    diagnostico.categoria ?? 'Categoria não disponível',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                // Remover dos favoritos
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDefensivoDetails(FavoritoDefensivoModel defensivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheDefensivoPage(
          defensivoName: defensivo.nomeComum ?? 'Defensivo',
          fabricante: defensivo.fabricante ?? 'Fabricante não informado',
        ),
      ),
    );
  }

  void _navigateToPragaDetails(FavoritoPragaModel praga) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePragaPage(
          pragaName: praga.nomeComum,
          pragaScientificName: praga.nomeCientifico ?? 'Nome científico não disponível',
        ),
      ),
    );
  }

  void _navigateToDiagnosticoDetails(FavoritoDiagnosticoModel diagnostico) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheDiagnosticoPage(
          diagnosticoId: diagnostico.idReg ?? 'DIAG001',
          nomeDefensivo: 'Defensivo Exemplo',
          nomePraga: diagnostico.nome ?? 'Diagnóstico',
          cultura: diagnostico.cultura ?? 'Cultura não especificada',
        ),
      ),
    );
  }
}