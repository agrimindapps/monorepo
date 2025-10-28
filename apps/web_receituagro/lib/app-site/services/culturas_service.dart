import '../classes/cultura_class.dart';
import '../repository/culturas_repository.dart';
import '../core/utils/secure_logger.dart';
import 'validation_service.dart';

/// Service para lógica de negócio das culturas
class CulturasService {
  final CulturaRepository _repository = CulturaRepository();

  /// Cria nova cultura
  Future<CulturaOperationResult> createCultura(
    String cultura,
    int status,
  ) async {
    try {
      final validation = ValidationService.validateCulturaData(cultura, status);

      if (!validation.isValid) {
        return CulturaOperationResult(
          success: false,
          error: validation.message ?? 'Erro de validação',
        );
      }

      final novaCultura = Cultura(
        cultura: validation.sanitizedValue,
        status: status,
      );

      await _repository.createCultura(novaCultura);

      return CulturaOperationResult(success: true, cultura: novaCultura);
    } catch (e) {
      SecureLogger.error('Erro ao criar cultura', error: e);
      return CulturaOperationResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Atualiza cultura existente
  Future<CulturaOperationResult> updateCultura(
    String objectId,
    String cultura,
    int status,
  ) async {
    try {
      final validation = ValidationService.validateCulturaData(cultura, status);

      if (!validation.isValid) {
        return CulturaOperationResult(
          success: false,
          error: validation.message ?? 'Erro de validação',
        );
      }

      final culturaAtualizada = Cultura(
        objectId: objectId,
        cultura: validation.sanitizedValue,
        status: status,
      );

      await _repository.updateCultura(objectId, culturaAtualizada);

      return CulturaOperationResult(success: true, cultura: culturaAtualizada);
    } catch (e) {
      SecureLogger.error('Erro ao atualizar cultura', error: e);
      return CulturaOperationResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Deleta cultura
  Future<CulturaOperationResult> deleteCultura(String objectId) async {
    try {
      await _repository.deleteCultura(objectId);

      return CulturaOperationResult(success: true);
    } catch (e) {
      SecureLogger.error('Erro ao deletar cultura', error: e);
      return CulturaOperationResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  /// Lista todas as culturas
  Future<CulturaListResult> listCulturas() async {
    try {
      final culturas = await _repository.getAllCulturas();

      return CulturaListResult(success: true, culturas: culturas);
    } catch (e) {
      SecureLogger.error('Erro ao listar culturas', error: e);
      return CulturaListResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }

  Future<CulturaOperationResult> getCulturaById(String objectId) async {
    try {
      final culturas = await _repository.getAllCulturas();
      final cultura = culturas.firstWhere(
        (c) => c.objectId == objectId,
        orElse: () => throw Exception('Cultura não encontrada'),
      );

      return CulturaOperationResult(success: true, cultura: cultura);
    } catch (e) {
      SecureLogger.error('Erro ao obter cultura', error: e);
      return CulturaOperationResult(
        success: false,
        error: SecureLogger.getUserFriendlyError(e),
      );
    }
  }
}

/// Resultado de operação com cultura
class CulturaOperationResult {
  final bool success;
  final Cultura? cultura;
  final String? error;

  CulturaOperationResult({required this.success, this.cultura, this.error});
}

/// Resultado de listagem de culturas
class CulturaListResult {
  final bool success;
  final List<Cultura>? culturas;
  final String? error;

  CulturaListResult({required this.success, this.culturas, this.error});
}
