import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/diagnostico_entity.dart';

/// Contrato do repositório de diagnósticos
/// 
/// Define as operações disponíveis para diagnósticos,
/// seguindo os princípios de Clean Architecture
abstract class DiagnosticoRepository {
  /// Busca diagnósticos por ID do defensivo
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByDefensivo(String idDefensivo);
  
  /// Busca diagnósticos por cultura
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByCultura(String cultura);
  
  /// Busca diagnósticos por praga
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByPraga(String praga);
  
  /// Busca um diagnóstico específico por ID
  ResultFuture<DiagnosticoEntity> getDiagnosticoById(String id);
  
  /// Lista todos os diagnósticos com filtros opcionais
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticos({
    String? cultura,
    String? praga,
    String? defensivo,
    int? limit,
    int? offset,
  });
  
  /// Busca diagnósticos por query de texto
  ResultFuture<List<DiagnosticoEntity>> searchDiagnosticos(String query);
  
  /// Stream de diagnósticos em tempo real
  Stream<List<DiagnosticoEntity>> watchDiagnosticos();
}