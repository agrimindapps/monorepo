import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/premium_status_notifier.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/premium_test_controls_widget.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../providers/detalhe_diagnostico_provider.dart';
import '../widgets/aplicacao_instrucoes_widget.dart';
import '../widgets/diagnostico_detalhes_widget.dart';
import '../widgets/diagnostico_info_widget.dart';
import '../widgets/premium_feature_widget.dart';
import '../widgets/share_bottom_sheet_widget.dart';

class DetalheDiagnosticoCleanPage extends StatefulWidget {
  final String diagnosticoId;
  final String nomeDefensivo;
  final String nomePraga;
  final String cultura;

  const DetalheDiagnosticoCleanPage({
    super.key,
    required this.diagnosticoId,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.cultura,
  });

  @override
  State<DetalheDiagnosticoCleanPage> createState() => _DetalheDiagnosticoCleanPageState();
}

class _DetalheDiagnosticoCleanPageState extends State<DetalheDiagnosticoCleanPage>
    with PremiumStatusListener {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DetalheDiagnosticoProvider>();
      provider.loadDiagnosticoData(widget.diagnosticoId);
      provider.loadFavoritoState(widget.diagnosticoId);
      provider.loadPremiumStatus();
    });
  }
  
  @override
  void onPremiumStatusChanged(bool isPremium) {
    // Atualiza o provider quando o status premium muda
    final provider = context.read<DetalheDiagnosticoProvider>();
    provider.loadPremiumStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<DetalheDiagnosticoProvider>(
      builder: (context, provider, child) {
        return BottomNavWrapper(
          selectedIndex: 0, // Assumindo que diagnóstico está relacionado a defensivos
          child: Container(
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
      showActions: provider.isPremium,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () => _toggleFavorito(provider),
      additionalActions: provider.isPremium ? [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _compartilhar(provider),
        ),
      ] : null,
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

  Widget _buildPremiumGate() {
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
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Conteúdo Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este diagnóstico está disponível apenas para usuários premium',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showPremiumDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Assinar Premium'),
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
          // Widget de teste para desenvolvimento (removido automaticamente em produção)
          const PremiumTestControlsWidget(),
          const SizedBox(height: 8),
          
          // Seção de Informações e Imagem (sempre visível)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção de Compartilhamento Premium
        PremiumFeatureWidget(
          isPremium: provider.isPremium,
          title: 'Compartilhamento Avançado',
          description: 'Compartilhe diagnósticos com formatação profissional',
          icon: Icons.share_outlined,
          onPremiumAction: () => _compartilhar(provider),
          onUpgradeRequested: _showPremiumDialog,
        ),
        const SizedBox(height: 16),
        
        // Seção de Comentários Premium (placeholder para futuro)
        PremiumFeatureWidget(
          isPremium: provider.isPremium,
          title: 'Comentários Ilimitados',
          description: 'Adicione comentários e notas pessoais aos diagnósticos',
          icon: Icons.comment_outlined,
          onPremiumAction: () => _showComingSoon('Comentários'),
          onUpgradeRequested: _showPremiumDialog,
        ),
        const SizedBox(height: 16),
        
        // Indicador de Status Premium
        _buildPremiumStatusIndicator(provider),
      ],
    );
  }
  
  Widget _buildPremiumStatusIndicator(DetalheDiagnosticoProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isPremium 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isPremium ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            provider.isPremium ? Icons.diamond : Icons.lock_outline,
            color: provider.isPremium ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.isPremium ? 'Usuário Premium Ativo' : 'Recursos Premium Limitados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.isPremium 
                      ? 'Você tem acesso completo a todos os recursos'
                      : 'Assine Premium para acesso completo aos recursos',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!provider.isPremium)
            TextButton(
              onPressed: _showPremiumDialog,
              child: const Text('Assinar'),
            ),
        ],
      ),
    );
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

  void _compartilhar(DetalheDiagnosticoProvider provider) {
    if (provider.diagnostico == null || provider.diagnosticoData.isEmpty) {
      _showErrorSnackBar('Nenhum diagnóstico para compartilhar');
      return;
    }

    try {
      final shareText = provider.buildShareText(
        widget.diagnosticoId,
        widget.nomeDefensivo,
        widget.nomePraga,
        widget.cultura,
      );
      
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ShareBottomSheetWidget(
          shareText: shareText,
          onSuccess: () => _showSuccessSnackBar('Diagnóstico compartilhado com sucesso'),
          onError: (message) => _showErrorSnackBar(message),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Erro ao preparar compartilhamento');
    }
  }

  void _showPremiumDialog() {
    final theme = Theme.of(context);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          'Funcionalidade Premium',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Este recurso está disponível apenas para usuários premium. '
          'Assine agora para ter acesso completo a todos os recursos.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
  }
  
  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Em breve para usuários Premium!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}