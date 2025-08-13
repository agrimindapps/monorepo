// Project imports:
import '../../domain/entities/defensivo_entity.dart';

/// Mapper específico da camada de infraestrutura
/// 
/// Responsável por converter dados da camada de infraestrutura (Map<String, dynamic>)
/// para entities do domínio
class DefensivosInfrastructureMapper {
  /// Converte Map da infraestrutura para DefensivoEntity
  DefensivoEntity mapToEntity(Map<String, dynamic> map) {
    return DefensivoEntity(
      id: _getString(map, 'id'),
      nomeComercial: _getString(map, 'nomeComercial', 
          fallbacks: ['nome_comercial', 'nome']),
      fabricante: _getString(map, 'fabricante'),
      classeAgronomica: _getString(map, 'classeAgronomica', 
          fallbacks: ['classe_agronomica', 'classe']),
      ingredienteAtivo: _getString(map, 'ingredienteAtivo', 
          fallbacks: ['ingrediente_ativo', 'ingrediente']),
      modoDeAcao: _getString(map, 'modoDeAcao', 
          fallbacks: ['modo_de_acao', 'modo']),
      isNew: _getBool(map, 'isNew', fallbacks: ['novo', 'is_new']),
      lastAccessed: _getDateTime(map, 'lastAccessed', 
          fallbacks: ['last_accessed', 'ultimo_acesso']),
    );
  }

  /// Converte DefensivoEntity para Map da infraestrutura
  Map<String, dynamic> entityToMap(DefensivoEntity entity) {
    return {
      'id': entity.id,
      'nomeComercial': entity.nomeComercial,
      'fabricante': entity.fabricante,
      'classeAgronomica': entity.classeAgronomica,
      'ingredienteAtivo': entity.ingredienteAtivo,
      'modoDeAcao': entity.modoDeAcao,
      'isNew': entity.isNew,
      'lastAccessed': entity.lastAccessed?.toIso8601String(),
    };
  }

  /// Helper para extrair string com fallbacks
  String _getString(Map<String, dynamic> map, String key, {List<String>? fallbacks}) {
    // Tenta a chave principal primeiro
    var value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }

    // Tenta fallbacks
    if (fallbacks != null) {
      for (final fallback in fallbacks) {
        value = map[fallback]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return '';
  }

  /// Helper para extrair bool com fallbacks
  bool _getBool(Map<String, dynamic> map, String key, {List<String>? fallbacks}) {
    // Tenta a chave principal primeiro
    var value = map[key];
    if (value != null) {
      return _parseBool(value);
    }

    // Tenta fallbacks
    if (fallbacks != null) {
      for (final fallback in fallbacks) {
        value = map[fallback];
        if (value != null) {
          return _parseBool(value);
        }
      }
    }

    return false;
  }

  /// Helper para extrair DateTime com fallbacks
  DateTime? _getDateTime(Map<String, dynamic> map, String key, {List<String>? fallbacks}) {
    // Tenta a chave principal primeiro
    var value = map[key];
    if (value != null) {
      return _parseDateTime(value);
    }

    // Tenta fallbacks
    if (fallbacks != null) {
      for (final fallback in fallbacks) {
        value = map[fallback];
        if (value != null) {
          return _parseDateTime(value);
        }
      }
    }

    return null;
  }

  /// Parse bool de diferentes formatos
  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'sim';
    }
    if (value is num) return value != 0;
    return false;
  }

  /// Parse DateTime de diferentes formatos
  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        // Tenta outros formatos comuns
        try {
          return DateTime.tryParse(value);
        } catch (_) {
          return null;
        }
      }
    }
    if (value is num) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}