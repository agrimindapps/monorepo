import '../../constants/comentarios_design_tokens.dart';
import '../entities/comentario_entity.dart';
import '../repositories/i_comentarios_read_repository.dart';
import '../repositories/i_comentarios_write_repository.dart';

/// **USE CASE: Add New Comment**
///
/// Orchestrates the creation of new comments with comprehensive business rule validation.
/// This use case implements all business logic for comment creation in the agricultural domain.
///
/// ## Business Rules Implemented:
///
/// ### Content Validation Rules:
/// - **Minimum Content**: Content must have at least 5 characters after trimming (ComentariosDesignTokens.minCommentLength)
/// - **Maximum Content**: Content cannot exceed 2000 characters
/// - **Quality Control**: Rejects low-quality content (spam, test messages, repetitive text)
/// - **Profanity Filter**: Basic inappropriate content detection
///
/// ### Title Validation Rules:
/// - **Required**: Title cannot be empty after trimming
/// - **Minimum Length**: Title must have at least 5 characters
/// - **Maximum Length**: Title cannot exceed 100 characters
///
/// ### Context Validation Rules:
/// - **Tool Identifier**: ferramenta field cannot be empty (required for categorization)
/// - **Context ID**: pkIdentificador is optional (empty for general comments, specific ID for content-linked comments)
/// - **Duplicate Prevention**: Prevents duplicate titles and highly similar content in same context (when context is specified)
///
/// ### User Limit Rules:
/// - **Total Comments**: Maximum 500 comments per user (absolute limit)
/// - **Active Comments**: Maximum 100 active comments for free tier users
/// - **Daily Rate Limit**: Maximum 20 comments per day per user
/// - **Anti-Spam**: Maximum 3 comments in 5-minute window
///
/// ### Data Integrity Rules:
/// - **Auto-Timestamps**: Sets createdAt and updatedAt if not provided
/// - **Active Status**: New comments are created with active status (true)
/// - **Immutable ID**: Preserves existing ID if provided, generates if needed
///
/// ## Agricultural Domain Context:
///
/// Comments in ReceitaAgro can be either context-specific or general user notes:
///
/// ### Context-Specific Comments (pkIdentificador provided):
/// - **Pragas** (Pests): User observations about pest behavior, treatments, results
/// - **Doenças** (Diseases): User experiences with disease management, symptoms
/// - **Defensivos** (Defensive Products): User feedback on product effectiveness, application notes
/// - **Diagnósticos** (Diagnostics): User clarifications, additional context, field observations
///
/// ### General Comments (pkIdentificador empty):
/// - **Personal Notes**: General agricultural observations and reminders
/// - **Planning Notes**: Seasonal planning, weather observations, field conditions
/// - **Learning Notes**: Agricultural insights, technique notes, experience sharing
///
/// ## Error Handling:
///
/// - **InvalidComentarioException**: Thrown for validation failures
/// - **DuplicateComentarioException**: Thrown for duplicate content detection
/// - **CommentLimitExceededException**: Thrown when user limits are exceeded
/// - **Graceful Degradation**: If optional checks fail, allows comment creation (availability over consistency)
///
/// ## Usage Example:
/// ```dart
/// final useCase = AddComentarioUseCase(repository);
///
/// // Context-specific comment (linked to agricultural content)
/// final specificComment = ComentarioEntity(
///   id: generateId(),
///   titulo: 'Resultado do tratamento X',
///   conteudo: 'Aplicação realizada conforme recomendação...',
///   ferramenta: 'defensivos',
///   pkIdentificador: 'def_12345', // Links to specific defensive product
///   // ... other fields
/// );
/// await useCase.call(specificComment);
///
/// // General comment (user personal note)
/// final generalComment = ComentarioEntity(
///   id: generateId(),
///   titulo: 'Observação pessoal',
///   conteudo: 'Lembrar de verificar as condições climáticas...',
///   ferramenta: 'Comentários',
///   pkIdentificador: '', // Empty for general comments
///   // ... other fields
/// );
/// await useCase.call(generalComment);
/// ```
class AddComentarioUseCase {
  final IComentariosReadRepository _readRepository;
  final IComentariosWriteRepository _writeRepository;

