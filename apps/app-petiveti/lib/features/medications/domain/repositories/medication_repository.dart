import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/medication.dart';

abstract class MedicationRepository {
  /// Retorna todos os medicamentos não deletados
  Future<Either<Failure, List<Medication>>> getMedications();

  /// Retorna medicamentos de um animal específico
  Future<Either<Failure, List<Medication>>> getMedicationsByAnimalId(String animalId);

  /// Retorna medicamentos ativos (em tratamento)
  Future<Either<Failure, List<Medication>>> getActiveMedications();

  /// Retorna medicamentos ativos de um animal específico
  Future<Either<Failure, List<Medication>>> getActiveMedicationsByAnimalId(String animalId);

  /// Retorna medicamentos que estão próximos do vencimento
  Future<Either<Failure, List<Medication>>> getExpiringSoonMedications();

  /// Retorna um medicamento específico pelo ID
  Future<Either<Failure, Medication>> getMedicationById(String id);

  /// Adiciona um novo medicamento
  Future<Either<Failure, void>> addMedication(Medication medication);

  /// Atualiza um medicamento existente
  Future<Either<Failure, void>> updateMedication(Medication medication);

  /// Remove um medicamento (soft delete)
  Future<Either<Failure, void>> deleteMedication(String id);

  /// Remove permanentemente um medicamento
  Future<Either<Failure, void>> hardDeleteMedication(String id);

  /// Marca um medicamento como descontinuado
  Future<Either<Failure, void>> discontinueMedication(String id, String reason);

  /// Retorna stream de medicamentos para observar mudanças em tempo real
  Stream<List<Medication>> watchMedications();

  /// Retorna stream de medicamentos de um animal específico
  Stream<List<Medication>> watchMedicationsByAnimalId(String animalId);

  /// Retorna stream de medicamentos ativos
  Stream<List<Medication>> watchActiveMedications();

  /// Busca medicamentos por nome ou tipo
  Future<Either<Failure, List<Medication>>> searchMedications(String query);

  /// Retorna histórico de medicamentos por período
  Future<Either<Failure, List<Medication>>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Verifica se existe conflito de medicamentos (mesmo horário/interação)
  Future<Either<Failure, List<Medication>>> checkMedicationConflicts(
    Medication medication,
  );

  /// Conta total de medicamentos ativos por animal
  Future<Either<Failure, int>> getActiveMedicationsCount(String animalId);

  /// Exporta dados de medicamentos para backup/sync
  Future<Either<Failure, List<Map<String, dynamic>>>> exportMedicationsData();

  /// Importa dados de medicamentos de backup/sync
  Future<Either<Failure, void>> importMedicationsData(
    List<Map<String, dynamic>> data,
  );
}
