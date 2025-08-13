// Project imports:
import '../../database/espaco_model.dart';

/// Interface para EspacoRepository
///
/// Define contrato para operações de dados de espaços,
/// permitindo dependency injection e testabilidade
abstract class IEspacoRepository {
  /// Inicializar o repository
  Future<void> initialize();

  /// Buscar todos os espaços
  Future<List<EspacoModel>> findAll();

  /// Buscar espaço por ID
  Future<EspacoModel?> findById(String id);

  /// Buscar múltiplos espaços por IDs
  Future<List<EspacoModel>> findByIds(List<String> ids);

  /// Criar novo espaço
  Future<String> criar(EspacoModel espaco);

  /// Atualizar espaço existente
  Future<void> atualizar(EspacoModel espaco);

  /// Remover espaço
  Future<void> remover(String id);

  /// Stream de todos os espaços
  Stream<List<EspacoModel>> get dataStream;

  /// Stream de espaços ativos
  Stream<List<EspacoModel>> watchAtivos();

  /// Stream de espaços inativos
  Stream<List<EspacoModel>> watchInativos();

  /// Verificar se existe espaço com nome (case insensitive)
  Future<bool> existeComNome(String nome, {String? excludeId});

  /// Ativar espaço
  Future<void> ativar(String id);

  /// Desativar espaço
  Future<void> desativar(String id);

  /// Definir status ativo/inativo
  Future<void> setAtivo(String id, bool ativo);

  /// Duplicar espaço
  Future<String> duplicar(String id);

  /// Dispose resources
  void dispose();
}
