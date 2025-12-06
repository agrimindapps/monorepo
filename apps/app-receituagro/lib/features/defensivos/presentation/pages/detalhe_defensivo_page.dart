import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import '../../../../database/receituagro_database.dart';
import '../../domain/entities/defensivo_details_entity.dart';
import '../providers/detalhe_defensivo_notifier.dart';
import '../widgets/detalhe/comentarios_tab_widget.dart';
import '../widgets/detalhe/defensivo_info_cards_widget.dart';
import '../widgets/detalhe/diagnosticos_tab_widget.dart';
import '../widgets/detalhe/loading_error_widgets.dart';
import '../widgets/detalhe/tecnologia_tab_widget.dart';

/// Página refatorada de detalhes do defensivo
/// REFATORAÇÃO COMPLETA: Usa provider unificado para diagnósticos
/// Responsabilidade: coordenar widgets e providers usando Clean Architecture
/// Migrated to Riverpod - uses ConsumerStatefulWidget
class DetalheDefensivoPage extends ConsumerStatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  ConsumerState<DetalheDefensivoPage> createState() =>
      _DetalheDefensivoPageState();
}

class _DetalheDefensivoPageState extends ConsumerState<DetalheDefensivoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    Future.microtask(() {
      // Validação: redireciona para página principal se parâmetros inválidos
      if (_hasInvalidParameters()) {
        _redirectToHome();
        return;
      }
      _loadData();
    });
  }

  /// Verifica se os parâmetros são inválidos (null, undefined, vazios)
  bool _hasInvalidParameters() {
    return widget.defensivoName.isEmpty || widget.fabricante.isEmpty;
  }

  /// Redireciona para a página principal
  void _redirectToHome() {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      // Carrega apenas os dados do defensivo
      // Diagnósticos são carregados automaticamente pelo provider unificado
      await ref
          .read(detalheDefensivoProvider.notifier)
          .initializeData(widget.defensivoName, widget.fabricante);
      
      final state = ref.read(detalheDefensivoProvider);
      state.whenData((data) async {
        if (data.defensivoData != null) {
          await _recordDefensivoAccess(data.defensivoData!);
        }
      });
    } catch (e) {
      debugPrint('❌ [DETALHE_DEFENSIVO_PAGE] Erro ao carregar dados: $e');
    }
  }

  /// Record access to this defensivo for history tracking
  Future<void> _recordDefensivoAccess(Fitossanitario defensivoData) async {
    try {
      final accessHistoryService = AccessHistoryService();
      await accessHistoryService.recordDefensivoAccess(
        id: defensivoData.idDefensivo,
        name: defensivoData.displayName,
        fabricante: defensivoData.displayFabricante,
        ingrediente: defensivoData.displayIngredient,
        classe: defensivoData.displayClass,
      );
    } catch (e) {
      debugPrint('❌ [DETALHE_DEFENSIVO_PAGE] Erro ao registrar acesso: $e');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(detalheDefensivoProvider);

    return Scaffold(
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
    );
  }

  Widget _buildHeader() {
    final state = ref.watch(detalheDefensivoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return state.when(
      data: (data) => ModernHeaderWidget(
        title: widget.defensivoName,
        subtitle: widget.fabricante,
        leftIcon: Icons.shield_outlined,
        rightIcon: data.isFavorited ? Icons.favorite : Icons.favorite_border,
        isDark: isDark,
        showBackButton: true,
        showActions: true,
        onBackPressed: () => Navigator.of(context).pop(),
        onRightIconPressed: _handleFavoriteToggle,
      ),
      loading: () => ModernHeaderWidget(
        title: widget.defensivoName,
        subtitle: widget.fabricante,
        leftIcon: Icons.shield_outlined,
        rightIcon: Icons.favorite_border,
        isDark: isDark,
        showBackButton: true,
        showActions: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      error: (_, __) => ModernHeaderWidget(
        title: widget.defensivoName,
        subtitle: widget.fabricante,
        leftIcon: Icons.shield_outlined,
        rightIcon: Icons.favorite_border,
        isDark: isDark,
        showBackButton: true,
        showActions: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(detalheDefensivoProvider);

    return state.when(
      data: (data) {
        // Sempre mostra a estrutura de tabs, com skeleton ou conteúdo real
        return _buildContent(isLoading: data.isLoading, hasError: data.hasError, errorMessage: data.errorMessage);
      },
      loading: () => _buildContent(isLoading: true, hasError: false),
      error: (error, _) => _buildContent(isLoading: false, hasError: true, errorMessage: error.toString()),
    );
  }

  Widget _buildContent({
    required bool isLoading,
    required bool hasError,
    String? errorMessage,
  }) {
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
              children: _buildTabContents(isLoading: isLoading, hasError: hasError, errorMessage: errorMessage),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabContents({
    required bool isLoading,
    required bool hasError,
    String? errorMessage,
  }) {
    return [
      _wrapTabContent(_buildInformacoesTab(isLoading: isLoading, hasError: hasError, errorMessage: errorMessage), 'informacoes'),
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

  Widget _buildInformacoesTab({
    required bool isLoading,
    required bool hasError,
    String? errorMessage,
  }) {
    // Mostra skeleton durante o loading
    if (isLoading) {
      return LoadingErrorWidgets.buildLoadingState(context);
    }

    // Mostra erro se houver
    if (hasError) {
      return LoadingErrorWidgets.buildErrorState(
        context,
        errorMessage ?? 'Erro desconhecido',
        () => _loadData(),
      );
    }

    final state = ref.watch(detalheDefensivoProvider);

    return state.when(
      data: (data) {
        if (data.defensivoData == null) {
          return LoadingErrorWidgets.buildEmptyState(
            context,
            title: 'Dados não encontrados',
            description: 'Não foi possível carregar os dados do defensivo',
          );
        }

        final entity = DefensivoDetailsEntity.fromDrift(data.defensivoData!);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [DefensivoInfoCardsWidget(defensivo: entity)],
          ),
        );
      },
      loading: () => LoadingErrorWidgets.buildLoadingState(context),
      error: (_, __) => LoadingErrorWidgets.buildEmptyState(
        context,
        title: 'Erro ao carregar',
        description: 'Não foi possível carregar os dados do defensivo',
      ),
    );
  }

  Future<void> _handleFavoriteToggle() async {
    unawaited(HapticFeedback.lightImpact());

    debugPrint(
      '🔄 [UI] Usuário clicou em favorito - defensivo: ${widget.defensivoName}',
    );

    final success = await ref
        .read(detalheDefensivoProvider.notifier)
        .toggleFavorito(widget.defensivoName, widget.fabricante);

    if (!mounted) return;
    final state = ref.read(detalheDefensivoProvider);
    state.whenData((data) {
      if (success) {
        // Feedback tátil silencioso - sem mensagem visual
        unawaited(HapticFeedback.selectionClick());
      } else {
        // Mostra erro apenas quando falha
        unawaited(HapticFeedback.heavyImpact());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (data.errorMessage?.isNotEmpty ?? false)
                  ? data.errorMessage!
                  : 'Erro ao alterar favorito',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
