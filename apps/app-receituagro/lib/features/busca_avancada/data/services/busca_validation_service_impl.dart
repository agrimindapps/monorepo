import 'package:injectable/injectable.dart';
import 'package:core/core.dart';

import '../../domain/entities/busca_entity.dart';
import '../../domain/services/i_busca_validation_service.dart';

/// Implementação do serviço de validação de busca
@LazySingleton(as: IBuscaValidationService)
class BuscaValidationService implements IBuscaValidationService {
  static const List<String> _validTypes = [
    'diagnostico',
    'praga',
    'defensivo',
    'cultura',
  ];

  static const int _minQueryLength = 2;

  @override
  bool hasActiveFilters(BuscaFiltersEntity filters) {
    return filters.hasActiveFilters;
  }

  @override
  Failure? validateSearchParams(BuscaFiltersEntity filters) {
    if (!hasActiveFilters(filters)) {
      return const ValidationFailure(
        'Selecione pelo menos um filtro para realizar a busca',
      );
    }

    if (filters.query != null && filters.query!.isNotEmpty) {
      final queryValidation = validateTextQuery(filters.query);
      if (queryValidation != null) {
        return queryValidation;
      }
    }

    return null;
  }

  @override
  Failure? validateTextQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return const ValidationFailure('Digite um termo de busca');
    }

    if (query.trim().length < _minQueryLength) {
      return ValidationFailure(
        'O termo de busca deve ter pelo menos $_minQueryLength caracteres',
      );
    }

    return null;
  }

  @override
  bool isValidId(String? id) {
    return id != null && id.trim().isNotEmpty;
  }

  @override
  int countActiveFilters(BuscaFiltersEntity filters) {
    return filters.activeFiltersCount;
  }

  @override
  String buildFilterDescription(BuscaFiltersEntity filters) {
    final parts = <String>[];

    if (filters.culturaId != null) {
      parts.add('Cultura');
    }

    if (filters.pragaId != null) {
      parts.add('Praga');
    }

    if (filters.defensivoId != null) {
      parts.add('Defensivo');
    }

    if (filters.query != null && filters.query!.isNotEmpty) {
      parts.add('Texto: "${filters.query}"');
    }

    if (filters.tipos.isNotEmpty) {
      parts.add('Tipos: ${filters.tipos.join(", ")}');
    }

    if (parts.isEmpty) {
      return 'Nenhum filtro ativo';
    }

    return parts.join(' • ');
  }

  @override
  bool isValidType(String type) {
    return _validTypes.contains(type.toLowerCase());
  }

  @override
  List<String> getValidTypes() {
    return List.unmodifiable(_validTypes);
  }
}
