import 'package:core/core.dart';

import '../../domain/entities/export_request.dart';

/// Validador de solicitações de exportação
///
/// Responsabilidade: Validar requisições de exportação
/// Aplica SRP (Single Responsibility Principle)

class ExportValidator {
  /// Valida uma solicitação de exportação
  Either<Failure, Unit> validateExportRequest(ExportRequest request) {
    // Valida user ID
    if (request.userId.isEmpty) {
      return const Left(ValidationFailure('ID de usuário é obrigatório'));
    }

    // Valida categorias
    if (request.includedCategories.isEmpty) {
      return const Left(
        ValidationFailure('Selecione pelo menos uma categoria para exportar'),
      );
    }

    // Valida categorias são válidas
    final validCategories = ExportDataCategory.getAllKeys();
    for (final category in request.includedCategories) {
      if (!validCategories.contains(category)) {
        return Left(ValidationFailure('Categoria inválida: $category'));
      }
    }

    // Valida formatos de saída
    if (request.outputFormats.isEmpty) {
      return const Left(
        ValidationFailure('Selecione pelo menos um formato de exportação'),
      );
    }

    // Valida formatos são suportados
    final validFormats = ['json', 'csv'];
    for (final format in request.outputFormats) {
      if (!validFormats.contains(format)) {
        return Left(ValidationFailure('Formato não suportado: $format'));
      }
    }

    // Valida range de datas
    if (request.startDate != null && request.endDate != null) {
      if (request.startDate!.isAfter(request.endDate!)) {
        return const Left(
          ValidationFailure('Data de início deve ser anterior à data de fim'),
        );
      }

      // Valida range não é muito grande (máximo 5 anos)
      final difference = request.endDate!.difference(request.startDate!);
      if (difference.inDays > 365 * 5) {
        return const Left(
          ValidationFailure('Período de exportação não pode exceder 5 anos'),
        );
      }
    }

    return const Right(unit);
  }

  /// Valida se o tamanho estimado é aceitável
  Either<Failure, Unit> validateExportSize(int estimatedSizeMb) {
    // Limite de 500MB
    if (estimatedSizeMb > 500) {
      return const Left(
        ValidationFailure(
          'Exportação muito grande (limite: 500MB). Reduza o período ou categorias.',
        ),
      );
    }

    return const Right(unit);
  }

  /// Verifica se categorias específicas são válidas
  bool isCategoryValid(String category) {
    return ExportDataCategory.getAllKeys().contains(category);
  }

  /// Verifica se formato é válido
  bool isFormatValid(String format) {
    return ['json', 'csv'].contains(format);
  }
}

/// Categorias de dados disponíveis para exportação
class ExportDataCategory {
  static const String profile = 'profile';
  static const String vehicles = 'vehicles';
  static const String fuelRecords = 'fuel_records';
  static const String maintenance = 'maintenance';
  static const String odometer = 'odometer';
  static const String expenses = 'expenses';
  static const String categories = 'categories';
  static const String settings = 'settings';

  static List<String> getAllKeys() {
    return [
      profile,
      vehicles,
      fuelRecords,
      maintenance,
      odometer,
      expenses,
      categories,
      settings,
    ];
  }

  static String getDisplayName(String key) {
    switch (key) {
      case profile:
        return 'Perfil do Usuário';
      case vehicles:
        return 'Veículos';
      case fuelRecords:
        return 'Registros de Combustível';
      case maintenance:
        return 'Manutenções';
      case odometer:
        return 'Odômetro';
      case expenses:
        return 'Despesas';
      case categories:
        return 'Categorias';
      case settings:
        return 'Configurações';
      default:
        return key;
    }
  }
}
