import 'package:core/core.dart';
import '../entities/defensivo_details_entity.dart';
import '../entities/diagnostico_entity.dart';

/// Interface para repositório de detalhes de defensivos
/// Segue padrões Clean Architecture - domain layer define contratos
abstract class IDefensivoDetailsRepository {
  /// Busca detalhes de um defensivo pelo nome
  Future<Either<Failure, DefensivoDetailsEntity?>> getDefensivoByName(String name);
  
  /// Busca diagnósticos relacionados ao defensivo
  Future<Either<Failure, List<DiagnosticoEntity>>> getDiagnosticosByDefensivo(String defensivoId);
  
  /// Verifica se defensivo está nos favoritos
  Future<Either<Failure, bool>> isFavorited(String defensivoId);
  
  /// Adiciona/remove defensivo dos favoritos
  Future<Either<Failure, bool>> toggleFavorite(String defensivoId, Map<String, dynamic> defensivoData);
}
