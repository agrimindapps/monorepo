// Package imports:
import 'package:get/get.dart';

/// Estados básicos comuns para todas as operações CRUD
enum OperationState {
  idle,
  loading,
  success,
  error,
}

/// Estados específicos para operações de carregamento de dados
enum LoadingState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Tipos de erro padronizados
enum AppErrorType {
  network,
  database,
  validation,
  authentication,
  permission,
  unknown,
}

/// Modelo de erro padronizado
class AppError {
  final AppErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details)';
  }

  /// Factory methods para tipos comuns de erro
  factory AppError.network(String message, {String? details, dynamic originalError}) {
    return AppError(
      type: AppErrorType.network,
      message: message,
      details: details,
      originalError: originalError,
    );
  }

  factory AppError.database(String message, {String? details, dynamic originalError}) {
    return AppError(
      type: AppErrorType.database,
      message: message,
      details: details,
      originalError: originalError,
    );
  }

  factory AppError.validation(String message, {String? details}) {
    return AppError(
      type: AppErrorType.validation,
      message: message,
      details: details,
    );
  }

  factory AppError.permission(String message, {String? details}) {
    return AppError(
      type: AppErrorType.permission,
      message: message,
      details: details,
    );
  }
}

/// Base class para todos os controllers que gerenciam estado CRUD
abstract class BaseStateManager extends GetxController {
  // Estados básicos observáveis
  final _operationState = OperationState.idle.obs;
  final _loadingState = LoadingState.initial.obs;
  final _error = Rxn<AppError>();
  final _successMessage = RxnString();

  // Getters para acessar os estados
  OperationState get operationState => _operationState.value;
  LoadingState get loadingState => _loadingState.value;
  AppError? get error => _error.value;
  String? get successMessage => _successMessage.value;

  // Estados computados para facilitar uso na UI
  bool get isIdle => _operationState.value == OperationState.idle;
  bool get isLoading => _operationState.value == OperationState.loading;
  bool get hasError => _operationState.value == OperationState.error && _error.value != null;
  bool get hasSuccess => _operationState.value == OperationState.success;

  // Estados de carregamento específicos
  bool get isInitialLoad => _loadingState.value == LoadingState.initial;
  bool get isDataLoading => _loadingState.value == LoadingState.loading;
  bool get isDataLoaded => _loadingState.value == LoadingState.loaded;
  bool get isDataEmpty => _loadingState.value == LoadingState.empty;
  bool get hasLoadingError => _loadingState.value == LoadingState.error;

  /// Métodos para atualizar estados
  void setOperationState(OperationState state) {
    _operationState.value = state;
  }

  void setLoadingState(LoadingState state) {
    _loadingState.value = state;
  }

  void setError(AppError error) {
    _error.value = error;
    _operationState.value = OperationState.error;
    _successMessage.value = null;
  }

  void setSuccess([String? message]) {
    _operationState.value = OperationState.success;
    _successMessage.value = message;
    _error.value = null;
  }

  void clearError() {
    _error.value = null;
    if (_operationState.value == OperationState.error) {
      _operationState.value = OperationState.idle;
    }
  }

  void clearSuccess() {
    _successMessage.value = null;
    if (_operationState.value == OperationState.success) {
      _operationState.value = OperationState.idle;
    }
  }

  void reset() {
    _operationState.value = OperationState.idle;
    _loadingState.value = LoadingState.initial;
    _error.value = null;
    _successMessage.value = null;
  }

  /// Helper method para executar operações com gerenciamento de estado automático
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? successMessage,
    String? errorMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setOperationState(OperationState.loading);
      }

      final result = await operation();

      setSuccess(successMessage);
      return result;
    } catch (e, stackTrace) {
      final error = e is AppError 
          ? e 
          : AppError(
              type: AppErrorType.unknown,
              message: errorMessage ?? 'Erro inesperado',
              details: e.toString(),
              originalError: e,
              stackTrace: stackTrace,
            );
      
      setError(error);
      return null;
    }
  }

  /// Helper method para carregar dados com estados de loading apropriados
  Future<T?> loadData<T>(
    Future<T> Function() loader, {
    String? errorMessage,
    bool isEmpty = false,
  }) async {
    try {
      setLoadingState(LoadingState.loading);

      final result = await loader();

      if (isEmpty) {
        setLoadingState(LoadingState.empty);
      } else {
        setLoadingState(LoadingState.loaded);
      }

      return result;
    } catch (e, stackTrace) {
      setLoadingState(LoadingState.error);
      
      final error = e is AppError 
          ? e 
          : AppError(
              type: AppErrorType.unknown,
              message: errorMessage ?? 'Erro ao carregar dados',
              details: e.toString(),
              originalError: e,
              stackTrace: stackTrace,
            );
      
      setError(error);
      return null;
    }
  }

  /// Métodos abstratos que devem ser implementados pelos controllers filhos
  Future<void> initialize();
  @override
  Future<void> refresh();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    // Limpar recursos se necessário
    super.onClose();
  }
}

