import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/services/receituagro_navigation_service.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import '../../../favoritos/favoritos_page.dart';
import '../providers/detalhe_praga_notifier.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import '../widgets/comentarios_praga_widget.dart';
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
    with TickerProviderStateMixin {
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
      final pragaNotifier = ref.read(detalhePragaNotifierProvider.notifier);
      final diagnosticosNotifier = ref.read(
        diagnosticosPragaNotifierProvider.notifier,
      );

      if (widget.pragaId != null && widget.pragaId!.isNotEmpty) {
        await pragaNotifier.initializeById(widget.pragaId!);
      } else {
        await pragaNotifier.initializeAsync(
          widget.pragaName,
          widget.pragaScientificName,
        );
      }

      final pragaState = await ref.read(detalhePragaNotifierProvider.future);

      if (pragaState.pragaData != null &&
          pragaState.pragaData!.idReg.isNotEmpty) {
        await diagnosticosNotifier.loadDiagnosticos(
          pragaState.pragaData!.idReg,
          pragaName: widget.pragaName,
        );
      }
    } catch (e) {
      // Handle error silently or log appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    final pragaAsyncState = ref.watch(detalhePragaNotifierProvider);

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
                                const Center(
                                  child: Text(
                                    'Diagnósticos em desenvolvimento',
                                  ),
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
          GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
      onRightIconPressed: () => _toggleFavorito(),
    );
  }

  /// Alterna estado de favorito
  Future<void> _toggleFavorito() async {
    final notifier = ref.read(detalhePragaNotifierProvider.notifier);
    final success = await notifier.toggleFavorito();

    if (mounted) {
      final state = ref.read(detalhePragaNotifierProvider).value;

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
