import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utilitários e helpers para facilitar o uso do Riverpod nos apps
/// Padroniza patterns comuns e reduz boilerplate

/// Widget base que todos os apps devem usar em vez de StatelessWidget
/// Automaticamente implementa ConsumerWidget para acesso ao Riverpod
abstract class BaseConsumerWidget extends ConsumerWidget {
  const BaseConsumerWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref);
}

/// Widget base para pages que automaticamente implementa ConsumerWidget
/// e adiciona funcionalidades comuns como loading, error handling
abstract class BasePage extends ConsumerWidget {
  const BasePage({super.key});
  
  /// Título da página (usado para analytics e navegação)
  String get pageTitle;
  
  /// Se true, mostra loading global quando algum provider estiver carregando
  bool get showGlobalLoading => true;
  
  /// Se true, mostra errors globais automaticamente
  bool get showGlobalErrors => true;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: buildBody(context, ref),
      floatingActionButton: buildFloatingActionButton(context, ref),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
    );
  }
  
  /// Constrói a AppBar da página (override para customizar)
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(title: Text(pageTitle));
  }
  
  /// Constrói o corpo principal da página (obrigatório implementar)
  Widget buildBody(BuildContext context, WidgetRef ref);
  
  /// Constrói o FloatingActionButton (override para customizar)
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return null;
  }
  
  /// Constrói a BottomNavigationBar (override para customizar)
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return null;
  }
}

/// Widget base para formulários que implementa validação automática
abstract class BaseFormWidget extends BaseConsumerWidget {
  const BaseFormWidget({super.key});
  
  /// Form key para validação
  @protected
  GlobalKey<FormState> get formKey;
  
  /// Constrói os campos do formulário
  @protected
  List<Widget> buildFormFields(BuildContext context, WidgetRef ref);
  
  /// Ação executada quando o formulário é submetido
  @protected
  Future<void> onFormSubmit(BuildContext context, WidgetRef ref);
  
  /// Validação customizada do formulário (override se necessário)
  @protected
  bool validateForm() => formKey.currentState?.validate() ?? false;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          ...buildFormFields(context, ref),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (validateForm()) {
                await onFormSubmit(context, ref);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

/// Mixin que adiciona funcionalidades de loading a qualquer ConsumerWidget
mixin LoadingMixin on ConsumerWidget {
  /// Mostra loading overlay
  void showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Esconde loading overlay
  void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Executa uma ação com loading automático
  Future<T> withLoading<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    showLoading(context);
    try {
      return await action();
    } finally {
      if (context.mounted) {
        hideLoading(context);
      }
    }
  }
}

/// Mixin que adiciona funcionalidades de error handling
mixin ErrorHandlingMixin on ConsumerWidget {
  /// Mostra erro via SnackBar
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Mostra sucesso via SnackBar
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  /// Mostra dialog de erro
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Mixin que adiciona funcionalidades de navegação
mixin NavigationMixin on ConsumerWidget {
  /// Navega para uma rota
  void navigateTo(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
  
  /// Substitui a rota atual
  void navigateReplace(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }
  
  /// Volta para a tela anterior
  void navigateBack(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }
  
  /// Navega e remove todas as rotas anteriores
  void navigateAndClearStack(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (route) => false,
    );
  }
}

/// Extension para WidgetRef com funcionalidades extras
extension WidgetRefExtensions on WidgetRef {
  /// Le um provider de forma segura, retornando null se houver erro
  T? readSafe<T>(ProviderListenable<T> provider) {
    try {
      return read(provider);
    } catch (e) {
      return null;
    }
  }
  
  /// Observa um provider de forma segura, retornando default se houver erro
  T watchSafe<T>(ProviderListenable<T> provider, T defaultValue) {
    try {
      return watch(provider);
    } catch (e) {
      return defaultValue;
    }
  }
  
  /// Invalida múltiplos providers de uma vez
  void invalidateAll(List<ProviderBase<dynamic>> providers) {
    for (final provider in providers) {
      invalidate(provider);
    }
  }
  
  /// Executa uma ação após o próximo build
  void postFrameCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }
}

/// Extension para StateController com funcionalidades extras
extension StateControllerExtensions<T> on StateController<T> {
  /// Atualiza o estado apenas se for diferente do atual
  void updateIfDifferent(T newState) {
    if (state != newState) {
      state = newState;
    }
  }
  
  /// Atualiza o estado de forma segura (não quebra se disposed)
  void safeUpdate(T newState) {
    try {
      state = newState;
    } catch (e) {
    }
  }
}

/// Widget que mostra loading, error ou conteúdo baseado em AsyncValue
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });
  
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  
  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: error ??
          (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Erro: $err'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
    );
  }
}

/// Widget que consome um provider e automaticamente mostra loading/error
class ProviderConsumerWidget<T> extends ConsumerWidget {
  const ProviderConsumerWidget({
    super.key,
    required this.provider,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });
  
  final ProviderListenable<AsyncValue<T>> provider;
  final Widget Function(BuildContext context, WidgetRef ref, T data) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorWidget;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);
    
    return AsyncValueWidget<T>(
      value: asyncValue,
      data: (data) => builder(context, ref, data),
      loading: loadingWidget,
      error: errorWidget != null 
        ? (error, stack) => errorWidget!(context, error, stack)
        : null,
    );
  }
}

/// Helper para criar StateNotifierProvider com menos boilerplate
StateNotifierProvider<TNotifier, TState> createStateNotifierProvider<TNotifier extends StateNotifier<TState>, TState>(
  TNotifier Function(Ref ref) create, {
  String? name,
}) {
  return StateNotifierProvider<TNotifier, TState>((ref) => create(ref), name: name);
}

/// Helper para criar FutureProvider com menos boilerplate
FutureProvider<T> createFutureProvider<T>(
  Future<T> Function(Ref ref) create, {
  String? name,
}) {
  return FutureProvider<T>((ref) => create(ref), name: name);
}

/// Helper para criar StreamProvider com menos boilerplate
StreamProvider<T> createStreamProvider<T>(
  Stream<T> Function(Ref ref) create, {
  String? name,
}) {
  return StreamProvider<T>((ref) => create(ref), name: name);
}

/// Mixin que adiciona funcionalidades de debounce
mixin DebounceMixin {
  Timer? _debounceTimer;
  
  /// Executa uma ação com debounce
  void debounce(Duration duration, VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }
  
  /// Cancela o debounce atual
  void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
  
  /// Dispose do debounce (chamar no dispose do widget)
  void disposeDebounce() {
    _debounceTimer?.cancel();
  }
}

/// Função utilitária para criar providers com debounce
Provider<T> createDebouncedProvider<T>(
  T Function(Ref ref) create,
  Duration debounceDuration,
) {
  Timer? debounceTimer;
  T? cachedValue;
  
  return Provider<T>((ref) {
    if (cachedValue != null) return cachedValue as T;
    
    debounceTimer?.cancel();
    debounceTimer = Timer(debounceDuration, () {
      cachedValue = create(ref);
    });
    
    return create(ref); // Retorna valor imediato na primeira chamada
  });
}