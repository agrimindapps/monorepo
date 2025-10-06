export 'lazy_loading_manager.dart';
export 'memory_manager.dart';

/// Arquivo de exportação consolidado para todos os providers de performance
/// 
/// Inclui:
/// - LazyLoadingProvider & LazyLoadingState
/// - MemoryProvider & MemoryState
/// 
/// Uso nos widgets:
/// 
/// ```dart
/// import 'package:app_agrihurbi/core/performance/performance_providers.dart';
/// 
/// // Consumir estado de lazy loading
/// Consumer(
///   builder: (context, ref, child) {
///     final lazyState = ref.watch(lazyLoadingProvider);
///     final memoryState = ref.watch(memoryProvider);
///     
///     return Column(
///       children: [
///         Text('Caches carregados: ${lazyState.loadedKeys.length}'),
///         Text('Memória: ${memoryState.currentMemoryUsageMB.toStringAsFixed(1)}MB'),
///       ],
///     );
///   },
/// )
/// 
/// // Usar lazy loading
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return ElevatedButton(
///       onPressed: () async {
///         final notifier = ref.read(lazyLoadingProvider.notifier);
///         notifier.registerProvider('my_key', () => ExpensiveService());
///         final service = await notifier.getProvider<ExpensiveService>('my_key');
///         // Use service...
///       },
///       child: Text('Carregar Service'),
///     );
///   }
/// }
/// 
/// // Monitorar memória
/// class MemoryMonitor extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final isUnderPressure = ref.watch(isMemoryPressureProvider);
///     final memoryLevel = ref.watch(memoryPressureLevelProvider);
///     
///     if (isUnderPressure) {
///       return AlertDialog(
///         title: Text('Pressão de Memória'),
///         content: Text('Nível: ${memoryLevel.name}'),
///         actions: [
///           TextButton(
///             onPressed: () => ref.read(memoryProvider.notifier).performManualCleanup(),
///             child: Text('Limpar Cache'),
///           ),
///         ],
///       );
///     }
///     
///     return SizedBox.shrink();
///   }
/// }
/// ```
