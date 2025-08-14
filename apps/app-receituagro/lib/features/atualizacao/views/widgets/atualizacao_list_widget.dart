import 'package:flutter/material.dart';
import '../../constants/atualizacao_design_tokens.dart';
import '../../models/atualizacao_model.dart';

/// Specialized widget for displaying list of updates
class AtualizacaoListWidget extends StatelessWidget {
  final List<AtualizacaoModel> atualizacoes;
  final bool isDark;
  final Function(AtualizacaoModel)? onVersionTap;

  const AtualizacaoListWidget({
    super.key,
    required this.atualizacoes,
    required this.isDark,
    this.onVersionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (atualizacoes.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      margin: AtualizacaoDesignTokens.defaultPadding,
      decoration: AtualizacaoDesignTokens.getCardDecoration(context),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: atualizacoes.length,
        itemBuilder: (context, index) => _buildVersionItem(context, index),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      ),
    );
  }

  Widget _buildVersionItem(BuildContext context, int index) {
    final atualizacao = atualizacoes[index];
    final isLatest = index == 0; // First item is latest
    
    return InkWell(
      onTap: onVersionTap != null ? () => onVersionTap!(atualizacao) : null,
      borderRadius: BorderRadius.circular(AtualizacaoDesignTokens.cardBorderRadius),
      child: Padding(
        padding: AtualizacaoDesignTokens.listTilePadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionIcon(context, isLatest: isLatest),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVersionContent(context, atualizacao, isLatest: isLatest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionIcon(BuildContext context, {bool isLatest = false}) {
    return Container(
      width: AtualizacaoDesignTokens.iconContainerSize,
      height: AtualizacaoDesignTokens.iconContainerSize,
      decoration: AtualizacaoDesignTokens.getVersionIconDecoration(
        context,
        isLatest: isLatest,
      ),
      child: Icon(
        AtualizacaoDesignTokens.getVersionIcon(isLatest: isLatest),
        size: AtualizacaoDesignTokens.iconSize,
        color: AtualizacaoDesignTokens.getVersionIconColor(
          context,
          isLatest: isLatest,
        ),
      ),
    );
  }

  Widget _buildVersionContent(
    BuildContext context,
    AtualizacaoModel atualizacao, {
    bool isLatest = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVersionTitle(context, atualizacao, isLatest: isLatest),
        const SizedBox(height: 8),
        _buildReleaseNotes(context, atualizacao),
      ],
    );
  }

  Widget _buildVersionTitle(
    BuildContext context,
    AtualizacaoModel atualizacao, {
    bool isLatest = false,
  }) {
    return Row(
      children: [
        Text(
          atualizacao.versao,
          style: AtualizacaoDesignTokens.getVersionTitleStyle(
            context,
            isLatest: isLatest,
          ),
        ),
        if (isLatest) ...[
          const SizedBox(width: 8),
          _buildLatestBadge(),
        ],
      ],
    );
  }

  Widget _buildLatestBadge() {
    return Container(
      padding: AtualizacaoDesignTokens.badgePadding,
      decoration: AtualizacaoDesignTokens.getBadgeDecoration(),
      child: const Text(
        AtualizacaoDesignTokens.latestVersionBadge,
        style: AtualizacaoDesignTokens.badgeTextStyle,
      ),
    );
  }

  Widget _buildReleaseNotes(BuildContext context, AtualizacaoModel atualizacao) {
    if (atualizacao.notas.isEmpty) {
      return Text(
        'Nenhuma nota de versão disponível',
        style: AtualizacaoDesignTokens.getReleaseNotesStyle(context).copyWith(
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      atualizacao.formattedNotas,
      style: AtualizacaoDesignTokens.getReleaseNotesStyle(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: AtualizacaoDesignTokens.defaultPadding,
      decoration: AtualizacaoDesignTokens.getCardDecoration(context),
      padding: AtualizacaoDesignTokens.emptyStatePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AtualizacaoDesignTokens.historyIcon,
            size: AtualizacaoDesignTokens.emptyStateIconSize,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AtualizacaoDesignTokens.emptyStateTitle,
            style: AtualizacaoDesignTokens.getEmptyStateTitleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AtualizacaoDesignTokens.emptyStateSubtitle,
            style: AtualizacaoDesignTokens.getEmptyStateSubtitleStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}