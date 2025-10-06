import '../../../../core/utils/typedef.dart';
import '../../../comentarios/domain/entities/comentario_entity.dart';

/// Contrato do repositório de comentários
/// 
/// Define as operações disponíveis para comentários,
/// seguindo os princípios de Clean Architecture
abstract class ComentarioRepository {
  /// Busca comentários por identificador do item (defensivo, etc)
  ResultFuture<List<ComentarioEntity>> getComentariosByPkIdentificador(String pkIdentificador);
  
  /// Busca comentários por ferramenta
  ResultFuture<List<ComentarioEntity>> getComentariosByFerramenta(String ferramenta);
  
  /// Busca um comentário específico por ID
  ResultFuture<ComentarioEntity> getComentarioById(String id);
  
  /// Adiciona um novo comentário
  ResultFuture<String> addComentario(ComentarioEntity comentario);
  
  /// Atualiza um comentário existente
  ResultFuture<void> updateComentario(ComentarioEntity comentario);
  
  /// Deleta um comentário
  ResultFuture<void> deleteComentario(String id);
  
  /// Lista todos os comentários ativos
  ResultFuture<List<ComentarioEntity>> getComentariosAtivos();
  
  /// Stream de comentários em tempo real
  Stream<List<ComentarioEntity>> watchComentarios(String pkIdentificador);
  
  /// Conta o número de comentários de um item
  ResultFuture<int> countComentarios(String pkIdentificador);
}
