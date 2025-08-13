// Project imports:
import '../../database/planta_config_model.dart';

/// Interface para PlantaConfigRepository
///
/// Define contrato para operações de dados de configurações de plantas,
/// permitindo dependency injection e testabilidade
abstract class IPlantaConfigRepository {
  /// Inicializar o repository
  Future<void> initialize();

  /// Buscar todas as configurações
  Future<List<PlantaConfigModel>> findAll();

  /// Buscar configuração por ID
  Future<PlantaConfigModel?> findById(String id);

  /// Buscar configuração por planta ID
  Future<PlantaConfigModel?> findByPlantaId(String plantaId);

  /// Buscar múltiplas configurações por IDs de plantas
  Future<List<PlantaConfigModel>> findByPlantaIds(List<String> plantaIds);

  /// Buscar configurações ativas
  Future<List<PlantaConfigModel>> findActiveConfigs();

  /// Buscar configurações por tipo de cuidado ativo
  Future<List<PlantaConfigModel>> findByActiveCareType(String careType);

  /// Criar nova configuração
  Future<String> criar(PlantaConfigModel config);

  /// Criar configuração padrão para planta
  Future<String> criarPadrao(String plantaId);

  /// Atualizar configuração existente
  Future<void> atualizar(PlantaConfigModel config);

  /// Remover configuração
  Future<void> remover(String id);

  /// Remover configuração por planta
  Future<void> removerPorPlanta(String plantaId);

  /// Ativar tipo de cuidado
  Future<void> activateCareType(String plantaId, String careType);

  /// Desativar tipo de cuidado
  Future<void> deactivateCareType(String plantaId, String careType);

  /// Atualizar intervalo de cuidado
  Future<void> updateCareInterval(
      String plantaId, String careType, int intervalDays);

  /// Executar operação de cuidado genérica
  Future<void> executeCareOperation(
      String plantaId, String careType, bool activate,
      [int? intervalDays]);

  /// Configurar múltiplos tipos de cuidado
  Future<void> activateMultipleCareTypes(
      String plantaId, Map<String, int> careTypesAndIntervals);

  /// Configurar planta completa
  Future<void> setupPlantCare(String plantaId, Map<String, dynamic> careConfig);

  /// Stream de todas as configurações
  Stream<List<PlantaConfigModel>> get dataStream;

  /// Stream de configurações ativas
  Stream<List<PlantaConfigModel>> watchActiveConfigs();

  /// Stream de configuração por planta
  Stream<PlantaConfigModel?> watchByPlantaId(String plantaId);

  /// Dispose resources
  void dispose();
}