/// Mixin para controllers que gerenciam listas de dados
mixin ListStateMixin<T> on BaseStateManager {
  final RxList<T> _items = <T>[].obs;
  final RxList<T> _filteredItems = <T>[].obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = ''.obs;

  // Getters para acessar os dados
  List<T> get items => _items;
  List<T> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;

  // Estados computados
  bool get hasItems => _items.isNotEmpty;
  bool get hasFilteredItems => _filteredItems.isNotEmpty;
  int get itemCount => _items.length;
  int get filteredItemCount => _filteredItems.length;

  /// Métodos para gerenciar lista
  void setItems(List<T> items) {
    _items.assignAll(items);
    _applyFilters();
  }

  void addItem(T item) {
    _items.add(item);
    _applyFilters();
  }

  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      _applyFilters();
    }
  }

  void removeItem(T item) {
    _items.remove(item);
    _applyFilters();
  }

  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _applyFilters();
    }
  }

  void clearItems() {
    _items.clear();
    _filteredItems.clear();
  }

  /// Métodos para gerenciar filtros
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void setFilter(String filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedFilter.value = '';
    _applyFilters();
  }

  /// Método abstrato que deve ser implementado para definir lógica de filtro
  List<T> filterItems(List<T> items, String searchQuery, String filter);

  void _applyFilters() {
    final filtered = filterItems(_items, _searchQuery.value, _selectedFilter.value);
    _filteredItems.assignAll(filtered);
    
    // Atualizar estado de loading baseado nos resultados
    if (filtered.isEmpty && _items.isNotEmpty) {
      setLoadingState(LoadingState.empty);
    } else if (filtered.isNotEmpty) {
      setLoadingState(LoadingState.loaded);
    }
  }

  /// Override para incluir limpeza da lista
  @override
  void reset() {
    super.reset();
    clearItems();
    clearFilters();
  }
}

/// Mixin para controllers que gerenciam formulários
mixin FormStateMixin on BaseStateManager {
  final _isFormValid = false.obs;
  final _isDirty = false.obs;
  final _fieldErrors = <String, String>{}.obs;

  // Getters para estado do formulário
  bool get isFormValid => _isFormValid.value;
  bool get isDirty => _isDirty.value;
  Map<String, String> get fieldErrors => _fieldErrors;
  bool get hasFieldErrors => _fieldErrors.isNotEmpty;

  /// Métodos para gerenciar estado do formulário
  void setFormValid(bool isValid) {
    _isFormValid.value = isValid;
  }

  void setDirty(bool dirty) {
    _isDirty.value = dirty;
  }

  void setFieldError(String field, String error) {
    _fieldErrors[field] = error;
    _validateForm();
  }

  void clearFieldError(String field) {
    _fieldErrors.remove(field);
    _validateForm();
  }

  void clearAllFieldErrors() {
    _fieldErrors.clear();
    _validateForm();
  }

  String? getFieldError(String field) {
    return _fieldErrors[field];
  }

  bool hasFieldError(String field) {
    return _fieldErrors.containsKey(field);
  }

  /// Método abstrato para validação customizada
  bool validateForm();

  void _validateForm() {
    setFormValid(validateForm() && _fieldErrors.isEmpty);
  }

  /// Override para incluir reset do formulário
  @override
  void reset() {
    super.reset();
    _isFormValid.value = false;
    _isDirty.value = false;
    _fieldErrors.clear();
  }
}

/// Controller base específico para operações CRUD
abstract class BaseCrudController<T> extends BaseStateManager with ListStateMixin<T> {
  /// Métodos abstratos que devem ser implementados
  Future<List<T>> loadItems();
  Future<T?> createItem(T item);
  Future<bool> updateItemById(String id, T item);
  Future<bool> deleteItem(String id);

  @override
  Future<void> initialize() async {
    await loadData(
      () async {
        final items = await loadItems();
        setItems(items);
        return items;
      },
      errorMessage: 'Erro ao inicializar dados',
      isEmpty: _items.isEmpty,
    );
  }

  @override
  Future<void> refresh() async {
    await loadData(
      () async {
        final items = await loadItems();
        setItems(items);
        return items;
      },
      errorMessage: 'Erro ao atualizar dados',
      isEmpty: _items.isEmpty,
    );
  }

  Future<void> create(T item) async {
    final result = await executeOperation(
      () => createItem(item),
      successMessage: 'Item criado com sucesso',
      errorMessage: 'Erro ao criar item',
    );

    if (result != null) {
      addItem(result);
    }
  }

  Future<void> updateById(String id, T item) async {
    final success = await executeOperation(
      () => updateItemById(id, item),
      successMessage: 'Item atualizado com sucesso',
      errorMessage: 'Erro ao atualizar item',
    );

    if (success == true) {
      // Recarregar dados para garantir consistência
      await refresh();
    }
  }

  Future<void> delete(String id) async {
    final success = await executeOperation(
      () => deleteItem(id),
      successMessage: 'Item excluído com sucesso',
      errorMessage: 'Erro ao excluir item',
    );

    if (success == true) {
      // Remover item da lista local
      _items.removeWhere((item) => getItemId(item) == id);
      _applyFilters();
    }
  }

  /// Método abstrato para obter ID do item
  String getItemId(T item);
}
