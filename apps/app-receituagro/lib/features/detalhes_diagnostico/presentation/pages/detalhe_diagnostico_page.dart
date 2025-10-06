import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../providers/detalhe_diagnostico_notifier.dart';
import '../widgets/aplicacao_instrucoes_widget.dart';
import '../widgets/diagnostico_detalhes_widget.dart';
import '../widgets/diagnostico_info_widget.dart';

class DetalheDiagnosticoPage extends ConsumerStatefulWidget {
  final String diagnosticoId;
  final String nomeDefensivo;
  final String nomePraga;
  final String cultura;

  const DetalheDiagnosticoPage({
    super.key,
    required this.diagnosticoId,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.cultura,
  });

  @override
  ConsumerState<DetalheDiagnosticoPage> createState() => _DetalheDiagnosticoPageState();
}

class _DetalheDiagnosticoPageState extends ConsumerState<DetalheDiagnosticoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(detalheDiagnosticoNotifierProvider.notifier);
      await notifier.loadDiagnosticoData(widget.diagnosticoId);
      await notifier.loadFavoritoState(widget.diagnosticoId);
      await notifier.loadPremiumStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncState = ref.watch(detalheDiagnosticoNotifierProvider);

    return asyncState.when(
      data: (state) => BottomNavWrapper(
          selectedIndex: 0, // Assumindo que diagnóstico está relacionado a defensivos
          child: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    children: [
                      _buildModernHeader(state, isDark),
                      Expanded(
                        child: state.isLoading
                            ? _buildLoadingState()
                            : state.hasError
                                ? _buildErrorState(state)
                                : _buildContent(state),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildModernHeader(DetalheDiagnosticoState state, bool isDark) {
    return ModernHeaderWidget(
      title: 'Diagnóstico',
      subtitle: 'Detalhes do diagnóstico',
      leftIcon: Icons.medical_services_outlined,
      rightIcon: state.isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _toggleFavorito(),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando diagnóstico...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde enquanto buscamos as informações',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(DetalheDiagnosticoState state) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar diagnóstico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Dados do diagnóstico não encontrados',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(detalheDiagnosticoNotifierProvider.notifier).loadDiagnosticoData(widget.diagnosticoId),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DetalheDiagnosticoState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiagnosticoInfoWidget(
            nomePraga: widget.nomePraga,
            nomeDefensivo: widget.nomeDefensivo,
            cultura: widget.cultura,
            diagnosticoData: state.diagnosticoData,
          ),
          const SizedBox(height: 24),
          DiagnosticoDetalhesWidget(
            diagnosticoData: state.diagnosticoData,
          ),
          const SizedBox(height: 24),
          AplicacaoInstrucoesWidget(
            diagnosticoData: state.diagnosticoData,
          ),
          const SizedBox(height: 24),
          _buildPremiumFeatures(state),
          
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }
  
  Widget _buildPremiumFeatures(DetalheDiagnosticoState state) {
    return const SizedBox.shrink();
  }

  Future<void> _toggleFavorito() async {
    final itemData = {
      'id': widget.diagnosticoId,
      'nomeDefensivo': widget.nomeDefensivo,
      'nomePraga': widget.nomePraga,
      'cultura': widget.cultura,
    };

    final notifier = ref.read(detalheDiagnosticoNotifierProvider.notifier);
    final success = await notifier.toggleFavorito(widget.diagnosticoId, itemData);

    if (!success && mounted) {
      final state = ref.read(detalheDiagnosticoNotifierProvider).value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ${state?.isFavorited == true ? 'adicionar' : 'remover'} favorito'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  

}