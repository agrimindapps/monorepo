import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../favoritos/favoritos_page.dart';
import '../providers/detalhe_praga_provider.dart';
import '../providers/diagnosticos_praga_provider.dart';
import '../widgets/comentarios_praga_widget.dart';
import '../widgets/custom_tab_bar_widget.dart';
import '../widgets/diagnosticos_praga_widget.dart';
import '../widgets/praga_info_widget.dart';

/// Página refatorada seguindo Clean Architecture
/// Responsabilidade única: coordenar providers e widgets especializados
class DetalhePragaCleanPage extends StatefulWidget {
  final String pragaName;
  final String pragaScientificName;

  const DetalhePragaCleanPage({
    super.key,
    required this.pragaName,
    required this.pragaScientificName,
  });

  @override
  State<DetalhePragaCleanPage> createState() => _DetalhePragaCleanPageState();
}

class _DetalhePragaCleanPageState extends State<DetalhePragaCleanPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DetalhePragaProvider _pragaProvider;
  late DiagnosticosPragaProvider _diagnosticosProvider;

  @override
  void initState() {
    super.initState();
    
    // Inicializar tab controller
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializar providers
    _pragaProvider = DetalhePragaProvider();
    _diagnosticosProvider = DiagnosticosPragaProvider();
    
    // Inicializar dados
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Providers serão dispostos automaticamente pelo Provider
    super.dispose();
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    // Inicializar provider da praga
    _pragaProvider.initialize(widget.pragaName, widget.pragaScientificName);
    
    // Se praga carregada com sucesso, carregar diagnósticos
    if (_pragaProvider.pragaData != null) {
      await _diagnosticosProvider.loadDiagnosticos(_pragaProvider.pragaData!.idReg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _pragaProvider),
        ChangeNotifierProvider.value(value: _diagnosticosProvider),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Consumer<DetalhePragaProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            CustomTabBarWidget(tabController: _tabController),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  PragaInfoWidget(
                                    pragaName: widget.pragaName,
                                    pragaScientificName: widget.pragaScientificName,
                                  ),
                                  DiagnosticosPragaWidget(
                                    pragaName: widget.pragaName,
                                  ),
                                  const ComentariosPragaWidget(),
                                ],
                              ),
                            ),
                          ],
                        );
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

  /// Constrói header da página
  Widget _buildHeader() {
    return Consumer<DetalhePragaProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return ModernHeaderWidget(
          title: widget.pragaName,
          subtitle: widget.pragaScientificName,
          leftIcon: Icons.bug_report_outlined,
          rightIcon: provider.isFavorited ? Icons.favorite : Icons.favorite_border,
          isDark: isDark,
          showBackButton: true,
          showActions: true,
          onBackPressed: () => Navigator.of(context).pop(),
          onRightIconPressed: () => _toggleFavorito(provider),
        );
      },
    );
  }

  /// Alterna estado de favorito
  Future<void> _toggleFavorito(DetalhePragaProvider provider) async {
    final success = await provider.toggleFavorito();
    
    if (mounted) {
      if (success) {
        // Notifica a página de favoritos sobre a mudança
        FavoritosPage.reloadIfActive();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isFavorited 
                ? 'Adicionado aos favoritos'
                : 'Removido dos favoritos'
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao alterar favorito'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}