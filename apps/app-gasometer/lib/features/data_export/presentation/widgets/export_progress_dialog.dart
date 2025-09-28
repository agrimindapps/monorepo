import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/export_progress.dart';

/// Dialog para mostrar o progresso da exportação
class ExportProgressDialog extends StatelessWidget {

  const ExportProgressDialog({
    super.key,
    this.progress,
    this.onCancel,
  });
  final ExportProgress? progress;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(height: 20),
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildSubtitle(context),
            const SizedBox(height: 24),
            _buildProgressIndicator(context),
            const SizedBox(height: 16),
            _buildProgressText(context),
            if (progress?.processedCounts.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildProcessedCounts(context),
            ],
            const SizedBox(height: 24),
            if (_canCancel && onCancel != null) _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color iconColor;
    
    switch (progress?.phase) {
      case 'completed':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'error':
        icon = Icons.error;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = Icons.download;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
    }

    return Icon(
      icon,
      size: 48,
      color: iconColor,
    );
  }

  Widget _buildTitle(BuildContext context) {
    String title;
    
    switch (progress?.phase) {
      case 'completed':
        title = 'Exportação Concluída!';
        break;
      case 'error':
        title = 'Erro na Exportação';
        break;
      default:
        title = 'Exportando Dados...';
        break;
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    String subtitle;
    
    switch (progress?.phase) {
      case 'completed':
        subtitle = 'Seus dados foram exportados com sucesso';
        break;
      case 'error':
        subtitle = 'Ocorreu um erro durante a exportação';
        break;
      default:
        subtitle = 'Por favor, aguarde enquanto coletamos seus dados';
        break;
    }

    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final percentage = progress?.percentage ?? 0.0;
    
    if (progress?.phase == 'completed') {
      return const Icon(
        Icons.check_circle_outline,
        size: 64,
        color: Colors.green,
      );
    } else if (progress?.phase == 'error') {
      return Icon(
        Icons.error_outline,
        size: 64,
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: percentage / 100,
          strokeWidth: 6,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressText(BuildContext context) {
    final currentTask = progress?.currentTask ?? 'Preparando...';
    
    return Text(
      currentTask,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProcessedCounts(BuildContext context) {
    final counts = progress?.processedCounts ?? <String, int>{};
    final processed = counts['processed'] ?? 0;
    final total = counts['total'] ?? 0;
    
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.data_usage,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Processados: $processed de $total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onCancel,
      child: const Text('Cancelar'),
    );
  }

  bool get _canCancel {
    return progress?.phase != 'completed' && 
           progress?.phase != 'error' &&
           progress?.percentage != 100.0;
  }
}