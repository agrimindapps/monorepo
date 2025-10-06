import '../entities/comentario_entity.dart';
import '../repositories/i_comentarios_repository.dart';

/// **USE CASE: Retrieve Comments**
/// 
/// Handles retrieval, sorting, filtering, and searching of comments with business logic applied.
/// Implements agricultural domain-specific rules for comment organization and relevance.
/// 
/// ## Business Rules Implemented:
/// 
/// ### Sorting Rules:
/// - **Primary Sort**: Active comments (status=true) appear before inactive comments
/// - **Secondary Sort**: Newer comments appear before older comments (createdAt desc)
/// - **Consistency**: Same sorting logic applied across all retrieval methods
/// 
/// ### Search Relevance Rules:
/// - **Title Match**: Highest relevance score (10 points + 5 bonus for starts-with)
/// - **Content Match**: Medium relevance score (5 points + 3 bonus for starts-with) 
/// - **Tool Match**: Lower relevance score (3 points)
/// - **Recency Boost**: Recent comments get relevance boost (2 points ≤7 days, 1 point ≤30 days)
/// - **Status Boost**: Active comments get small relevance boost (1 point)
/// 
/// ### Filtering Rules:
/// - **Context Filtering**: Comments linked to specific agricultural content (pkIdentificador)
/// - **Tool Filtering**: Comments grouped by agricultural tool/feature (ferramenta)
/// - **Status Aware**: Inactive comments included but deprioritized in sorting
/// 
/// ## Agricultural Domain Context:
/// 
/// Comments are organized by agricultural context:
/// - **By Context**: All comments for specific pest, disease, or defensive product
/// - **By Tool**: All comments from specific app feature (pragas, defensivos, diagnosticos)
/// - **Global View**: All user comments across all agricultural content
/// 
/// ## Performance Considerations:
/// 
/// - Sorting performed in memory after database retrieval
/// - Search relevance calculated on-demand for flexibility
/// - Repository layer handles database-specific optimizations
/// - Consistent sorting prevents UI flickering and confusion
class GetComentariosUseCase {
  final IComentariosRepository _repository;

  GetComentariosUseCase(this._repository);

  /// Gets all comentarios sorted by newest first
  Future<List<ComentarioEntity>> call() async {
    final comentarios = await _repository.getAllComentarios();
    comentarios.sort((a, b) {
      if (a.status != b.status) {
        return a.status ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return comentarios;
  }

  /// Gets comentarios filtered by context
  Future<List<ComentarioEntity>> getByContext(String pkIdentificador) async {
    final comentarios = await _repository.getComentariosByContext(pkIdentificador);
    comentarios.sort((a, b) {
      if (a.status != b.status) {
        return a.status ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return comentarios;
  }

  /// Gets comentarios filtered by tool/feature
  Future<List<ComentarioEntity>> getByTool(String ferramenta) async {
    final comentarios = await _repository.getComentariosByTool(ferramenta);
    comentarios.sort((a, b) {
      if (a.status != b.status) {
        return a.status ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return comentarios;
  }

  /// Searches comentarios with relevance scoring
  Future<List<ComentarioEntity>> search(String query) async {
    if (query.trim().isEmpty) {
      return await call();
    }

    final comentarios = await _repository.searchComentarios(query);
    final queryLower = query.toLowerCase();
    comentarios.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, queryLower);
      final scoreB = _calculateRelevanceScore(b, queryLower);
      
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA); // Higher score first
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return comentarios;
  }

  /// Calculate relevance score for search results
  int _calculateRelevanceScore(ComentarioEntity comentario, String query) {
    int score = 0;
    
    final content = comentario.conteudo.toLowerCase();
    final title = comentario.titulo.toLowerCase();
    final tool = comentario.ferramenta.toLowerCase();
    if (title.contains(query)) score += 10;
    if (title.startsWith(query)) score += 5;
    if (content.contains(query)) score += 5;
    if (content.startsWith(query)) score += 3;
    if (tool.contains(query)) score += 3;
    final daysSince = DateTime.now().difference(comentario.createdAt).inDays;
    if (daysSince <= 7) {
      score += 2;
    } else if (daysSince <= 30) score += 1;
    if (comentario.status) score += 1;
    
    return score;
  }
}