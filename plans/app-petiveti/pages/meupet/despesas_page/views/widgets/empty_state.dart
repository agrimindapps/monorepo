// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../config/despesas_page_config.dart';

/// Enhanced empty state widget with different scenarios
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Widget? illustration;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DespesasPageConfig.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: DespesasPageConfig.spacingLarge),
            ] else ...[
              Icon(
                icon,
                size: 64,
                color: iconColor ?? Colors.grey[400],
              ),
              const SizedBox(height: DespesasPageConfig.spacingMedium),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DespesasPageConfig.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: DespesasPageConfig.spacingLarge),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DespesasPageConfig.spacingLarge,
                    vertical: DespesasPageConfig.spacingMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty states for different scenarios
class NoAnimalSelectedState extends StatelessWidget {
  const NoAnimalSelectedState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.pets_outlined,
      title: 'Selecione um Animal',
      message: 'Escolha um animal acima para visualizar suas despesas veterinárias.',
      iconColor: Colors.blue,
    );
  }
}

class NoDespesasState extends StatelessWidget {
  final VoidCallback? onAddDespesa;

  const NoDespesasState({
    super.key,
    this.onAddDespesa,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Nenhuma Despesa Cadastrada',
      message: 'Ainda não há despesas registradas para este animal neste período.',
      actionText: 'Adicionar Despesa',
      onAction: onAddDespesa,
      iconColor: Colors.green,
    );
  }
}

class NoSearchResultsState extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onClearSearch;

  const NoSearchResultsState({
    super.key,
    required this.searchTerm,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'Nenhum Resultado',
      message: 'Não encontramos despesas que correspondam à busca "$searchTerm".',
      actionText: 'Limpar Busca',
      onAction: onClearSearch,
      iconColor: Colors.orange,
    );
  }
}

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Ops! Algo deu errado',
      message: error,
      actionText: 'Tentar Novamente',
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }
}

/// Loading state with skeleton
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DespesasPageConfig.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: DespesasPageConfig.spacingMedium),
            Text(
              message ?? DespesasPageConfig.labelCarregando,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
