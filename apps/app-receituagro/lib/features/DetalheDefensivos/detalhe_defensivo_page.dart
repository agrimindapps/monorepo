import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart';
import '../../core/navigation/app_navigation_provider.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/standard_tab_bar_widget.dart';
import 'domain/entities/defensivo_details_entity.dart';
import 'presentation/providers/diagnosticos_provider.dart';
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
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeProviders();
    _loadData();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _initializeProviders() {
    _defensivoProvider = DetalheDefensivoProvider(
      favoritosRepository: sl(),
      fitossanitarioRepository: sl(),
      comentariosService: sl(),
      premiumService: sl(),
    );

    // Usa o provider com filtros implementados
    _diagnosticosProvider = DiagnosticosProvider();
  }

  Future<void> _loadData() async {
    try {
      await _defensivoProvider.initializeData(
          widget.defensivoName, widget.fabricante);

      // Carrega diagnósticos se os dados do defensivo foram carregados com sucesso
      if (_defensivoProvider.defensivoData != null) {
        await _diagnosticosProvider
            .loadDiagnosticos(_defensivoProvider.defensivoData!.idReg);
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      // O estado de erro será gerenciado pelos providers individuais
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _defensivoProvider.dispose();
    _diagnosticosProvider.dispose();
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
          rightIcon:
              provider.isFavorited ? Icons.favorite : Icons.favorite_border,
          isDark: isDark,
          showBackButton: true,
          showActions: true,
          onBackPressed: () => context.read<AppNavigationProvider>().goBack(),
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
        StandardTabBarWidget(
          tabController: _tabController,
          tabs: StandardTabData.defensivoDetailsTabs,
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IndexedStack(
              index: _currentTabIndex,
              children: _buildTabContents(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabContents() {
    return [
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
    ];
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
    // Adicionar haptic feedback inicial
    unawaited(HapticFeedback.lightImpact());
    

    final success =
        await provider.toggleFavorito(widget.defensivoName, widget.fabricante);

    if (!mounted) return;

    // Feedback haptic apenas (sem SnackBar)
    if (success) {
      unawaited(HapticFeedback.selectionClick());
    } else {
      unawaited(HapticFeedback.heavyImpact());
    }
  }
}
