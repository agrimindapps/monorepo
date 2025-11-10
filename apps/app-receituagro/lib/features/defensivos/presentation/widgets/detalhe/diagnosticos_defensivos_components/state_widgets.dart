import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../../../core/theme/spacing_tokens.dart';
import '../../../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';

/// Widget para gerenciamento de estados da lista de diagnósticos
class DiagnosticoDefensivoStateManager extends ConsumerWidget {
  final String defensivoName;
  final Widget Function(List<dynamic>) builder;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoStateManager({
    super.key,
    required this.defensivoName,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosticosAsync = ref.watch(diagnosticosNotifierProvider);

    return diagnosticosAsync.when(
      data: (diagnosticosState) {
        if (diagnosticosState.isLoading) {
          return const DiagnosticoDefensivoLoadingWidget();
        }

        if (diagnosticosState.hasError) {
          return DiagnosticoDefensivoErrorWidget(
            errorMessage: diagnosticosState.errorMessage ?? 'Erro desconhecido',
            onRetry: onRetry,
          );
        }

        final diagnosticosParaExibir =
            diagnosticosState.searchQuery.isNotEmpty
                ? diagnosticosState.searchResults
                : diagnosticosState.filteredDiagnosticos;

        if (diagnosticosParaExibir.isEmpty) {
          return DiagnosticoDefensivoEmptyWidget(defensivoName: defensivoName);
        }

        return builder(diagnosticosParaExibir);
      },
      loading: () => const DiagnosticoDefensivoLoadingWidget(),
      error:
          (error, _) => DiagnosticoDefensivoErrorWidget(
            errorMessage: error.toString(),
            onRetry: onRetry,
          ),
    );
  }
}

/// Widget para estado de carregamento
class DiagnosticoDefensivoLoadingWidget extends StatelessWidget {
  const DiagnosticoDefensivoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(SpacingTokens.xxl),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Widget para estado de erro
class DiagnosticoDefensivoErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DiagnosticoDefensivoErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Erro ao carregar diagnósticos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para estado vazio
class DiagnosticoDefensivoEmptyWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticoDefensivoEmptyWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Nenhum diagnóstico encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Não há diagnósticos disponíveis para $defensivoName',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
