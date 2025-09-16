import 'package:flutter/material.dart';
import '../../domain/entities/calculation_result.dart';

/// Widget para exibição de resultados de cálculo
/// 
/// Apresenta os resultados de forma organizada e visual
/// Suporta múltiplos valores de saída e interpretações
class CalculationResultDisplay extends StatelessWidget {
  final CalculationResult result;

  const CalculationResultDisplay({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.isValid) {
      return _buildErrorResult(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resultado principal
        if (result.primaryValue != null) 
          _buildPrimaryResult(context),
        
        const SizedBox(height: 16),
        
        // Valores adicionais
        if (result.values.isNotEmpty)
          _buildAdditionalValues(context),
        
        // Interpretação/recomendações
        if (result.interpretation != null) ...[
          const SizedBox(height: 16),
          _buildInterpretation(context),
        ],
        
        // Warnings ou observações
        if (result.warnings?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          _buildWarnings(context),
        ],
        
        // Timestamp do cálculo
        const SizedBox(height: 16),
        _buildTimestamp(context),
      ],
    );
  }

  Widget _buildErrorResult(BuildContext context) {
    if (result is CalculationError) {
      final error = result as CalculationError;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Erro no Cálculo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Resultado inválido',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildPrimaryResult(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado Principal',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatValue(result.primaryValue),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (result.getPrimaryResult()?.unit != null) ...[
            const SizedBox(height: 4),
            Text(
              result.getPrimaryResult()!.unit,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalValues(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valores Adicionais',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...result.getSecondaryResults().map((value) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    value.formattedValue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInterpretation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interpretação',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            result.interpretation!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarnings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...result.warnings!.map((warning) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Calculado em ${_formatTimestamp(result.calculatedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '—';
    
    if (value is num) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      } else {
        return value.toStringAsFixed(2);
      }
    }
    
    return value.toString();
  }

  String _formatLabel(String key) {
    // Converte snake_case ou camelCase para formato legível
    return key
        .replaceAllMapped(RegExp(r'[_-]'), (match) => ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/'
             '${timestamp.month.toString().padLeft(2, '0')}/'
             '${timestamp.year} às '
             '${timestamp.hour.toString().padLeft(2, '0')}:'
             '${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}