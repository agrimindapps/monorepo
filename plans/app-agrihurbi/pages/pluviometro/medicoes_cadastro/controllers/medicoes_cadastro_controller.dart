// Project imports:
import '../../../../controllers/medicoes_controller.dart';
import '../../../../controllers/pluviometros_controller.dart';
import '../../../../models/medicoes_models.dart';
import '../services/error_handling/error_handler_service.dart';
import '../services/error_handling/medicoes_exceptions.dart';
import '../services/id_service.dart';
import '../services/validators/medicoes_validator.dart';


class MedicoesCadastroController {
  final _idService = IdService();
  final _errorHandler = ErrorHandlerService();

  Future<OperationResult<bool>> saveMedicao({
    required int? createdAt,
    required double quantidade,
    required int dtMedicao,
    required String? id,
    required String? fkPluviometro,
    String? observacoes,
  }) async {
    return await _errorHandler.executeWithRetry<bool>(
      () async {
        // Validação robusta usando o validator
        final validationResult = MedicoesValidator.validateMedicao(
          quantidade: quantidade,
          dtMedicao: dtMedicao,
          id: id,
          fkPluviometro: fkPluviometro,
        );

        // Lança exceção se validação falhar
        MedicoesValidator.throwIfInvalid(validationResult,
            context: 'saveMedicao');

        final medicao = Medicoes(
          id: id ?? _idService.generateUniqueId(),
          createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          fkPluviometro:
              fkPluviometro ?? PluviometrosController().selectedPluviometroId,
          dtMedicao: dtMedicao,
          quantidade: quantidade,
          observacoes: observacoes,
        );

        try {
          if (id != null) {
            await MedicoesController().updateMedicao(medicao);
          } else {
            await MedicoesController().addMedicao(medicao);
          }
          return true;
        } catch (e) {
          throw PersistenceException(
            message: 'Falha ao salvar medição',
            operation: id != null ? 'update' : 'create',
            details: e.toString(),
          );
        }
      },
      operationName: 'saveMedicao',
      maxRetries: 3,
      context: {
        'id': id,
        'quantidade': quantidade,
        'dtMedicao': dtMedicao,
      },
    );
  }
}
