import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/atualizacao_design_tokens.dart';
import '../controller/atualizacao_controller.dart';
import '../models/atualizacao_model.dart';
import 'widgets/atualizacao_list_widget.dart';
import 'widgets/modern_header_widget.dart';

/// Main updates page following SOLID principles
class AtualizacaoPage extends StatelessWidget {
  const AtualizacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AtualizacaoController>(
      builder: (context, controller, child) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AtualizacaoDesignTokens.maxPageWidth,
                ),
                child: Column(
                  children: [
                    _buildModernHeader(context, controller),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildBody(context, controller),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(BuildContext context, AtualizacaoController controller) {
    return ModernHeaderWidget(
      title: AtualizacaoDesignTokens.pageTitle,
      subtitle: AtualizacaoDesignTokens.pageSubtitle,
      leftIcon: AtualizacaoDesignTokens.branchIcon,
      isDark: controller.state.isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBody(BuildContext context, AtualizacaoController controller) {
    final state = controller.state;

    if (state.isLoading) {
      return _buildLoadingState(context, state.isDark);
    }

    if (state.hasError) {
      return _buildErrorState(context, controller);
    }

    return Column(
      children: [
        if (state.hasData) ...[
          _buildStatsHeader(context, controller),
          const SizedBox(height: 16),
        ],
        AtualizacaoListWidget(
          atualizacoes: state.atualizacoesList,
          isDark: state.isDark,
          onVersionTap: (version) => _onVersionTap(context, version),
        ),
        const SizedBox(height: 80), // Extra space for better UX
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Container(
      margin: AtualizacaoDesignTokens.defaultPadding,
      decoration: AtualizacaoDesignTokens.getCardDecoration(context),
      padding: AtualizacaoDesignTokens.emptyStatePadding,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            AtualizacaoDesignTokens.loadingMessage,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AtualizacaoController controller) {
    return Container(
      margin: AtualizacaoDesignTokens.defaultPadding,
      decoration: AtualizacaoDesignTokens.getCardDecoration(context),
      padding: AtualizacaoDesignTokens.emptyStatePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AtualizacaoDesignTokens.errorIcon,
            size: AtualizacaoDesignTokens.emptyStateIconSize,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            AtualizacaoDesignTokens.errorLoadingMessage,
            style: AtualizacaoDesignTokens.getEmptyStateTitleStyle(context).copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.state.error!,
              style: AtualizacaoDesignTokens.getEmptyStateSubtitleStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.recarregarAtualizacoes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, AtualizacaoController controller) {
    final theme = Theme.of(context);
    final state = controller.state;
    
    return Container(
      margin: AtualizacaoDesignTokens.defaultPadding.copyWith(bottom: 0),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total de versões: ${state.totalAtualizacoes}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.latestVersion != null)
            Text(
              'Versão atual: ${state.latestVersion!.versao}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AtualizacaoDesignTokens.latestVersionIconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  void _onVersionTap(BuildContext context, AtualizacaoModel version) {
    // Show version details dialog
    showDialog(
      context: context,
      builder: (context) => _buildVersionDialog(context, version),
    );
  }

  Widget _buildVersionDialog(BuildContext context, AtualizacaoModel version) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            AtualizacaoDesignTokens.getVersionIcon(isLatest: false),
            color: AtualizacaoDesignTokens.primaryColor,
          ),
          const SizedBox(width: 12),
          Text('Versão ${version.versao}'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (version.notas.isNotEmpty) ...[
              Text(
                'Novidades:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...version.notas.map((nota) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        nota,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ] else
              Text(
                'Nenhuma nota de versão disponível.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}