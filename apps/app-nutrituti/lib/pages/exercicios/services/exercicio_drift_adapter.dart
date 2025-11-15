import 'package:drift/drift.dart' as drift;
import '../../../drift_database/nutrituti_database.dart';
import '../models/exercicio_model.dart';

/// Adapter para converter entre ExercicioModel e Drift Exercicio
extension ExercicioModelExtensions on ExercicioModel {
  /// Converte ExercicioModel para Drift Companion (para inserção/update)
  ExerciciosCompanion toCompanion() {
    return ExerciciosCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      nome: drift.Value(nome),
      categoria: drift.Value(categoria),
      duracao: drift.Value(duracao),
      caloriasQueimadas: drift.Value(caloriasQueimadas.toDouble()),
      dataRegistro: drift.Value(
        DateTime.fromMillisecondsSinceEpoch(dataRegistro),
      ),
      observacoes: drift.Value(observacoes),
      isSynced: const drift.Value(false),
      isPending: const drift.Value(true),
    );
  }

  /// Converte ExercicioModel para Drift Companion de update
  ExerciciosCompanion toUpdateCompanion() {
    return ExerciciosCompanion(
      id: drift.Value(id!),
      nome: drift.Value(nome),
      categoria: drift.Value(categoria),
      duracao: drift.Value(duracao),
      caloriasQueimadas: drift.Value(caloriasQueimadas.toDouble()),
      dataRegistro: drift.Value(
        DateTime.fromMillisecondsSinceEpoch(dataRegistro),
      ),
      observacoes: drift.Value(observacoes),
      updatedAt: drift.Value(DateTime.now()),
    );
  }
}

/// Extension para converter Drift Exercicio para ExercicioModel
extension ExercicioDriftExtensions on Exercicio {
  /// Converte Drift Exercicio para ExercicioModel
  ExercicioModel toModel() {
    return ExercicioModel(
      id: id,
      nome: nome,
      categoria: categoria,
      duracao: duracao,
      caloriasQueimadas: caloriasQueimadas.toInt(),
      dataRegistro: dataRegistro.millisecondsSinceEpoch,
      observacoes: observacoes,
    );
  }
}
