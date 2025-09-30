import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../core/mixins/premium_status_listener.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../providers/detalhe_diagnostico_provider.dart';
import '../widgets/aplicacao_instrucoes_widget.dart';
import '../widgets/diagnostico_detalhes_widget.dart';
import '../widgets/diagnostico_info_widget.dart';

class DetalheDiagnosticoPage extends StatefulWidget {
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
  State<DetalheDiagnosticoPage> createState() => _DetalheDiagnosticoPageState();
}

class _DetalheDiagnosticoPageState extends State<DetalheDiagnosticoPage>
    with PremiumStatusListener {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final detalheDiagnosticoProvider = provider.Provider.of<DetalheDiagnosticoProvider>(context, listen: false);
      await detalheDiagnosticoProvider.loadDiagnosticoData(widget.diagnosticoId);
      await detalheDiagnosticoProvider.loadFavoritoState(widget.diagnosticoId);
      await detalheDiagnosticoProvider.loadPremiumStatus();
    });
  }
  
  @override
  void onPremiumStatusChanged(bool isPremium) {
    // Atualiza o provider quando o status premium muda
    final detalheDiagnosticoProvider = provider.Provider.of<DetalheDiagnosticoProvider>(context, listen: false);
    detalheDiagnosticoProvider.loadPremiumStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return provider.Consumer<DetalheDiagnosticoProvider>(
      builder: (context, provider, child) {
        return BottomNavWrapper(
          selectedIndex: 0, // Assumindo que diagnóstico está relacionado a defensivos
          child: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    children: [
                      _buildModernHeader(provider, isDark),
                      Expanded(
                        child: provider.isLoading
                            ? _buildLoadingState()
                            : provider.hasError
                                ? _buildErrorState(provider)
                                : _buildContent(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(DetalheDiagnosticoProvider provider, bool isDark) {
    return ModernHeaderWidget(
      title: 'Diagnóstico',
      subtitle: 'Detalhes do diagnóstico',
      leftIcon: Icons.medical_services_outlined,
      rightIcon: provider.isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _toggleFavorito(provider),
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

  Widget _buildErrorState(DetalheDiagnosticoProvider provider) {
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
              provider.errorMessage ?? 'Dados do diagnóstico não encontrados',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadDiagnosticoData(widget.diagnosticoId),
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


  Widget _buildContent(DetalheDiagnosticoProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de Informações e Imagem
          DiagnosticoInfoWidget(
            nomePraga: widget.nomePraga,
            nomeDefensivo: widget.nomeDefensivo,
            cultura: widget.cultura,
            diagnosticoData: provider.diagnosticoData,
          ),
          const SizedBox(height: 24),
          
          // Seção de Detalhes do Diagnóstico (sempre visível)
          DiagnosticoDetalhesWidget(
            diagnosticoData: provider.diagnosticoData,
          ),
          const SizedBox(height: 24),
          
          // Seção de Instruções de Aplicação (sempre visível)
          AplicacaoInstrucoesWidget(
            diagnosticoData: provider.diagnosticoData,
          ),
          const SizedBox(height: 24),
          
          // Recursos Premium - Visíveis mas controlados por isPremium
          _buildPremiumFeatures(provider),
          
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }
  
  Widget _buildPremiumFeatures(DetalheDiagnosticoProvider provider) {
    // Removido - sem seções premium visíveis
    return const SizedBox.shrink();
  }
  

  void _toggleFavorito(DetalheDiagnosticoProvider provider) async {
    final itemData = {
      'id': widget.diagnosticoId,
      'nomeDefensivo': widget.nomeDefensivo,
      'nomePraga': widget.nomePraga,
      'cultura': widget.cultura,
    };

    final success = await provider.toggleFavorito(widget.diagnosticoId, itemData);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ${provider.isFavorited ? 'adicionar' : 'remover'} favorito'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  

}