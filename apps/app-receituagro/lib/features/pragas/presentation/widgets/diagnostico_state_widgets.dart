import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/diagnosticos_praga_notifier.dart';

/// Widgets para diferentes estados da lista de diagnósticos
///
/// Responsabilidade única: renderizar estados específicos da UI
/// - Loading: indicador de carregamento
/// - Error: mensagem de erro com retry
/// - Empty: estado vazio com mensagens contextuais
/// - Performance otimizada com const constructors

/// Widget para estado de carregamento
class DiagnosticoLoadingWidget extends StatelessWidget {
  const DiagnosticoLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Widget para estado de erro
class DiagnosticoErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const DiagnosticoErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar diagnósticos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
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
class DiagnosticoEmptyWidget extends ConsumerWidget {
  const DiagnosticoEmptyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticosPragaNotifierProvider);

    return RepaintBoundary(
      child: state.when(
        data: (data) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.diagnosticos.isEmpty
                      ? Icons.bug_report_outlined
                      : Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  data.diagnosticos.isEmpty
                      ? 'Nenhum diagnóstico disponível'
                      : 'Nenhum diagnóstico encontrado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  data.diagnosticos.isEmpty
                      ? 'Esta praga ainda não possui diagnósticos cadastrados ou os dados estão sendo carregados'
                      : 'Tente ajustar os filtros de pesquisa',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (data.diagnosticos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(diagnosticosPragaNotifierProvider.notifier).clearFilters();
                    },
                    child: const Text('Limpar Filtros'),
                  ),
                ],
              ],
            ),
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (error, _) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Widget wrapper que gerencia automaticamente os estados
class DiagnosticoStateManager extends ConsumerWidget {
  final Widget Function(List<DiagnosticoModel> diagnosticos) builder;
  final VoidCallback? onRetry;

  const DiagnosticoStateManager({
    super.key,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticosPragaNotifierProvider);

    return state.when(
      data: (data) {
        if (data.groupedDiagnosticos.isEmpty) {
          return const DiagnosticoEmptyWidget();
        }
        return builder(data.filteredDiagnosticos);
      },
      loading: () => const DiagnosticoLoadingWidget(),
      error: (error, _) => DiagnosticoErrorWidget(
        errorMessage: error.toString(),
        onRetry: onRetry,
      ),
    );
  }
}