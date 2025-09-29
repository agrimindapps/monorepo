import 'package:core/core.dart';
import '../entities/diagnostico_entity.dart';
import '../repositories/i_defensivo_details_repository.dart';

class GetDiagnosticosParams {
  final String defensivoId;

  const GetDiagnosticosParams({required this.defensivoId});
}

/// Use case para buscar diagnósticos relacionados a um defensivo
class GetDiagnosticosUsecase implements UseCase<List<DiagnosticoEntity>, GetDiagnosticosParams> {
  final IDefensivoDetailsRepository repository;

  const GetDiagnosticosUsecase({required this.repository});

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> call(GetDiagnosticosParams params) async {
    return await repository.getDiagnosticosByDefensivo(params.defensivoId);
  }
}