// Project imports:
import '../../database/planta_model.dart';

/// Interface para PlantaRepository
///
/// Define contrato para operações de dados de plantas,
/// permitindo dependency injection e testabilidade
abstract class IPlantaRepository {
  /// Inicializar o repository
  Future<void> initialize();

  /// Buscar todas as plantas
  Future<List<PlantaModel>> findAll();

  /// Buscar planta por ID
  Future<PlantaModel?> findById(String id);

  /// Buscar múltiplas plantas por IDs
  Future<List<PlantaModel>> findByIds(List<String> ids);

  /// Buscar plantas por espaço
  Future<List<PlantaModel>> findByEspaco(String espacoId);

  /// Buscar plantas por nome (case insensitive, contains)
  Future<List<PlantaModel>> findByNome(String nome);

  /// Criar nova planta
  Future<String> criar(PlantaModel planta);

  /// Atualizar planta existente
  Future<void> atualizar(PlantaModel planta);

  /// Remover planta
  Future<void> remover(String id);

  /// Remover múltiplas plantas por espaço
  Future<void> removerPorEspaco(String espacoId);

  /// Stream de todas as plantas
  Stream<List<PlantaModel>> get dataStream;

  /// Stream de plantas por espaço
  Stream<List<PlantaModel>> watchByEspaco(String espacoId);

  /// Contar plantas por espaço
  Future<Map<String, int>> countByEspaco();

  /// Buscar plantas que precisam cuidados hoje
  Future<List<PlantaModel>> findPrecisaCuidadosHoje();

  /// Buscar plantas com tarefas atrasadas
  Future<List<PlantaModel>> findComTarefasAtrasadas();

  /// Stream de plantas que precisam água hoje
  Stream<List<PlantaModel>> watchPrecisaAguaHoje();

  /// Stream de plantas que precisam adubo hoje
  Stream<List<PlantaModel>> watchPrecisaAduboHoje();

  /// Stream de plantas que precisam banho de sol hoje
  Stream<List<PlantaModel>> watchPrecisaBanhoSolHoje();

  /// Stream de plantas que precisam inspeção de pragas hoje
  Stream<List<PlantaModel>> watchPrecisaInspecaoPragasHoje();

  /// Stream de plantas que precisam poda hoje
  Stream<List<PlantaModel>> watchPrecisaPodaHoje();

  /// Stream de plantas que precisam replantio hoje
  Stream<List<PlantaModel>> watchPrecisaReplantioHoje();

  /// Stream de plantas com água ativa
  Stream<List<PlantaModel>> watchComAguaAtiva();

  /// Stream de plantas com adubo ativo
  Stream<List<PlantaModel>> watchComAduboAtivo();

  /// Stream de plantas com banho de sol ativo
  Stream<List<PlantaModel>> watchComBanhoSolAtivo();

  /// Stream de plantas com inspeção de pragas ativa
  Stream<List<PlantaModel>> watchComInspecaoPragasAtiva();

  /// Stream de plantas com poda ativa
  Stream<List<PlantaModel>> watchComPodaAtiva();

  /// Stream de plantas com replantio ativo
  Stream<List<PlantaModel>> watchComReplantioAtivo();

  /// Completar rega para uma planta
  Future<void> completarRega(String plantaId);

  /// Completar adubação para uma planta
  Future<void> completarAdubacao(String plantaId);

  /// Completar banho de sol para uma planta
  Future<void> completarBanhoSol(String plantaId);

  /// Completar inspeção de pragas para uma planta
  Future<void> completarInspecaoPragas(String plantaId);

  /// Completar poda para uma planta
  Future<void> completarPoda(String plantaId);

  /// Completar replantio para uma planta
  Future<void> completarReplantio(String plantaId);

  /// Toggle água ativa/inativa
  Future<void> toggleAgua(String plantaId);

  /// Toggle adubo ativo/inativo
  Future<void> toggleAdubo(String plantaId);

  /// Toggle banho de sol ativo/inativo
  Future<void> toggleBanhoSol(String plantaId);

  /// Toggle inspeção de pragas ativa/inativa
  Future<void> toggleInspecaoPragas(String plantaId);

  /// Toggle poda ativa/inativa
  Future<void> togglePoda(String plantaId);

  /// Toggle replantio ativo/inativo
  Future<void> toggleReplantio(String plantaId);

  /// Dispose resources
  void dispose();
}
