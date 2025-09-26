import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../providers/body_condition_provider.dart';

/// State indicator widget for Body Condition Calculator
/// 
/// Responsibilities:
/// - Display loading, error, and validation states
/// - Keep state indication logic separate from main page
/// - Provide consistent status feedback
class BodyConditionStateIndicator extends ConsumerWidget {
  const BodyConditionStateIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyConditionProvider);
    
    if (state.isLoading) {
      return _buildLoadingIndicator();
    }

    if (state.hasError) {
      return _buildErrorIndicator(context, ref, state);
    }

    if (state.hasValidationErrors) {
      return _buildValidationErrorIndicator(state);
    }

    return const SizedBox.shrink();
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.blue.withValues(alpha: 0.1),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Calculando...'),
        ],
      ),
    );
  }

  /// Build error indicator
  Widget _buildErrorIndicator(BuildContext context, WidgetRef ref, dynamic state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.red.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (state.error as String?) ?? 'Erro desconhecido',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(bodyConditionProvider.notifier).clearError(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Build validation error indicator
  Widget _buildValidationErrorIndicator(dynamic state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.orange.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Text(
                'Dados incompletos:',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...(state.validationErrors as List<String>? ?? <String>[]).map<Widget>((error) => Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              '• $error',
              style: const TextStyle(color: Colors.orange),
            ),
          )),
        ],
      ),
    );
  }
}