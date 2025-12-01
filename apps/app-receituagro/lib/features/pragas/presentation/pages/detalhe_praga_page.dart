import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import '../../../../features/navigation/navigation_providers.dart';
import '../../../favoritos/favoritos_page.dart';
import '../providers/detalhe_praga_notifier.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import '../widgets/comentarios_praga_widget.dart';
import '../widgets/diagnosticos_praga_widget.dart';
import '../widgets/praga_info_widget.dart';

/// Página refatorada seguindo Clean Architecture
/// Responsabilidade única: coordenar notifiers e widgets especializados
class DetalhePragaPage extends ConsumerStatefulWidget {
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
  ConsumerState<DetalhePragaPage> createState() => _DetalhePragaPageState();
}

class _DetalhePragaPageState extends ConsumerState<DetalhePragaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Validação: redireciona para página principal se parâmetros inválidos
      if (_hasInvalidParameters()) {
        _redirectToHome();
        return;
      }
      _loadInitialData();
    });
  }

  /// Verifica se os parâmetros são inválidos (null, undefined, vazios)
  bool _hasInvalidParameters() {
    return widget.pragaName.isEmpty || widget.pragaScientificName.isEmpty;
  }

  /// Redireciona para a página principal
  void _redirectToHome() {
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Carrega dados iniciais - operações locais sem timeout necessário
  Future<void> _loadInitialData() async {
    try {
      debugPrint('🔍 [DETALHE_PRAGA_PAGE] _loadInitialData iniciando...');
      debugPrint('🔍 [DETALHE_PRAGA_PAGE] pragaId: ${widget.pragaId}, pragaName: ${widget.pragaName}');
      
      final pragaNotifier = ref.read(detalhePragaProvider.notifier);
      final diagnosticosNotifier = ref.read(
        diagnosticosPragaProvider.notifier,
      );

      if (widget.pragaId != null && widget.pragaId!.isNotEmpty) {
        debugPrint('🔍 [DETALHE_PRAGA_PAGE] Inicializando por ID: ${widget.pragaId}');
        await pragaNotifier.initializeById(widget.pragaId!);
      } else {
        debugPrint('🔍 [DETALHE_PRAGA_PAGE] Inicializando por nome: ${widget.pragaName}');
        await pragaNotifier.initializeAsync(
          widget.pragaName,
          widget.pragaScientificName,
        );
      }

      final pragaState = await ref.read(detalhePragaProvider.future);
      debugPrint('🔍 [DETALHE_PRAGA_PAGE] pragaState.pragaData: ${pragaState.pragaData}');
      debugPrint('🔍 [DETALHE_PRAGA_PAGE] pragaData.id: ${pragaState.pragaData?.id}');
      debugPrint('🔍 [DETALHE_PRAGA_PAGE] pragaData.idPraga: ${pragaState.pragaData?.idPraga}');

      if (pragaState.pragaData != null &&
          pragaState.pragaData!.idPraga.isNotEmpty) {
        debugPrint('🔍 [DETALHE_PRAGA_PAGE] Carregando diagnósticos para idPraga: ${pragaState.pragaData!.idPraga}');
        await diagnosticosNotifier.loadDiagnosticos(
          pragaState.pragaData!.idPraga,
          pragaName: widget.pragaName,
        );
      } else {
        debugPrint('⚠️ [DETALHE_PRAGA_PAGE] pragaData ou idPraga vazio/null');
      }
    } catch (e, stack) {
      debugPrint('❌ [DETALHE_PRAGA_PAGE] Erro em _loadInitialData: $e');
      debugPrint('❌ [DETALHE_PRAGA_PAGE] Stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pragaAsyncState = ref.watch(detalhePragaProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: pragaAsyncState.when(
                data: (state) => Column(
                  children: [
                    _buildHeader(state),
                    Expanded(
                      child: Column(
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
                                DiagnosticosPragaWidget(
                                  pragaName: widget.pragaName,
                                ),
                                const ComentariosPragaWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Erro: $error')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói header da página
  Widget _buildHeader(DetalhePragaState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernHeaderWidget(
      title: widget.pragaName,
      subtitle: widget.pragaScientificName,
      leftIcon: Icons.bug_report_outlined,
      rightIcon: state.isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () =>
          ref.read(receitaAgroNavigationServiceProvider).goBack<void>(),
      onRightIconPressed: () => _toggleFavorito(),
    );
  }

  /// Alterna estado de favorito
  Future<void> _toggleFavorito() async {
    final notifier = ref.read(detalhePragaProvider.notifier);
    final success = await notifier.toggleFavorito();

    if (mounted) {
      final state = ref.read(detalhePragaProvider).value;

      if (success) {
        FavoritosPage.reloadIfActive();
        // Sem mensagem de sucesso - feedback visual do ícone é suficiente
      } else {
        // Mostra erro apenas quando falha
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state?.errorMessage ?? 'Erro ao alterar favorito'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
