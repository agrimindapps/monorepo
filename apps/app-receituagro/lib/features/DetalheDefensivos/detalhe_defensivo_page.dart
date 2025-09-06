import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/spacing_tokens.dart';
import '../../core/di/injection_container.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/unified_tab_bar_widget.dart';
import '../diagnosticos/presentation/providers/diagnosticos_provider.dart';
import 'domain/entities/defensivo_details_entity.dart';
import 'presentation/providers/detalhe_defensivo_provider.dart';
import 'presentation/widgets/comentarios_tab_widget.dart';
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
    await _defensivoProvider.initializeData(widget.defensivoName, widget.fabricante);
    
    // Carrega diagnósticos se os dados do defensivo foram carregados com sucesso
    if (_defensivoProvider.defensivoData != null) {
      await _diagnosticosProvider.getDiagnosticosByDefensivo(_defensivoProvider.defensivoData!.idReg);
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
        UnifiedTabBarWidget.forDefensivos(
          tabController: _tabController,
        ),
        Expanded(
          child: Container(
            margin: SpacingTokens.cardMargin,
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
          padding: SpacingTokens.scrollPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefensivoInfoCardsWidget(defensivo: entity),
              // Espaço já incluído no scrollPadding
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFavoriteToggle(DetalheDefensivoProvider provider) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final wasAlreadyFavorited = provider.isFavorited;
    
    // Mostra feedback imediato
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          wasAlreadyFavorited 
            ? '\u2764\ufe0f Removendo dos favoritos...' 
            : '\u2764\ufe0f Adicionando aos favoritos...',
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    
    final success = await provider.toggleFavorito(widget.defensivoName, widget.fabricante);
    
    if (!mounted) return;

    // Feedback final baseado no resultado
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          success 
            ? (wasAlreadyFavorited 
                ? '\u2713 ${widget.defensivoName} removido dos favoritos' 
                : '\u2713 ${widget.defensivoName} adicionado aos favoritos')
            : '\u274c Erro ao alterar favorito',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: success 
          ? Theme.of(context).colorScheme.primary 
          : Colors.red,
      ),
    );
  }
}