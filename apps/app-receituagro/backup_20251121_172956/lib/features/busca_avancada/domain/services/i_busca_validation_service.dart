import 'package:core/core.dart';
import '../entities/busca_entity.dart';

/// Interface para serviço de validação de busca
/// Principle: Single Responsibility - Only validation logic
abstract class IBuscaValidationService {
  /// Valida se há filtros ativos
  bool hasActiveFilters(BuscaFiltersEntity filters);

  /// Valida parâmetros de busca
  /// Retorna ValidationFailure se inválido, null se válido
  Failure? validateSearchParams(BuscaFiltersEntity filters);

  /// Valida query de texto
  Failure? validateTextQuery(String? query);

  /// Valida se um ID é válido
  bool isValidId(String? id);

  /// Conta filtros ativos
  int countActiveFilters(BuscaFiltersEntity filters);

  /// Constrói texto descritivo dos filtros ativos
  String buildFilterDescription(BuscaFiltersEntity filters);

  /// Valida se o tipo é suportado
  bool isValidType(String type);

  /// Obtém lista de tipos válidos
  List<String> getValidTypes();
}
