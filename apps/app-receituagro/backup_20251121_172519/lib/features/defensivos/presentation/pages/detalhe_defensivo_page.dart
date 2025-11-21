import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/diagnosticos_data_loader.dart';
import '../../../../core/services/receituagro_navigation_service.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../features/navigation/navigation_providers.dart';
import '../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';
import '../../domain/entities/defensivo_details_entity.dart';
import '../providers/detalhe_defensivo_notifier.dart';
import '../widgets/detalhe/comentarios_tab_widget.dart';
import '../widgets/detalhe/defensivo_info_cards_widget.dart';
import '../widgets/detalhe/diagnosticos_tab_widget.dart';
import '../widgets/detalhe/loading_error_widgets.dart';
import '../widgets/detalhe/tecnologia_tab_widget.dart';

/// Página refatorada de detalhes do defensivo
/// REFATORAÇÃO COMPLETA: De 2.379 linhas para menos de 300
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
      debugPrint('=== DETALHE DEFENSIVO: Iniciando carregamento ===');
      debugPrint('Defensivo: ${widget.defensivoName}');
      debugPrint('Fabricante: ${widget.fabricante}');
      await _debugDiagnosticosStatus();

      final startTime = DateTime.now();

      await ref
          .read(detalheDefensivoNotifierProvider.notifier)
          .initializeData(widget.defensivoName, widget.fabricante);
      final state = ref.read(detalheDefensivoNotifierProvider);
      state.whenData((data) async {
        if (data.defensivoData != null) {
          final defensivoData = data.defensivoData!;
          final defensivoIdReg = defensivoData.idDefensivo;
          debugPrint('=== CARREGANDO DIAGNÓSTICOS ===');
          debugPrint('ID Reg do defensivo encontrado: $defensivoIdReg');
          debugPrint('Nome do defensivo: ${defensivoData.nomeComum}');
          debugPrint('Fabricante: ${defensivoData.fabricante}');

          debugPrint(
            '🔍 [DETALHE_DEFENSIVO_PAGE] Chamando getDiagnosticosByDefensivo...',
          );
          debugPrint(
            '🔍 [DETALHE_DEFENSIVO_PAGE] defensivoIdReg: $defensivoIdReg',
          );
          debugPrint(
            '🔍 [DETALHE_DEFENSIVO_PAGE] nomeDefensivo: ${defensivoData.nomeComum}',
          );

          final notifier = ref.read(diagnosticosNotifierProvider.notifier);
          debugPrint(
            '🔍 [DETALHE_DEFENSIVO_PAGE] Notifier obtido: ${notifier.runtimeType}',
          );

          await notifier.getDiagnosticosByDefensivo(
            defensivoIdReg,
            nomeDefensivo: defensivoData.nomeComum,
          );

          debugPrint(
            '✅ [DETALHE_DEFENSIVO_PAGE] getDiagnosticosByDefensivo concluído',
          );

          // Verificar estado após chamada
          final stateAfter = ref.read(diagnosticosNotifierProvider);
          stateAfter.whenData((stateData) {
            debugPrint('📊 [DETALHE_DEFENSIVO_PAGE] Estado após chamada:');
            debugPrint(
              '   - allDiagnosticos: ${stateData.allDiagnosticos.length}',
            );
            debugPrint(
              '   - filteredDiagnosticos: ${stateData.filteredDiagnosticos.length}',
            );
            debugPrint(
              '   - contextoDefensivo: ${stateData.contextoDefensivo}',
            );
            debugPrint(
              '   - diagnosticos (getter): ${stateData.diagnosticos.length}',
            );
          });
          await _recordDefensivoAccess(defensivoData);

          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          debugPrint('=== CARREGAMENTO COMPLETO ===');
          debugPrint('Tempo total: ${duration.inMilliseconds}ms');
        } else {
          debugPrint('⚠️ AVISO: Dados do defensivo não foram carregados!');
        }
      });
    } catch (e) {
      debugPrint('❌ ERRO ao carregar dados: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// Debug function para verificar status dos diagnósticos
  Future<void> _debugDiagnosticosStatus() async {
    try {
      debugPrint('🔧 [FORCE DEBUG] Verificando status dos diagnósticos...');
      final repository = ref.read(diagnosticoRepositoryProvider);
      final result = await repository.getAll();
      final allDiagnosticos = result;
      debugPrint(
        '📊 [FORCE DEBUG] Repository direto: ${allDiagnosticos.length} diagnósticos',
      );

      if (allDiagnosticos.isEmpty) {
        debugPrint(
          '⚠️ [FORCE DEBUG] Nenhum diagnóstico no repository, tentando forçar carregamento...',
        );
        debugPrint(
          '🔄 [FORCE DEBUG] Chamando DiagnosticosDataLoader.loadDiagnosticosData()...',
        );
        await DiagnosticosDataLoader.loadDiagnosticosData();
        final newResult = await repository.getAll();
        final newCount = newResult.length;
        debugPrint(
          '📊 [FORCE DEBUG] Após carregamento: $newCount diagnósticos',
        );

        if (newCount > 0) {
          debugPrint('✅ [FORCE DEBUG] Carregamento bem-sucedido!');
          final sampleResult = await repository.getAll();
          final sample = sampleResult.take(3).toList();
          for (int i = 0; i < sample.length; i++) {
            final diag = sample[i];
            debugPrint(
              '[$i] SAMPLE: defensivoId="${diag.defensivoId}"',
            );
          }
        } else {
          debugPrint(
            '❌ [FORCE DEBUG] Carregamento falhou - ainda 0 diagnósticos',
          );
        }
      } else {
        debugPrint(
          '✅ [FORCE DEBUG] Repository já tem dados - verificando sample...',
        );
        final sample = allDiagnosticos.take(10).toList();
        for (int i = 0; i < sample.length; i++) {
          final diag = sample[i];
          debugPrint(
          '[$i] SAMPLE: defensivoId="${diag.defensivoId}", idReg="${diag.idReg}"',
          );
        }
        debugPrint(
          '🔍 [INVESTIGAÇÃO] Procurando diagnósticos para defensive atual...',
        );
      }
      await _investigateIdPatterns(repository, allDiagnosticos);
    } catch (e) {
      debugPrint('❌ [FORCE DEBUG] Erro: $e');
      debugPrint('Stack: ${StackTrace.current}');
    }
  }

  /// Investigar padrões de ID e buscar correspondências
  Future<void> _investigateIdPatterns(
    DiagnosticoRepository repository,
    List<dynamic> allDiagnosticos,
  ) async {
    try {
      final state = ref.read(detalheDefensivoNotifierProvider);
      Fitossanitario? defensivoData;
      state.whenData((data) {
        defensivoData = data.defensivoData;
      });

      if (defensivoData == null) return;

      final defensivoId = defensivoData!.idDefensivo;
      final defensivoNome = defensivoData!.displayName;

      debugPrint('🔍 [INVESTIGAÇÃO] ===== ANÁLISE DE CORRESPONDÊNCIA =====');
      debugPrint('Defensivo procurado:');
      debugPrint('  - ID: "$defensivoId"');
      debugPrint('  - Nome: "$defensivoNome"');
      final exactMatches = allDiagnosticos
          .where((d) => d.fkIdDefensivo == defensivoId)
          .toList();
      debugPrint('Correspondências exatas por ID: ${exactMatches.length}');
      final nameMatches = allDiagnosticos
          .where(
            (d) =>
                d.nomeDefensivo != null &&
                d.nomeDefensivo.toString().toLowerCase().contains(
                  defensivoNome.toLowerCase(),
                ),
          )
          .toList();
      debugPrint('Correspondências por nome: ${nameMatches.length}');

      if (nameMatches.isNotEmpty) {
        debugPrint('🎯 [INVESTIGAÇÃO] ENCONTRADAS correspondências por nome:');
        for (int i = 0; i < nameMatches.length && i < 5; i++) {
          final match = nameMatches[i];
          debugPrint('  [$i] fkIdDefensivo: "${match.fkIdDefensivo}"');
          debugPrint('      nomeDefensivo: "${match.nomeDefensivo}"');
          debugPrint('      nomeCultura: "${match.nomeCultura}"');
        }
      }
      final allDefensivoIds = allDiagnosticos
          .map((d) => d.fkIdDefensivo as String)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('🔍 [INVESTIGAÇÃO] Padrões de fkIdDefensivo (10 primeiros):');
      for (int i = 0; i < allDefensivoIds.length && i < 10; i++) {
        debugPrint(
          '  [$i] "${allDefensivoIds[i]}" (${allDefensivoIds[i].length} chars)',
        );
      }

      debugPrint('📊 [INVESTIGAÇÃO] Estatísticas:');
      debugPrint('  - Total diagnósticos: ${allDiagnosticos.length}');
      debugPrint('  - IDs únicos de defensivos: ${allDefensivoIds.length}');
      debugPrint('  - Tamanho do ID procurado: ${defensivoId.length} chars');

      debugPrint('🔍 [INVESTIGAÇÃO] ===== FIM DA ANÁLISE =====');
    } catch (e) {
      debugPrint('❌ [FORCE DEBUG] Erro: $e');
      debugPrint('Stack: ${StackTrace.current}');
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

      debugPrint('✅ Acesso registrado para: ${defensivoData.displayName}');
    } catch (e) {
      debugPrint('❌ Erro ao registrar acesso: $e');
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
    ref.watch(detalheDefensivoNotifierProvider);

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
    final state = ref.watch(detalheDefensivoNotifierProvider);
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
        onBackPressed: () =>
            ref.read(receitaAgroNavigationServiceProvider).goBack<void>(),
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
        onBackPressed: () =>
            ref.read(receitaAgroNavigationServiceProvider).goBack<void>(),
      ),
      error: (_, __) => ModernHeaderWidget(
        title: widget.defensivoName,
        subtitle: widget.fabricante,
        leftIcon: Icons.shield_outlined,
        rightIcon: Icons.favorite_border,
        isDark: isDark,
        showBackButton: true,
        showActions: true,
        onBackPressed: () =>
            ref.read(receitaAgroNavigationServiceProvider).goBack<void>(),
      ),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(detalheDefensivoNotifierProvider);

    return state.when(
      data: (data) {
        if (data.isLoading) {
          return LoadingErrorWidgets.buildLoadingState(context);
        }

        if (data.hasError) {
          return LoadingErrorWidgets.buildErrorState(
            context,
            data.errorMessage ?? 'Erro desconhecido',
            () => _loadData(),
          );
        }

        return _buildContent();
      },
      loading: () => LoadingErrorWidgets.buildLoadingState(context),
      error: (error, _) => LoadingErrorWidgets.buildErrorState(
        context,
        error.toString(),
        () => _loadData(),
      ),
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
    final state = ref.watch(detalheDefensivoNotifierProvider);

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
        .read(detalheDefensivoNotifierProvider.notifier)
        .toggleFavorito(widget.defensivoName, widget.fabricante);

    if (!mounted) return;
    final state = ref.read(detalheDefensivoNotifierProvider);
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