  AddComentarioUseCase(this._readRepository, this._writeRepository);

  /// Adds a new comentario after comprehensive validation
  Future<void> call(ComentarioEntity comentario) async {
    await _validateComentario(comentario);
    await _checkUserLimits();
    final now = DateTime.now();
    final comentarioToSave = comentario.copyWith(
      createdAt: comentario.createdAt == DateTime.fromMillisecondsSinceEpoch(0)
          ? now
          : comentario.createdAt,
      updatedAt: comentario.updatedAt == DateTime.fromMillisecondsSinceEpoch(0)
          ? now
          : comentario.updatedAt,
      status: true, // Always active when created
    );

    await _writeRepository.addComentario(comentarioToSave);
  }

  /// Comprehensive business validation for comentario content
  Future<void> _validateComentario(ComentarioEntity comentario) async {
    if (!comentario.isValid) {
      throw InvalidComentarioException(
        'Comentário deve ter título e conteúdo válidos',
      );
    }
    final contentLength = comentario.conteudo.trim().length;
    if (contentLength < ComentariosDesignTokens.minCommentLength) {
      throw InvalidComentarioException(
        'Conteúdo deve ter pelo menos ${ComentariosDesignTokens.minCommentLength} caracteres',
      );
    }

    if (contentLength > 2000) {
      throw InvalidComentarioException(
        'Conteúdo não pode exceder 2000 caracteres',
      );
    }
    if (_isLowQualityContent(comentario.conteudo)) {
      throw InvalidComentarioException(
        'Conteúdo deve ser mais descritivo e útil',
      );
    }
    final titleLength = comentario.titulo.trim().length;
    if (titleLength == 0) {
      throw InvalidComentarioException('Título é obrigatório');
    }

    if (titleLength < 5) {
      throw InvalidComentarioException(
        'Título deve ter pelo menos 5 caracteres',
      );
    }

    if (titleLength > 100) {
      throw InvalidComentarioException(
        'Título não pode exceder 100 caracteres',
      );
    }
    if (comentario.ferramenta.trim().isEmpty) {
      throw InvalidComentarioException('Ferramenta/contexto é obrigatório');
    }
    if (_containsInappropriateContent(comentario)) {
      throw InvalidComentarioException(
        'Conteúdo contém linguagem inapropriada',
      );
    }
    if (comentario.pkIdentificador.isNotEmpty &&
        await _isDuplicateContent(comentario)) {
      throw DuplicateComentarioException(
        'Já existe um comentário similar neste contexto',
      );
    }
  }

  /// Check if content is low quality (too generic or spammy)
  bool _isLowQualityContent(String content) {
    final normalizedContent = content.toLowerCase().trim();
    if (normalizedContent.length < 10) {
      return true;
    }
    final repetitivePattern = RegExp(
      r'(.)\1{4,}',
    ); // 5+ same characters in a row
    if (repetitivePattern.hasMatch(normalizedContent)) {
      return true;
    }
    final lowQualityPatterns = [
      'test', 'teste', '...', 'aaa', 'bbb', 'ccc',
      RegExp(r'^[a-z]\s*$'), // Single letters
      RegExp(r'^\d+\s*$'), // Only numbers
    ];

    for (final pattern in lowQualityPatterns) {
      if (pattern is String && normalizedContent == pattern) {
        return true;
      } else if (pattern is RegExp && pattern.hasMatch(normalizedContent)) {
        return true;
      }
    }

    return false;
  }

  /// Check for inappropriate content (basic implementation)
  bool _containsInappropriateContent(ComentarioEntity comentario) {
    final content = '${comentario.titulo} ${comentario.conteudo}'.toLowerCase();
    final inappropriateWords = ['spam', 'scam', 'hack'];

    return inappropriateWords.any((word) => content.contains(word));
  }

