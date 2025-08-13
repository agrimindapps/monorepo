// Project imports:
import '../../constants/care_type_const.dart';
import '../../repository/espaco_repository.dart';
import '../../repository/planta_config_repository.dart';
import '../../repository/planta_repository.dart';
import '../../repository/tarefa_repository.dart';
import '../../shared/utils/string_comparison_utils.dart';

/// Serviço centralizado para regras de negócio
/// Responsabilidade: Implementar lógica de negócio que não pertence diretamente aos repositories
class BusinessRulesService {
  static BusinessRulesService? _instance;
  // Late final singleton pattern com thread safety
  static BusinessRulesService get instance {
    return _instance ??= BusinessRulesService._();
  }

  // Late final para repositories - garantir inicialização única e imutável
  late final EspacoRepository _espacoRepository;
  late final PlantaRepository _plantaRepository;
  late final PlantaConfigRepository _plantaConfigRepository;
  late final TarefaRepository _tarefaRepository;

  BusinessRulesService._() {
    // Inicializar repositories de forma segura
    _espacoRepository = EspacoRepository.instance;
    _plantaRepository = PlantaRepository.instance;
    _plantaConfigRepository = PlantaConfigRepository.instance;
    _tarefaRepository = TarefaRepository.instance;
  }

  /// Verificar se existe espaço com nome (regra de negócio de unicidade)
  /// FIXED: Usa comparação normalizada para caracteres acentuados
  Future<bool> existeEspacoComNome(String nome, {String? excluirId}) async {
    // Assertions para validar parâmetros
    assert(nome.trim().isNotEmpty, 'Nome para verificação não pode ser vazio');
    assert(excluirId == null || excluirId.trim().isNotEmpty,
        'Se fornecido, excluirId deve ser válido');

    final espacos = await _espacoRepository.findAll();

    return espacos.any((espaco) {
      // Null safety: garantir que nome do espaço seja válido
      final espacoNome = espaco.nome;
      if (espacoNome.trim().isEmpty) return false;

      return StringComparisonUtils.equals(espacoNome, nome) &&
          espaco.ativo &&
          (excluirId == null || espaco.id != excluirId);
    });
  }

  /// Verificar se existe planta com nome no mesmo espaço
  /// FIXED: Usa comparação normalizada para caracteres acentuados
  Future<bool> existePlantaComNome(String nome, String espacoId,
      {String? excluirId}) async {
    // Assertions para validar parâmetros
    assert(nome.trim().isNotEmpty, 'Nome da planta não pode ser vazio');
    assert(espacoId.trim().isNotEmpty, 'espacoId não pode ser vazio');
    assert(excluirId == null || excluirId.trim().isNotEmpty,
        'Se fornecido, excluirId deve ser válido');

    final plantas = await _plantaRepository.findByEspaco(espacoId);

    return plantas.any((planta) {
      // Null safety: garantir que nome da planta seja válido
      final plantaNome = planta.nome;
      if (plantaNome == null || plantaNome.trim().isEmpty) return false;

      return StringComparisonUtils.equals(plantaNome, nome) &&
          (excluirId == null || planta.id != excluirId);
    });
  }

  /// Verificar se é permitido excluir um espaço
  Future<bool> podeExcluirEspaco(String espacoId) async {
    // Assertion para validar parâmetro
    assert(espacoId.trim().isNotEmpty, 'espacoId não pode ser vazio');

    final plantas = await _plantaRepository.findByEspaco(espacoId);
    // Null object pattern: garantir lista válida
    return plantas.isEmpty; // Só pode excluir se não houver plantas
  }

  /// Verificar se é permitido excluir uma planta
  Future<bool> podeExcluirPlanta(String plantaId) async {
    // Assertion para validar parâmetro
    assert(plantaId.trim().isNotEmpty, 'plantaId não pode ser vazio');

    final tarefas = await _tarefaRepository.findByPlanta(plantaId);
    // Null object pattern: garantir lista válida para verificação
    return !tarefas.any((tarefa) => tarefa.pendente);
  }

  /// Verificar se um espaço pode ser desativado
  Future<bool> podeDesativarEspaco(String espacoId) async {
    final plantas = await _plantaRepository.findByEspaco(espacoId);
    // Só pode desativar se todas as plantas tiverem tarefas concluídas
    for (final planta in plantas) {
      final tarefasPendentes = await _tarefaRepository.findByPlanta(planta.id);
      if (tarefasPendentes.any((tarefa) => tarefa.pendente)) {
        return false;
      }
    }
    return true;
  }

  /// Verificar se uma configuração de planta é válida para criação
  Future<bool> podeConfigurarPlanta(String plantaId) async {
    // Assertion para validar parâmetro
    assert(plantaId.trim().isNotEmpty, 'plantaId não pode ser vazio');

    final planta = await _plantaRepository.findById(plantaId);
    if (planta == null) return false;

    // Null safety: garantir que espacoId seja válido
    final espacoId = planta.espacoId;
    if (espacoId == null || espacoId.trim().isEmpty) return false;

    // Verificar se o espaço está ativo
    final espaco = await _espacoRepository.findById(espacoId);
    return espaco?.ativo ?? false;
  }

