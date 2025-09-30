import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;

import '../../../../core/mixins/premium_status_listener.dart';
import '../../../../core/services/receituagro_navigation_service.dart';
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
class DetalhePragaPage extends StatefulWidget {
  final String pragaName;
  final String? pragaId;
  final String pragaScientificName;

  const DetalhePragaPage({
    super.key,
    required this.pragaName,
    this.pragaId,
    required this.pragaScientificName,
  });

  @override
  State<DetalhePragaPage> createState() => _DetalhePragaPageState();
}

class _DetalhePragaPageState extends State<DetalhePragaPage>
    with TickerProviderStateMixin, PremiumStatusListener {
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
    _pragaProvider.dispose();
    _diagnosticosProvider.dispose();
    super.dispose();
  }

  /// Carrega dados iniciais - operações locais sem timeout necessário
  Future<void> _loadInitialData() async {
    try {
      // Inicializar provider da praga (operação local - sem timeout)
      // Preferir ID quando disponível para melhor precisão
      if (widget.pragaId != null && widget.pragaId!.isNotEmpty) {
        await _pragaProvider.initializeById(widget.pragaId!);
      } else {
        await _pragaProvider.initializeAsync(
          widget.pragaName, 
          widget.pragaScientificName
        );
      }

      // Aguardar um frame para garantir que o provider foi inicializado
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Se praga carregada com sucesso, carregar diagnósticos por ID
      if (_pragaProvider.pragaData != null && _pragaProvider.pragaData!.idReg.isNotEmpty) {
        await _diagnosticosProvider.loadDiagnosticos(
          _pragaProvider.pragaData!.idReg,
          pragaName: widget.pragaName,
        );
      } else {
        // Diagnósticos só podem ser carregados com idReg válido
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados iniciais: $e');
      // Não relançar a exceção para não quebrar a UI
      // O provider já terá o estado de erro interno
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider_lib.MultiProvider(
      providers: [
        provider_lib.ChangeNotifierProvider.value(value: _pragaProvider),
        provider_lib.ChangeNotifierProvider.value(value: _diagnosticosProvider),
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
                      child: provider_lib.Consumer<DetalhePragaProvider>(
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
    return provider_lib.Consumer<DetalhePragaProvider>(
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
          onBackPressed: () => GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
          onRightIconPressed: () => _toggleFavorito(provider),
        );
      },
    );
  }

  @override
  void onPremiumStatusChanged(bool isPremium) {
    // Método vazio - o provider já escuta mudanças automaticamente
    // através do PremiumStatusNotifier configurado no _setupPremiumStatusListener
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