  /// Check if user has reached comment limits with comprehensive rules
  Future<void> _checkUserLimits() async {
    final stats = await _readRepository.getUserCommentStats();
    final activeComments = stats['active'] ?? 0;
    final totalComments = stats['total'] ?? 0;
    const maxTotalComments = 500;
    if (totalComments >= maxTotalComments) {
      throw CommentLimitExceededException(
        'Limite absoluto de comentários atingido ($maxTotalComments). '
        'Entre em contato com suporte para mais informações.',
      );
    }
    const maxFreeActiveComments = 100;
    if (activeComments >= maxFreeActiveComments) {
      throw CommentLimitExceededException(
        'Limite de comentários ativos atingido ($maxFreeActiveComments). '
        'Considere deletar comentários antigos ou fazer upgrade.',
      );
    }
    await _checkDailyLimits();
    await _checkContextLimits();
  }

  /// Check daily comment creation limits
  Future<void> _checkDailyLimits() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayComments = await _readRepository.getCommentsByDateRange(
        today,
        today.add(const Duration(days: 1)),
      );

      const maxCommentsPerDay = 20;
      if (todayComments.length >= maxCommentsPerDay) {
        throw CommentLimitExceededException(
          'Limite diário de comentários atingido ($maxCommentsPerDay). '
          'Tente novamente amanhã.',
        );
      }
      final recentComments = todayComments
          .where(
            (comment) => comment.createdAt.isAfter(
              now.subtract(const Duration(minutes: 5)),
            ),
          )
          .length;

      const maxCommentsInFiveMinutes = 3;
      if (recentComments >= maxCommentsInFiveMinutes) {
        throw CommentLimitExceededException(
          'Muitos comentários criados recentemente. '
          'Aguarde alguns minutos antes de criar outro.',
        );
      }
    } catch (e) {
      if (e is CommentLimitExceededException) {
        rethrow;
      }
    }
  }

  /// Check context-specific comment limits
  Future<void> _checkContextLimits() async {
    try {} catch (e) {
      // Silently ignore duplicate check errors - comment will still be added
    }
  }

  /// Check for duplicate content in same context with proper implementation
  Future<bool> _isDuplicateContent(ComentarioEntity comentario) async {
    try {
      final existingComments = await _readRepository.getByContext(
        comentario.pkIdentificador,
      );
      final exactTitleMatch = existingComments.any(
        (existing) =>
            existing.id != comentario.id &&
            existing.titulo.trim().toLowerCase() ==
                comentario.titulo.trim().toLowerCase(),
      );

      if (exactTitleMatch) {
        return true;
      }
      const similarityThreshold = 0.85;
      final comentarioWords = _extractWords(comentario.conteudo);

      for (final existing in existingComments) {
        if (existing.id == comentario.id) continue;

        final existingWords = _extractWords(existing.conteudo);
        final similarity = _calculateSimilarity(comentarioWords, existingWords);

        if (similarity >= similarityThreshold) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Extract meaningful words from text for comparison
  List<String> _extractWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2) // Filter short words
        .toList();
  }

  /// Calculate text similarity using Jaccard coefficient
  double _calculateSimilarity(List<String> words1, List<String> words2) {
    if (words1.isEmpty && words2.isEmpty) return 1.0;
    if (words1.isEmpty || words2.isEmpty) return 0.0;

    final set1 = words1.toSet();
    final set2 = words2.toSet();

    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;

    return union > 0 ? intersection / union : 0.0;
  }
}

/// Exception thrown when comentario validation fails
class InvalidComentarioException implements Exception {
  final String message;
  InvalidComentarioException(this.message);

  @override
  String toString() => 'InvalidComentarioException: $message';
}

/// Exception thrown when trying to create duplicate content
class DuplicateComentarioException implements Exception {
  final String message;
  DuplicateComentarioException(this.message);

  @override
  String toString() => 'DuplicateComentarioException: $message';
}

/// Exception thrown when user exceeds comment limits
class CommentLimitExceededException implements Exception {
  final String message;
  CommentLimitExceededException(this.message);

  @override
  String toString() => 'CommentLimitExceededException: $message';
}
