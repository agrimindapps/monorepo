import '../repository/defensivos_repository.dart';
import '../core/utils/secure_logger.dart';
import 'validation_service.dart';

/// Service para lógica de negócio dos defensivos
class DefensivosService {
  final DefensivosRepository _repository = DefensivosRepository();

  /// Busca defensivos com validação
  Future<DefensivosSearchResult> searchDefensivos(String searchTerm) async {
    try {
      final validation = ValidationService.validateDefensivosSearch(searchTerm);

      if (!validation.isValid) {
        return DefensivosSearchResult(
          success: false,
          error: validation.message ?? 'Erro de validação',
        );
      }

      await _repository.buscaDefensivos(validation.sanitizedValue);

      return DefensivosSearchResult(
        success: true,
        results: _repository.defensivosOnScreen,
        totalCount: _repository.filteredDefensivos.length,
      );
    } catch (e) {
      SecureLogger.error('Erro ao buscar defensivos no service', error: e);
      return DefensivosSearchResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Carrega todos os defensivos
  Future<DefensivosLoadResult> loadAllDefensivos(
      {bool forceRefresh = false}) async {
    try {
      await _repository.fetchAllDefensivos(forceRefresh: forceRefresh);

      return DefensivosLoadResult(
        success: true,
        totalCount: _repository.allDefensivosSearch.length,
        isLoading: _repository.isLoading.value,
      );
    } catch (e) {
      SecureLogger.error('Erro ao carregar defensivos no service', error: e);
      return DefensivosLoadResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
        isLoading: false,
      );
    }
  }

  /// Obtém detalhes do defensivo
  Future<DefensivoDetailResult> getDefensivoDetails(String id) async {
    try {
      final details = await _repository.fetchDefensivoView(id);

      if (details.isEmpty) {
        return DefensivoDetailResult(
          success: false,
          error: 'Defensivo não encontrado',
        );
      }

      return DefensivoDetailResult(
        success: true,
        details: details.first,
      );
    } catch (e) {
      SecureLogger.error('Erro ao obter detalhes do defensivo', error: e);
      return DefensivoDetailResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Navega para página específica
  Future<PaginationResult> navigateToPage(int page) async {
    try {
      final totalPages = _repository.totalPages;

      if (page < 0 || page >= totalPages) {
        return PaginationResult(
          success: false,
          error: 'Página inválida',
        );
      }

      _repository.currentPage.value = page;
      _repository.currentItems();

      return PaginationResult(
        success: true,
        currentPage: page,
        totalPages: totalPages,
        items: _repository.defensivosOnScreen,
      );
    } catch (e) {
      SecureLogger.error('Erro ao navegar para página', error: e);
      return PaginationResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Obtém informações de paginação
  PaginationInfo getPaginationInfo() {
    return PaginationInfo(
      currentPage: _repository.currentPage.value,
      totalPages: _repository.totalPages,
      pageSize: _repository.pageSize,
      totalItems: _repository.filteredDefensivos.length,
      pageNumbers: _repository.pageNumbers,
      hasNextPage: _repository.currentPage.value < _repository.totalPages - 1,
      hasPreviousPage: _repository.currentPage.value > 0,
    );
  }

  /// Limpa cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      SecureLogger.info('Cache limpo com sucesso');
    } catch (e) {
      SecureLogger.error('Erro ao limpar cache', error: e);
    }
  }

  /// Obtém métricas
  Map<String, dynamic> getMetrics() {
    return {
      'cache_metrics': _repository.getCacheMetrics(),
      'current_items': _repository.defensivosOnScreen.length,
      'total_items': _repository.filteredDefensivos.length,
      'current_page': _repository.currentPage.value,
      'total_pages': _repository.totalPages,
    };
  }
}

/// Resultado de busca de defensivos
class DefensivosSearchResult {
  final bool success;
  final List<dynamic>? results;
  final int? totalCount;
  final String? error;

  DefensivosSearchResult({
    required this.success,
    this.results,
    this.totalCount,
    this.error,
  });
}

/// Resultado de carregamento de defensivos
class DefensivosLoadResult {
  final bool success;
  final int? totalCount;
  final bool isLoading;
  final String? error;

  DefensivosLoadResult({
    required this.success,
    this.totalCount,
    required this.isLoading,
    this.error,
  });
}

/// Resultado de detalhes do defensivo
class DefensivoDetailResult {
  final bool success;
  final Map<dynamic, dynamic>? details;
  final String? error;

  DefensivoDetailResult({
    required this.success,
    this.details,
    this.error,
  });
}

/// Resultado de paginação
class PaginationResult {
  final bool success;
  final int? currentPage;
  final int? totalPages;
  final List<dynamic>? items;
  final String? error;

  PaginationResult({
    required this.success,
    this.currentPage,
    this.totalPages,
    this.items,
    this.error,
  });
}

/// Informações de paginação
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;
  final List<int> pageNumbers;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
    required this.pageNumbers,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
