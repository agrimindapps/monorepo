import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers/static_data_providers.dart';

/// Widget wrapper que garante que os dados estáticos estão carregados
///
/// Este widget deve envolver o app na primeira inicialização para
/// garantir que as tabelas de referência (culturas, pragas, fitossanitários)
/// estejam populadas antes do usuário acessar qualquer funcionalidade.
///
/// ## Uso:
/// ```dart
/// void main() {
///   runApp(
///     ProviderScope(
///       child: StaticDataInitializer(
///         child: MyApp(),
///       ),
///     ),
///   );
/// }
/// ```
class StaticDataInitializer extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;

  const StaticDataInitializer({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticDataLoadedAsync = ref.watch(staticDataLoadedProvider);

    return staticDataLoadedAsync.when(
      data: (isLoaded) {
        if (!isLoaded) {
          // Dados não carregados, inicia o carregamento
          return FutureBuilder<bool>(
            future: ref.read(loadStaticDataProvider.future),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget ?? _defaultLoadingWidget();
              }

              if (snapshot.hasError) {
                if (errorBuilder != null) {
                  return errorBuilder!(snapshot.error!);
                }
                return _defaultErrorWidget(snapshot.error!);
              }

              if (snapshot.data == true) {
                // Carregamento bem-sucedido, mostra o app
                return child;
              }

              // Falha no carregamento
              return errorBuilder?.call(
                    Exception('Falha ao carregar dados estáticos'),
                  ) ??
                  _defaultErrorWidget(
                    Exception('Falha ao carregar dados estáticos'),
                  );
            },
          );
        }

        // Dados já carregados, mostra o app
        return child;
      },
      loading: () => loadingWidget ?? _defaultLoadingWidget(),
      error: (error, stack) =>
          errorBuilder?.call(error) ?? _defaultErrorWidget(error),
    );
  }

  Widget _defaultLoadingWidget() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando dados...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultErrorWidget(Object error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar dados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
