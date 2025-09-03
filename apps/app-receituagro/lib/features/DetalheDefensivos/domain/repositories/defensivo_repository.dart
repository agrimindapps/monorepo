import '../../../../core/utils/typedef.dart';
import '../entities/defensivo_entity.dart';

/// Contrato do repositório de defensivos
/// 
/// Define as operações disponíveis para defensivos,
/// seguindo os princípios de Clean Architecture
abstract class DefensivoRepository {
  /// Busca um defensivo pelo ID de registro
  ResultFuture<DefensivoEntity> getDefensivoById(String idReg);
  
  /// Busca um defensivo pelo nome
  ResultFuture<DefensivoEntity> getDefensivoByName(String nome);
  
  /// Busca defensivos por fabricante
  ResultFuture<List<DefensivoEntity>> getDefensivosByFabricante(String fabricante);
  
  /// Busca defensivos por ingrediente ativo
  ResultFuture<List<DefensivoEntity>> getDefensivosByIngredienteAtivo(String ingredienteAtivo);
  
  /// Lista todos os defensivos com filtros opcionais
  ResultFuture<List<DefensivoEntity>> getDefensivos({
    String? fabricante,
    String? classeAgronomica,
    String? ingredienteAtivo,
    int? limit,
    int? offset,
  });
  
  /// Busca defensivos por query de texto
  ResultFuture<List<DefensivoEntity>> searchDefensivos(String query);
  
  /// Stream de defensivos em tempo real
  Stream<List<DefensivoEntity>> watchDefensivos();
}