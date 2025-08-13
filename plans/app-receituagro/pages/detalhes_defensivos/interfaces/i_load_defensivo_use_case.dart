// Project imports:
import '../models/defensivo_details_model.dart';

/// Interface para o caso de uso de carregamento de defensivo
abstract class ILoadDefensivoUseCase {
  /// Carrega todos os dados de um defensivo pelo ID
  Future<DefensivoDetailsModel> execute(String defensivoId);
  
  /// Carrega apenas as características básicas do defensivo
  Future<Map<String, dynamic>> loadBasicData(String defensivoId);
  
  /// Carrega informações detalhadas do defensivo
  Future<Map<String, dynamic>> loadDetailedInfo(String defensivoId);
  
  /// Carrega diagnósticos relacionados ao defensivo
  Future<List<Map<String, dynamic>>> loadDiagnostics(String defensivoId);
}
