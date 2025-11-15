import 'package:core/core.dart';

/// Modelo para resultado de verificação de integridade
class DataIntegrityIssue {
  const DataIntegrityIssue({
    required this.type,
    required this.description,
    required this.recordId,
    this.severity = 'warning',
  });

  final String type;
  final String description;
  final String recordId;
  final String severity; // 'info', 'warning', 'error'
}

/// Interface para facade de integridade de dados
///
/// **Responsabilidades (Single Responsibility):**
/// - Orquestrar múltiplos serviços de reconciliação
/// - Verificar integridade geral de dados após sincronização
/// - Reportar problemas detectados
/// - Apenas orquestração, delegação para serviços especializados
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas operações principais)
/// - Segregado de serviços individuais de reconciliação
///
/// **Princípio DIP:**
/// - Depende de IIdReconciliationService abstratos
/// - Não depende de implementações específicas
///
/// **Exemplo:**
/// ```dart
/// final result = await facade.reconcileAllPendingIds();
/// result.fold(
///   (failure) => print('Reconciliation failed: ${failure.message}'),
///   (_) => print('All IDs reconciliated'),
/// );
///
/// final integrity = await facade.verifyDataIntegrity();
/// integrity.fold(
///   (failure) => print('Verification failed: ${failure.message}'),
///   (issues) => print('Issues found: ${issues.length}'),
/// );
/// ```
abstract class IDataIntegrityFacade {
  /// Reconcilia todos os IDs pendentes para todos os domínios
  ///
  /// Delegação para serviços especializados:
  /// - Vehicle IDs
  /// - Fuel IDs
  /// - Maintenance IDs
  ///
  /// Retorna:
  /// - Right(null): Todas as reconciliações completas
  /// - Left(failure): Erro durante reconciliação
  Future<Either<Failure, void>> reconcileAllPendingIds();

  /// Verifica integridade geral de dados
  ///
  /// Procura por:
  /// - Registros órfãos (referências quebradas)
  /// - Inconsistências de versão
  /// - Dados incompletos
  ///
  /// Retorna:
  /// - Right(issues): Lista de problemas encontrados (vazio se ok)
  /// - Left(failure): Erro durante verificação
  Future<Either<Failure, List<DataIntegrityIssue>>> verifyDataIntegrity();
}
