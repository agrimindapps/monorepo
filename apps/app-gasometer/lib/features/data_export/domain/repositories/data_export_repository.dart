import '../entities/export_progress.dart';
import '../entities/export_request.dart';
import '../entities/export_result.dart';

/// Interface para repositório de exportação de dados LGPD
abstract class DataExportRepository {
  /// Inicia uma exportação de dados do usuário
  /// 
  /// [request] - Configuração da exportação
  /// [onProgress] - Callback para atualizações de progresso
  /// 
  /// Retorna o resultado da exportação com path do arquivo gerado
  Future<ExportResult> exportUserData(
    ExportRequest request, {
    void Function(ExportProgress progress)? onProgress,
  });

  /// Verifica se o usuário pode fazer uma nova exportação
  /// (rate limiting - 1 exportação por dia)
  Future<bool> canExportData(String userId);

  /// Obtém o histórico de exportações do usuário
  Future<List<ExportResult>> getExportHistory(String userId);

  /// Remove arquivos temporários de exportação
  Future<void> cleanupTemporaryFiles();

  /// Valida se uma solicitação de exportação está correta
  Future<bool> validateExportRequest(ExportRequest request);

  /// Estima o tamanho da exportação sem executá-la
  Future<Map<String, dynamic>> estimateExportSize(ExportRequest request);
}