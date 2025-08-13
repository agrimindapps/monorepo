// Flutter imports:
// Removed unused import
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../pages/nova_tarefas_page/views/nova_tarefas_view.dart';
import '../../../pages/web/login_page.dart';
import '../../infrastructure/degraded_mode_service.dart';
import 'navigation_interfaces.dart';

/// Factory para criar widgets baseados no destino de navegação
///
/// Centraliza a criação de widgets para diferentes destinos,
/// permitindo customização e reutilização de componentes
class NavigationWidgetFactory implements INavigationWidgetFactory {
  final Map<AppDestination, Widget Function(NavigationContext)>
      _customBuilders = {};
  final Map<AppDestination, int> _usageStats = {};

  NavigationWidgetFactory() {
    debugPrint('🏭 [NavigationWidgetFactory] Inicializado');
  }

  @override
  Widget createWidget(AppDestination destination, NavigationContext context) {
    final stopwatch = Stopwatch()..start();

    try {
      // Registrar uso
      _usageStats[destination] = (_usageStats[destination] ?? 0) + 1;

      // Verificar se há builder customizado
      final customBuilder = _customBuilders[destination];
      if (customBuilder != null) {
        final widget = customBuilder(context);
        stopwatch.stop();
        debugPrint(
            '🎨 [NavigationWidgetFactory] Widget customizado criado: ${destination.name} '
            '(${stopwatch.elapsedMilliseconds}ms)');
        return widget;
      }

      // Usar builder padrão
      final widget = _createDefaultWidget(destination, context);
      stopwatch.stop();
      debugPrint(
          '🏗️ [NavigationWidgetFactory] Widget padrão criado: ${destination.name} '
          '(${stopwatch.elapsedMilliseconds}ms)');
      return widget;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '❌ [NavigationWidgetFactory] Erro ao criar widget para ${destination.name}: $e');
      return _createErrorWidget(e.toString(), context);
    }
  }

  @override
  bool canCreateWidget(AppDestination destination) {
    return _customBuilders.containsKey(destination) ||
        _hasDefaultBuilder(destination);
  }

  @override
  void registerCustomBuilder(
    AppDestination destination,
    Widget Function(NavigationContext context) builder,
  ) {
    _customBuilders[destination] = builder;
    debugPrint(
        '✅ [NavigationWidgetFactory] Builder customizado registrado para: ${destination.name}');
  }

  /// Cria widget usando builder padrão
  Widget _createDefaultWidget(
      AppDestination destination, NavigationContext context) {
    switch (destination) {
      case AppDestination.loading:
        return _createLoadingWidget(context);

      case AppDestination.error:
        return _createErrorWidget('Erro na aplicação', context);

      case AppDestination.loginPage:
        return _createLoginPageWidget(context);

      case AppDestination.novaTarefasView:
        return _createNovaTarefasViewWidget(context);

      case AppDestination.degradedView:
        return _createDegradedViewWidget(context);

      case AppDestination.recoveringView:
        return _createRecoveringViewWidget(context);

      case AppDestination.offlineView:
        return _createOfflineViewWidget(context);
    }
  }

  Widget _createLoadingWidget(NavigationContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Inicializando módulo Plantas...',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Plataforma: ${context.platform.name}',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createErrorWidget(String error, NavigationContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erro na Aplicação',
                style: Theme.of(context.additionalData['buildContext']
                            as BuildContext? ??
                        Get.context!)
                    .textTheme
                    .headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context.additionalData['buildContext']
                            as BuildContext? ??
                        Get.context!)
                    .textTheme
                    .bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Callback para retry pode ser passado no context
                  final retryCallback =
                      context.additionalData['retryCallback'] as VoidCallback?;
                  if (retryCallback != null) {
                    retryCallback();
                  } else {
                    // Fallback: recarregar a página
                    if (GetPlatform.isWeb) {
                      // Para web, recarregar página
                    } else {
                      // Para mobile, voltar ou mostrar mensagem
                    }
                  }
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createLoginPageWidget(NavigationContext context) {
    return const LoginPage();
  }

  Widget _createNovaTarefasViewWidget(NavigationContext context) {
    return const NovaTarefasView();
  }

  Widget _createDegradedViewWidget(NavigationContext context) {
    return Scaffold(
      appBar: _createDegradedAppBar(context),
      body: Column(
        children: [
          _createDegradedBanner(context),
          Expanded(child: _createDegradedContent(context)),
        ],
      ),
    );
  }

  Widget _createRecoveringViewWidget(NavigationContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Recuperando serviços...',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tentando restaurar funcionalidades',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createOfflineViewWidget(NavigationContext context) {
    final isDarkMode = Theme.of(
                context.additionalData['buildContext'] as BuildContext? ??
                    Get.context!)
            .brightness ==
        Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off,
                size: 64,
                color: isDarkMode ? Colors.orange.shade300 : Colors.orange),
            const SizedBox(height: 16),
            Text(
              context.platform == AppPlatform.mobile
                  ? 'Modo Offline'
                  : 'Sem Conexão',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.platform == AppPlatform.mobile
                  ? 'Funcionalidades limitadas disponíveis'
                  : 'Conecte-se à internet para acessar todas as funcionalidades',
              style: Theme.of(
                      context.additionalData['buildContext'] as BuildContext? ??
                          Get.context!)
                  .textTheme
                  .bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (context.platform == AppPlatform.mobile) ...[
              const Text('🌱 Visualizar plantas offline'),
              const Text('📱 Funcionalidades básicas'),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _createDegradedAppBar(NavigationContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            _getDegradationIcon(context.degradationLevel),
            color: _getDegradationColor(context.degradationLevel),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text('PlantApp'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getDegradationColor(context.degradationLevel)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getDegradationLabel(context.degradationLevel),
              style: TextStyle(
                fontSize: 12,
                color: _getDegradationColor(context.degradationLevel),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final recoveryCallback =
                context.additionalData['recoveryCallback'] as VoidCallback?;
            recoveryCallback?.call();
          },
          tooltip: 'Recovery Inteligente',
        ),
        IconButton(
          icon: const Icon(Icons.restart_alt),
          onPressed: () {
            final retryCallback =
                context.additionalData['retryCallback'] as VoidCallback?;
            retryCallback?.call();
          },
          tooltip: 'Reinicializar',
        ),
      ],
    );
  }

  Widget _createDegradedBanner(NavigationContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color:
          _getDegradationColor(context.degradationLevel).withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(_getDegradationIcon(context.degradationLevel),
              color: _getDegradationColor(context.degradationLevel)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDegradationMessage(context.degradationLevel),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getDegradationColor(context.degradationLevel),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Algumas funcionalidades podem estar limitadas',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDegradationColor(context.degradationLevel)
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDegradedContent(NavigationContext context) {
    if (context.platform == AppPlatform.mobile) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'PlantApp - Modo Limitado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Funcionalidades básicas disponíveis',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text('🌱 Visualizar plantas'),
            Text('🔍 Navegação básica'),
            Text('⚙️ Configurações limitadas'),
          ],
        ),
      );
    } else {
      return _createOfflineViewWidget(context);
    }
  }

  // Helper methods para UI degradada
  IconData _getDegradationIcon(DegradationLevel level) {
    switch (level) {
      case DegradationLevel.none:
        return Icons.check_circle;
      case DegradationLevel.minimal:
        return Icons.warning;
      case DegradationLevel.offline:
        return Icons.cloud_off;
      case DegradationLevel.critical:
        return Icons.error;
    }
  }

  Color _getDegradationColor(DegradationLevel level) {
    switch (level) {
      case DegradationLevel.none:
        return Colors.green;
      case DegradationLevel.minimal:
        return Colors.orange;
      case DegradationLevel.offline:
        return Colors.blue;
      case DegradationLevel.critical:
        return Colors.red;
    }
  }

  String _getDegradationLabel(DegradationLevel level) {
    switch (level) {
      case DegradationLevel.none:
        return 'Normal';
      case DegradationLevel.minimal:
        return 'Limitado';
      case DegradationLevel.offline:
        return 'Offline';
      case DegradationLevel.critical:
        return 'Crítico';
    }
  }

  String _getDegradationMessage(DegradationLevel level) {
    switch (level) {
      case DegradationLevel.none:
        return 'Sistema funcionando normalmente';
      case DegradationLevel.minimal:
        return 'Modo limitado: algumas funcionalidades não estão disponíveis';
      case DegradationLevel.offline:
        return 'Modo offline: funcionalidades que requerem conexão estão desabilitadas';
      case DegradationLevel.critical:
        return 'Modo crítico: apenas funcionalidades essenciais estão disponíveis';
    }
  }

  bool _hasDefaultBuilder(AppDestination destination) {
    // Todos os destinos definidos no enum têm builders padrão
    return true;
  }

  /// Obtém estatísticas de uso dos widgets
  @override
  Map<String, dynamic> getUsageStats() {
    final totalUsage =
        _usageStats.values.fold<int>(0, (sum, count) => sum + count);

    return {
      'total_widgets_created': totalUsage,
      'custom_builders_count': _customBuilders.length,
      'usage_by_destination':
          _usageStats.map((dest, count) => MapEntry(dest.name, count)),
      'custom_destinations':
          _customBuilders.keys.map((dest) => dest.name).toList(),
    };
  }

  /// Remove builder customizado
  void removeCustomBuilder(AppDestination destination) {
    _customBuilders.remove(destination);
    debugPrint(
        '🗑️ [NavigationWidgetFactory] Builder customizado removido: ${destination.name}');
  }

  /// Limpa estatísticas
  void clearStats() {
    _usageStats.clear();
    debugPrint('🧹 [NavigationWidgetFactory] Estatísticas limpas');
  }
}
