// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/atualizacao_model.dart';
import '../models/release_notes_model.dart';
import '../services/version_service.dart';
import 'atualizacoes_constants.dart';

class AtualizacoesHelpers {
  static Widget buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(AtualizacoesConstants.loadingMessage),
          ],
        ),
      ),
    );
  }

  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AtualizacoesConstants.emptyIcon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              AtualizacoesConstants.emptyMessage,
              style: AtualizacoesConstants.emptyStateStyle,
            ),
            const SizedBox(height: 8),
            Text(
              AtualizacoesConstants.emptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static BorderRadius getCardBorderRadius() {
    return BorderRadius.circular(AtualizacoesConstants.cardBorderRadius);
  }

  static EdgeInsets getCardPadding() {
    return AtualizacoesConstants.cardPadding;
  }

  static EdgeInsets getDefaultPadding() {
    return AtualizacoesConstants.defaultPadding;
  }

  static String formatVersion(String version) {
    return VersionService.formatVersion(version);
  }

  static String getVersionType(String version) {
    return VersionService.getVersionType(version);
  }

  static bool isLatestVersion(String version, List<Atualizacao> atualizacoes) {
    final latest = AtualizacaoRepository.getLatestVersion(atualizacoes);
    return latest != null && latest.versao == version;
  }

  static Color getVersionColor(Atualizacao atualizacao, List<Atualizacao> allVersions) {
    if (atualizacao.isImportante) {
      return AtualizacoesConstants.importantColor;
    }
    
    if (isLatestVersion(atualizacao.versao, allVersions)) {
      return AtualizacoesConstants.featureColor;
    }
    
    return Colors.black87;
  }

  static IconData getVersionIcon(Atualizacao atualizacao, List<Atualizacao> allVersions) {
    if (atualizacao.isImportante) {
      return AtualizacoesConstants.importantIcon;
    }
    
    if (isLatestVersion(atualizacao.versao, allVersions)) {
      return AtualizacoesConstants.featureIcon;
    }
    
    return AtualizacoesConstants.versionIcon;
  }

  static Widget buildVersionBadge(Atualizacao atualizacao, List<Atualizacao> allVersions) {
    if (!atualizacao.isImportante && !isLatestVersion(atualizacao.versao, allVersions)) {
      return const SizedBox.shrink();
    }

    String label;
    Color color;
    IconData icon;

    if (atualizacao.isImportante) {
      label = 'Importante';
      color = AtualizacoesConstants.importantColor;
      icon = AtualizacoesConstants.importantIcon;
    } else {
      label = 'Mais recente';
      color = AtualizacoesConstants.featureColor;
      icon = AtualizacoesConstants.featureIcon;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static List<ReleaseNote> parseReleaseNotes(List<String> notasTexto) {
    return ReleaseNotesHelper.parseFromStringList(notasTexto);
  }

  static Widget buildReleaseNote(ReleaseNote nota) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nota.icone,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nota.texto,
              style: AtualizacoesConstants.releaseNoteStyle.copyWith(
                fontWeight: nota.isDestaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String getNotasPreview(List<String> notas, {int maxLines = 3}) {
    if (notas.isEmpty) return AtualizacoesConstants.noReleaseNotes;
    
    if (notas.length <= maxLines) {
      return notas.join('\n');
    }
    
    final preview = notas.take(maxLines).join('\n');
    final remaining = notas.length - maxLines;
    return '$preview\n... e mais $remaining ${remaining == 1 ? 'item' : 'itens'}';
  }

  static String formatNotasCount(int count) {
    if (count == 0) return 'Nenhuma nota';
    if (count == 1) return '1 nota';
    return '$count notas';
  }

  static Widget buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? Colors.blue).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (color ?? Colors.blue).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'Data desconhecida';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getRelativeTimeString(DateTime? date) {
    if (date == null) return '';
    
    final duration = VersionService.getTimeSinceVersion('', date);
    return VersionService.formatTimeSinceRelease(duration);
  }

  static Color getBackgroundColor() {
    return AtualizacoesConstants.backgroundColor;
  }

  static Color getCardBackgroundColor() {
    return AtualizacoesConstants.cardBackgroundColor;
  }

  static Duration getAnimationDuration() {
    return AtualizacoesConstants.animationDuration;
  }

  static Curve getAnimationCurve() {
    return AtualizacoesConstants.animationCurve;
  }

  static bool shouldShowExpanded(List<String> notas) {
    return notas.length > AtualizacoesConstants.maxNotesPreview;
  }

  static List<String> highlightSearchTerms(String text, String searchTerm) {
    if (searchTerm.isEmpty) return [text];
    
    final parts = text.split(RegExp(searchTerm, caseSensitive: false));
    final List<String> result = [];
    
    for (int i = 0; i < parts.length; i++) {
      result.add(parts[i]);
      if (i < parts.length - 1) {
        result.add(searchTerm);
      }
    }
    
    return result;
  }

  static double getResponsiveWidth(BuildContext context) {
    return AtualizacoesConstants.getResponsiveWidth(context);
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return AtualizacoesConstants.getResponsivePadding(context);
  }
}
