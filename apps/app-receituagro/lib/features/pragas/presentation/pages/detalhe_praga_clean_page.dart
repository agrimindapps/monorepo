import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import '../../../favoritos/favoritos_page.dart';
import '../providers/detalhe_praga_provider.dart';
import '../providers/diagnosticos_praga_provider.dart';
import '../widgets/comentarios_praga_widget.dart';
import '../widgets/diagnosticos_praga_mockup_widget.dart';
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

  /// Carrega dados iniciais com tratamento de timeout e retry
  Future<void> _loadInitialData() async {
    try {
      // Inicializar provider da praga com timeout
      await _pragaProvider.initializeAsync(
        widget.pragaName, 
        widget.pragaScientificName
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ Timeout ao inicializar praga provider');
          throw TimeoutException('Timeout ao carregar dados da praga', const Duration(seconds: 10));
        },
      );

      // Aguardar um frame para garantir que o provider foi inicializado
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Se praga carregada com sucesso, carregar diagnósticos por ID
      if (_pragaProvider.pragaData != null && _pragaProvider.pragaData!.idReg.isNotEmpty) {
        debugPrint('✅ Carregando diagnósticos por ID: ${_pragaProvider.pragaData!.idReg}');
        await _diagnosticosProvider
            .loadDiagnosticos(_pragaProvider.pragaData!.idReg)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('⏰ Timeout ao carregar diagnósticos por ID');
                throw TimeoutException('Timeout ao carregar diagnósticos por ID', const Duration(seconds: 15));
              },
            );
      } else {
        // Fallback: carregar diagnósticos usando o nome da praga
        debugPrint('🔄 Fallback: carregando diagnósticos por nome: ${widget.pragaName}');
        await _diagnosticosProvider
            .loadDiagnosticosByNomePraga(widget.pragaName)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                debugPrint('⏰ Timeout ao carregar diagnósticos por nome');
                throw TimeoutException('Timeout ao carregar diagnósticos por nome', const Duration(seconds: 15));
              },
            );
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados iniciais: $e');
      // Não relançar a exceção para não quebrar a UI
      // O provider já terá o estado de erro interno
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                              StandardTabBarWidget(
                                tabController: _tabController,
                                tabs: StandardTabData.pragaDetailsTabs,
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    PragaInfoWidget(
                                      pragaName: widget.pragaName,
                                      pragaScientificName:
                                          widget.pragaScientificName,
                                    ),
                                    DiagnosticosPragaMockupWidget(
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
          rightIcon:
              provider.isFavorited ? Icons.favorite : Icons.favorite_border,
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
            content: Text(provider.isFavorited
                ? 'Adicionado aos favoritos'
                : 'Removido dos favoritos'),
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
