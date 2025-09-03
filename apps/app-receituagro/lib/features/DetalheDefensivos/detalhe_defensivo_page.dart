import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../diagnosticos/presentation/providers/diagnosticos_provider.dart';
import 'domain/entities/defensivo_details_entity.dart';
import 'presentation/providers/detalhe_defensivo_provider.dart';
import 'presentation/widgets/comentarios_tab_widget.dart';
import 'presentation/widgets/custom_tab_bar_widget.dart';
import 'presentation/widgets/defensivo_info_cards_widget.dart';
import 'presentation/widgets/diagnosticos_tab_widget.dart';
import 'presentation/widgets/loading_error_widgets.dart';
import 'presentation/widgets/tecnologia_tab_widget.dart';

/// Página refatorada de detalhes do defensivo
/// REFATORAÇÃO COMPLETA: De 2.379 linhas para menos de 300
/// Responsabilidade: coordenar widgets e providers usando Clean Architecture
class DetalheDefensivoPage extends StatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  State<DetalheDefensivoPage> createState() => _DetalheDefensivoPageState();
}

class _DetalheDefensivoPageState extends State<DetalheDefensivoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DetalheDefensivoProvider _defensivoProvider;
  late DiagnosticosProvider _diagnosticosProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeProviders();
    _loadData();
  }

  void _initializeProviders() {
    _defensivoProvider = DetalheDefensivoProvider(
      favoritosRepository: sl(),
      fitossanitarioRepository: sl(),
      comentariosService: sl(),
      premiumService: sl(),
    );

    _diagnosticosProvider = DiagnosticosProvider(
      getDiagnosticosUseCase: sl(),
      getDiagnosticoByIdUseCase: sl(),
      getRecomendacoesUseCase: sl(),
      getDiagnosticosByDefensivoUseCase: sl(),
      getDiagnosticosByCulturaUseCase: sl(),
      getDiagnosticosByPragaUseCase: sl(),
      searchDiagnosticosWithFiltersUseCase: sl(),
      getDiagnosticoStatsUseCase: sl(),
      validateCompatibilidadeUseCase: sl(),
      searchDiagnosticosByPatternUseCase: sl(),
      getDiagnosticoFiltersDataUseCase: sl(),
    );
  }

  Future<void> _loadData() async {
    debugPrint('Loading data for defensivo: ${widget.defensivoName}');
    await _defensivoProvider.initializeData(widget.defensivoName, widget.fabricante);
    
    // Carrega diagnósticos se os dados do defensivo foram carregados com sucesso
    if (_defensivoProvider.defensivoData != null) {
      debugPrint('Loading diagnósticos for ID: ${_defensivoProvider.defensivoData!.idReg}');
      await _diagnosticosProvider.getDiagnosticosByDefensivo(_defensivoProvider.defensivoData!.idReg);
      debugPrint('Loaded ${_diagnosticosProvider.diagnosticos.length} diagnósticos');
    } else {
      debugPrint('No defensivo data found');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _defensivoProvider),
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
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ModernHeaderWidget(
          title: widget.defensivoName,
          subtitle: widget.fabricante,
          leftIcon: Icons.shield_outlined,
          rightIcon: provider.isFavorited ? Icons.favorite : Icons.favorite_border,
          isDark: isDark,
          showBackButton: true,
          showActions: true,
          onBackPressed: () => Navigator.of(context).pop(),
          onRightIconPressed: () => _handleFavoriteToggle(provider),
        );
      },
    );
  }

  Widget _buildBody() {
    return Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return LoadingErrorWidgets.buildLoadingState(context);
        }

        if (provider.hasError) {
          return LoadingErrorWidgets.buildErrorState(
            context,
            provider.errorMessage,
            () => _loadData(),
          );
        }

        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        CustomTabBarWidget(tabController: _tabController),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _wrapTabContent(_buildInformacoesTab(), 'informacoes'),
                _wrapTabContent(
                  DiagnosticosTabWidget(defensivoName: widget.defensivoName),
                  'diagnostico',
                ),
                _wrapTabContent(
                  TecnologiaTabWidget(defensivoName: widget.defensivoName),
                  'tecnologia',
                ),
                _wrapTabContent(
                  ComentariosTabWidget(defensivoName: widget.defensivoName),
                  'comentarios',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrapTabContent(Widget content, String type) {
    return Container(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            key: ValueKey('$type-content'),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInformacoesTab() {
    return Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        if (provider.defensivoData == null) {
          return LoadingErrorWidgets.buildEmptyState(
            context,
            title: 'Dados não encontrados',
            description: 'Não foi possível carregar os dados do defensivo',
          );
        }

        final entity = DefensivoDetailsEntity.fromHive(provider.defensivoData!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefensivoInfoCardsWidget(defensivo: entity),
              const SizedBox(height: 80), // Espaço para bottom navigation
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFavoriteToggle(DetalheDefensivoProvider provider) async {
    final success = await provider.toggleFavorito(widget.defensivoName, widget.fabricante);
    
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao alterar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}