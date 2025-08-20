// Package imports:
import 'package:uuid/uuid.dart';

/// Service centralizado para geração segura de IDs
class IdService {
  static final IdService _instance = IdService._internal();
  factory IdService() => _instance;
  IdService._internal();

  final _uuid = const Uuid();
  final Set<String> _usedObjectIds = <String>{};

  /// Gera um objectId seguro e único baseado em UUID
  String generateSecureObjectId() {
    String objectId;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      // Gera UUID v4 como base
      final uuid = _uuid.v4();

      // Adiciona timestamp para unicidade temporal
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Combina UUID com timestamp e pega substring determinística
      final combined = '$uuid-$timestamp';

      // Gera objectId baseado no hash simples da string
      objectId = _generateHashFromString(combined);

      attempts++;

      if (attempts >= maxAttempts) {
        throw Exception(
            'Falha ao gerar objectId único após $maxAttempts tentativas');
      }
    } while (_usedObjectIds.contains(objectId));

    _usedObjectIds.add(objectId);
    return objectId;
  }

  /// Gera hash simples a partir de uma string
  String _generateHashFromString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & hash; // Converte para 32bit
    }

    // Converte para hexadecimal e pega 16 caracteres
    final hexHash = hash.abs().toRadixString(16).padLeft(8, '0');
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(8, '0');

    return (hexHash + timestamp).substring(0, 16);
  }

  /// Gera um ID único padrão (UUID v4)
  String generateUniqueId() {
    return _uuid.v4();
  }

  /// Valida formato de objectId
  bool isValidObjectId(String objectId) {
    if (objectId.isEmpty) return false;

    // ObjectId deve ter 16 caracteres hexadecimais
    final hexRegex = RegExp(r'^[a-f0-9]{16}$');
    return hexRegex.hasMatch(objectId);
  }

  /// Valida formato de ID UUID
  bool isValidUuid(String id) {
    if (id.isEmpty) return false;

    // UUID v4 pattern
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  /// Registra um objectId como usado (para evitar duplicações)
  void registerUsedObjectId(String objectId) {
    _usedObjectIds.add(objectId);
  }

  /// Limpa cache de IDs usados (para testes ou reset)
  void clearUsedIds() {
    _usedObjectIds.clear();
  }

  /// Retorna estatísticas de uso
  Map<String, dynamic> getUsageStats() {
    return {
      'usedObjectIds': _usedObjectIds.length,
      'lastCleared': DateTime.now().toIso8601String(),
    };
  }
}
