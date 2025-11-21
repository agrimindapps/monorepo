import 'package:core/core.dart';

import '../entities/diagnostico_entity.dart';

/// Interface Segregation Pattern: CRUD operations for diagnosticos
/// 
/// Focused responsibility: Create, Read operations (diagnosticos are read-only in current implementation)
/// Does NOT include complex queries, filtering, or recommendations
/// 
/// This follows ISP principle - clients only depend on methods they use
abstract class IDiagnosticosCrudRepository {
  /// Gets a diagnostico by its ID
  Future<Either<Failure, DiagnosticoEntity>> getById(String id);

  /// Gets all diagnosticos
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll();
}
