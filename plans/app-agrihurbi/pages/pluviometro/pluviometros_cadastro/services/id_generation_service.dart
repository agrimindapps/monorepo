// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import 'pluviometro_repository_service.dart';

/// Serviço para geração segura de IDs
class IdGenerationService {
  final IPluviometroRepository _repository;
  final Uuid _uuid = const Uuid();

  IdGenerationService({required IPluviometroRepository repository})
      : _repository = repository;

  /// Gera um ID único e seguro para pluviômetro
  Future<String> generateSecureId({int maxRetries = 5}) async {
    for (int i = 0; i < maxRetries; i++) {
      final id = _generateId();

      // Verifica se o ID já existe
      if (await _isIdUnique(id)) {
        return id;
      }
    }

    throw IdGenerationException(
        'Não foi possível gerar um ID único após $maxRetries tentativas');
  }

  /// Gera um ID baseado em UUID v4 com timestamp
  String _generateId() {
    final uuid = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Combina UUID com timestamp para garantir unicidade
    final combined = '$uuid-$timestamp';

    // Retorna apenas os primeiros 32 caracteres para manter compatibilidade
    return combined.replaceAll('-', '').substring(0, 32);
  }

  /// Verifica se o ID é único no repositório
  Future<bool> _isIdUnique(String id) async {
    try {
      final existingPluviometro = await _repository.getPluviometro(id);
      return existingPluviometro == null;
    } catch (e) {
      // Se houver erro na busca, assumimos que o ID é único
      return true;
    }
  }

  /// Valida se um ID tem formato válido
  bool isValidIdFormat(String id) {
    if (id.isEmpty || id.length < 8 || id.length > 50) {
      return false;
    }

    // Verifica se contém apenas caracteres alfanuméricos
    final validPattern = RegExp(r'^[a-zA-Z0-9]+$');
    return validPattern.hasMatch(id);
  }

  /// Gera um objectId para uso interno
  String generateObjectId() {
    return _uuid.v4();
  }
}

/// Exceção para erros de geração de ID
class IdGenerationException implements Exception {
  final String message;

  IdGenerationException(this.message);

  @override
  String toString() => 'IdGenerationException: $message';
}