  /// Determinar próxima data para cuidado baseado em regras de negócio
  Future<DateTime?> calcularProximoCuidado(
      String plantaId, String tipoCuidado) async {
    final config = await _plantaConfigRepository.findByPlantaId(plantaId);
    if (config == null) return null;

    final intervalo = config.getIntervalForCareType(tipoCuidado);
    if (intervalo <= 0) return null;

    // Buscar última tarefa do mesmo tipo
    final tarefas = await _tarefaRepository.findByPlanta(plantaId);
    final ultimaTarefa = tarefas
        .where((t) => t.tipoCuidado == tipoCuidado && t.concluida)
        .fold<DateTime?>(null, (latest, tarefa) {
      if (latest == null) return tarefa.dataExecucao;
      return tarefa.dataExecucao.isAfter(latest) ? tarefa.dataExecucao : latest;
    });

    final baseDate = ultimaTarefa ?? DateTime.now();
    return baseDate.add(Duration(days: intervalo));
  }

  /// Verificar se uma planta precisa de cuidado específico hoje
  Future<bool> plantaPrecisaCuidadoHoje(
      String plantaId, String tipoCuidado) async {
    final proximaData = await calcularProximoCuidado(plantaId, tipoCuidado);
    if (proximaData == null) return false;

    final hoje = DateTime.now();
    return proximaData.isBefore(hoje.add(const Duration(days: 1))) &&
        proximaData.isAfter(hoje.subtract(const Duration(days: 1)));
  }

  /// Validar se um tipo de cuidado é válido
  /// Usa CareType.isValidCareType para garantir consistência
  bool ehTipoCuidadoValido(String tipoCuidado) {
    return CareType.isValidCareType(tipoCuidado);
  }

  /// Verificar se é hora de criar tarefa automática
  Future<bool> devecriarTarefaAutomatica(
      String plantaId, String tipoCuidado) async {
    final config = await _plantaConfigRepository.findByPlantaId(plantaId);
    if (config == null || !config.isCareTypeActive(tipoCuidado)) return false;

    // Verificar se já existe tarefa pendente do mesmo tipo
    final tarefas = await _tarefaRepository.findByPlanta(plantaId);
    final jaTemPendente = tarefas.any((t) =>
        t.tipoCuidado == tipoCuidado &&
        t.pendente &&
        t.dataExecucao
            .isAfter(DateTime.now().subtract(const Duration(days: 1))));

    if (jaTemPendente) return false;

    // Verificar se chegou a hora baseada no intervalo
    return await plantaPrecisaCuidadoHoje(plantaId, tipoCuidado);
  }

  /// Calcular prioridade de uma tarefa baseada em regras de negócio
  int calcularPrioridadeTarefa(String tipoCuidado, DateTime dataExecucao) {
    final hoje = DateTime.now();
    final diasAtraso = hoje.difference(dataExecucao).inDays;

    // Prioridade base por tipo de cuidado
    int prioridadeBase;
    switch (tipoCuidado) {
      case 'agua': // CareType.agua.value
        prioridadeBase = 10;
        break;
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        prioridadeBase = 8;
        break;
      case 'adubo': // CareType.adubo.value
        prioridadeBase = 6;
        break;
      case 'poda': // CareType.poda.value
        prioridadeBase = 4;
        break;
      case 'banho_sol': // CareType.banhoSol.value
        prioridadeBase = 3;
        break;
      case 'replantio': // CareType.replantio.value
        prioridadeBase = 2;
        break;
      default:
        prioridadeBase = 5;
    }

    // Aumentar prioridade por dias de atraso
    return prioridadeBase + (diasAtraso > 0 ? diasAtraso * 2 : 0);
  }

  /// Verificar se uma tarefa é para hoje
  bool isTarefaForToday(dynamic tarefa) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (tarefa is Map) {
      final dataExecucao = tarefa['dataExecucao'] as DateTime?;
      if (dataExecucao == null) return false;
      
      final taskDate = DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
      return taskDate == today;
    }

    // Para objetos TarefaModel - implementar quando necessário
    return false;
  }

  /// Verificar se uma tarefa está atrasada
  bool isTarefaOverdue(dynamic tarefa) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (tarefa is Map) {
      final dataExecucao = tarefa['dataExecucao'] as DateTime?;
      final concluida = tarefa['concluida'] as bool? ?? false;
      
      if (dataExecucao == null || concluida) return false;
      
      final taskDate = DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
      return taskDate.isBefore(today);
    }

    // Para objetos TarefaModel - implementar quando necessário
    return false;
  }

  /// Verificar se uma tarefa é urgente
  bool isTarefaUrgent(dynamic tarefa) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (tarefa is Map) {
      final dataExecucao = tarefa['dataExecucao'] as DateTime?;
      final tipoCuidado = tarefa['tipoCuidado'] as String? ?? '';
      final concluida = tarefa['concluida'] as bool? ?? false;
      
      if (dataExecucao == null || concluida) return false;
      
      final taskDate = DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
      final diasAtraso = today.difference(taskDate).inDays;
      
      // Tarefas de água são urgentes se atrasadas em 1 dia ou mais
      if (tipoCuidado == 'agua' && diasAtraso >= 1) return true;
      
      // Outras tarefas são urgentes se atrasadas em 3 dias ou mais
      return diasAtraso >= 3;
    }

    return false;
  }

  /// Verificar se uma planta pode ser movida para um espaço
  Future<bool> canMovePlantaToSpace(String plantaId, String espacoId) async {
    try {
      // Verificar se o espaço existe e está ativo
      final espaco = await _espacoRepository.findById(espacoId);
      if (espaco == null || !espaco.ativo) return false;

      // Verificar se a planta existe
      final planta = await _plantaRepository.findById(plantaId);
      if (planta == null) return false;

      // Verificar se já não está no mesmo espaço
      if (planta.espacoId == espacoId) return false;

      // Verificar se já existe planta com mesmo nome no espaço destino
      if (planta.nome != null) {
        final jaExiste = await existePlantaComNome(planta.nome!, espacoId, excluirId: plantaId);
        if (jaExiste) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

}
