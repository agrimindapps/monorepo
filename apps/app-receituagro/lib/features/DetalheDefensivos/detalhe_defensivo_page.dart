import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;

import '../../core/di/injection_container.dart';
import '../../core/models/diagnostico_hive.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/diagnostico_hive_repository.dart';
import '../../core/services/access_history_service.dart';
import '../../core/services/diagnosticos_data_loader.dart';
import '../../core/services/receituagro_navigation_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/standard_tab_bar_widget.dart';
import 'domain/entities/defensivo_details_entity.dart';
import 'presentation/providers/detalhe_defensivo_provider.dart';
import 'presentation/providers/diagnosticos_provider.dart';
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
      debugPrint('=== DETALHE DEFENSIVO: Iniciando carregamento ===');
      debugPrint('Defensivo: ${widget.defensivoName}');
      debugPrint('Fabricante: ${widget.fabricante}');
      
      // FORCE DEBUG: Verificar diagnósticos antes de carregar
      await _debugDiagnosticosStatus();
      
      final startTime = DateTime.now();
      
      await _defensivoProvider.initializeData(
          widget.defensivoName, widget.fabricante);

      // Carrega diagnósticos se os dados do defensivo foram carregados com sucesso
      if (_defensivoProvider.defensivoData != null) {
        final defensivoData = _defensivoProvider.defensivoData!;
        final defensivoIdReg = defensivoData.idReg;
        debugPrint('=== CARREGANDO DIAGNÓSTICOS ===');
        debugPrint('ID Reg do defensivo encontrado: $defensivoIdReg');
        debugPrint('Nome do defensivo: ${defensivoData.nomeComum}');
        debugPrint('Fabricante: ${defensivoData.fabricante}');
        
        await _diagnosticosProvider.loadDiagnosticos(defensivoIdReg);
        
        // Record access to this defensivo for "Últimos Acessados"
        await _recordDefensivoAccess(defensivoData);
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        debugPrint('=== CARREGAMENTO COMPLETO ===');
        debugPrint('Tempo total: ${duration.inMilliseconds}ms');
      } else {
        debugPrint('⚠️ AVISO: Dados do defensivo não foram carregados!');
      }
    } catch (e) {
      debugPrint('❌ ERRO ao carregar dados: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      // O estado de erro será gerenciado pelos providers individuais
    }
  }

  /// Debug function para verificar status dos diagnósticos
  Future<void> _debugDiagnosticosStatus() async {
    try {
      debugPrint('🔧 [FORCE DEBUG] Verificando status dos diagnósticos...');
      
      // Tentar acessar o repository diretamente
      final repository = sl<DiagnosticoHiveRepository>();
      final result = await repository.getAll();
      final allDiagnosticos = result.isSuccess ? result.data! : <DiagnosticoHive>[];
      debugPrint('📊 [FORCE DEBUG] Repository direto: ${allDiagnosticos.length} diagnósticos');
      
      if (allDiagnosticos.isEmpty) {
        debugPrint('⚠️ [FORCE DEBUG] Nenhum diagnóstico no repository, tentando forçar carregamento...');
        
        // Tentar carregar via DiagnosticosDataLoader
        debugPrint('🔄 [FORCE DEBUG] Chamando DiagnosticosDataLoader.loadDiagnosticosData()...');
        await DiagnosticosDataLoader.loadDiagnosticosData();
        
        // Verificar novamente
        final newResult = await repository.getAll();
        final newCount = newResult.isSuccess ? newResult.data!.length : 0;
        debugPrint('📊 [FORCE DEBUG] Após carregamento: $newCount diagnósticos');
        
        if (newCount > 0) {
          debugPrint('✅ [FORCE DEBUG] Carregamento bem-sucedido!');
          
          // Verificar sample dos dados
          final sampleResult = await repository.getAll();
          final sample = sampleResult.isSuccess ? sampleResult.data!.take(3).toList() : <DiagnosticoHive>[];
          for (int i = 0; i < sample.length; i++) {
            final diag = sample[i];
            debugPrint('[$i] SAMPLE: fkIdDefensivo="${diag.fkIdDefensivo}", nome="${diag.nomeDefensivo}"');
          }
        } else {
          debugPrint('❌ [FORCE DEBUG] Carregamento falhou - ainda 0 diagnósticos');
        }
      } else {
        debugPrint('✅ [FORCE DEBUG] Repository já tem dados - verificando sample...');
        final sample = allDiagnosticos.take(10).toList();
        for (int i = 0; i < sample.length; i++) {
          final diag = sample[i];
          debugPrint('[$i] SAMPLE: fkIdDefensivo="${diag.fkIdDefensivo}", nome="${diag.nomeDefensivo}"');
        }
        
        // INVESTIGAÇÃO: Procurar pelo ID específico do defensivo atual
        debugPrint('🔍 [INVESTIGAÇÃO] Procurando diagnósticos para defensive atual...');
      }
      
      // NOVA INVESTIGAÇÃO: Buscar por padrões de ID
      await _investigateIdPatterns(repository, allDiagnosticos);
    } catch (e) {
      debugPrint('❌ [FORCE DEBUG] Erro: $e');
      debugPrint('Stack: ${StackTrace.current}');
    }
  }
  
  /// Investigar padrões de ID e buscar correspondências
  Future<void> _investigateIdPatterns(DiagnosticoHiveRepository repository, List<dynamic> allDiagnosticos) async {
    try {
      // Quando chegar na parte de carregar o defensivo, investigar
      if (_defensivoProvider.defensivoData == null) return;
      
      final defensivoId = _defensivoProvider.defensivoData!.idReg;
      final defensivoNome = _defensivoProvider.defensivoData!.nomeComum;
      
      debugPrint('🔍 [INVESTIGAÇÃO] ===== ANÁLISE DE CORRESPONDÊNCIA =====');
      debugPrint('Defensivo procurado:');
      debugPrint('  - ID: "$defensivoId"');
      debugPrint('  - Nome: "$defensivoNome"');
      
      // Buscar por correspondência exata
      final exactMatches = allDiagnosticos.where((d) => d.fkIdDefensivo == defensivoId).toList();
      debugPrint('Correspondências exatas por ID: ${exactMatches.length}');
      
      // Buscar por nome do defensivo nos diagnósticos
      final nameMatches = allDiagnosticos.where((d) => 
        d.nomeDefensivo != null && 
        d.nomeDefensivo.toString().toLowerCase().contains(defensivoNome.toLowerCase())
      ).toList();
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
      
      // Analisar padrões de ID
      final allDefensivoIds = allDiagnosticos
          .map((d) => d.fkIdDefensivo as String)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      
      debugPrint('🔍 [INVESTIGAÇÃO] Padrões de fkIdDefensivo (10 primeiros):');
      for (int i = 0; i < allDefensivoIds.length && i < 10; i++) {
        debugPrint('  [$i] "${allDefensivoIds[i]}" (${allDefensivoIds[i].length} chars)');
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
  Future<void> _recordDefensivoAccess(FitossanitarioHive defensivoData) async {
    try {
      // Use the AccessHistoryService through dependency injection if available
      final accessHistoryService = AccessHistoryService();
      await accessHistoryService.recordDefensivoAccess(
        id: defensivoData.idReg,
        name: defensivoData.nomeComum,
        fabricante: defensivoData.fabricante ?? '',
        ingrediente: defensivoData.ingredienteAtivo ?? '',
        classe: defensivoData.classeAgronomica ?? '',
      );
      
      debugPrint('✅ Acesso registrado para: ${defensivoData.nomeComum}');
    } catch (e) {
      debugPrint('❌ Erro ao registrar acesso: $e');
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
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider.value(value: _defensivoProvider),
        provider.ChangeNotifierProvider.value(value: _diagnosticosProvider),
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
    return provider.Consumer<DetalheDefensivoProvider>(
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
          onBackPressed: () => GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
          onRightIconPressed: () => _handleFavoriteToggle(provider),
        );
      },
    );
  }

  Widget _buildBody() {
    return provider.Consumer<DetalheDefensivoProvider>(
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
    return provider.Consumer<DetalheDefensivoProvider>(
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
