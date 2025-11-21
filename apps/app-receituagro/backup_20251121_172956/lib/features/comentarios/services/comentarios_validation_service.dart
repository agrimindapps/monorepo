import 'package:injectable/injectable.dart';

/// Service specialized in validating comentario content
/// Principle: Single Responsibility - Only handles validation logic
@lazySingleton
class ComentariosValidationService {
  // Validation constants
  static const int minContentLength = 3;
  static const int maxContentLength = 5000;
  static const int minTitleLength = 0;
  static const int maxTitleLength = 200;

  /// Validates comentario content
  bool isValidContent(String content) {
    final trimmed = content.trim();
    return trimmed.length >= minContentLength &&
        trimmed.length <= maxContentLength;
  }

  /// Validates comentario title
  bool isValidTitle(String title) {
    final trimmed = title.trim();
    return trimmed.length >= minTitleLength && trimmed.length <= maxTitleLength;
  }

  /// Gets validation error message for content
  String getContentValidationError(String content) {
    final trimmed = content.trim();

    if (trimmed.isEmpty) {
      return 'O conteúdo não pode estar vazio';
    }

    if (trimmed.length < minContentLength) {
      return 'O conteúdo deve ter pelo menos $minContentLength caracteres';
    }

    if (trimmed.length > maxContentLength) {
      return 'O conteúdo não pode exceder $maxContentLength caracteres';
    }

    return 'Conteúdo inválido';
  }

  /// Gets validation error message for title
  String getTitleValidationError(String title) {
    final trimmed = title.trim();

    if (trimmed.length > maxTitleLength) {
      return 'O título não pode exceder $maxTitleLength caracteres';
    }

    return 'Título inválido';
  }

  /// Validates if user can add more comentarios based on limit
  bool canAddComentario(int currentCount, int maxAllowed) {
    return currentCount < maxAllowed;
  }

  /// Gets error message when comment limit is reached
  String getLimitReachedMessage(int maxAllowed) {
    return 'Você atingiu o limite de $maxAllowed comentários. Exclua alguns comentários para adicionar novos.';
  }

  /// Checks if content has been modified
  bool hasContentChanged(String original, String modified) {
    return original.trim() != modified.trim();
  }
}
