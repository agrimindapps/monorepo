// Dart imports:
import 'dart:math';
import 'dart:typed_data';

/// Serviço para geração segura de IDs únicos
/// Implementa diferentes estratégias de geração usando padrão Strategy
class IDGenerationService {
  static final IDGenerationService _instance = IDGenerationService._internal();
  factory IDGenerationService() => _instance;
  IDGenerationService._internal();

  final Map<String, Set<String>> _generatedIds = {};
  final Map<String, int> _rateLimits = {};
  static const int _maxIdsPerSecond = 100;

  /// Gerar ID usando UUID v4 criptograficamente seguro
  String generateSecureId({String prefix = '', IDType type = IDType.uuid}) {
    final strategy = _getStrategy(type);
    final id = strategy.generate(prefix);
    
    // Verificar unicidade
    if (!_isUnique(id, type.name)) {
      // Se não for único, tentar novamente (recursivo com limite)
      return _generateWithRetry(prefix: prefix, type: type, attempts: 3);
    }

    // Rate limiting
    if (!_checkRateLimit(type.name)) {
      throw IDGenerationException('Rate limit exceeded for ${type.name}');
    }

    // Registrar ID gerado
    _registerGeneratedId(id, type.name);

    // Log de segurança (apenas em debug)
    _logSecurityEvent('ID_GENERATED', {'type': type.name, 'prefix': prefix});

    return id;
  }

  /// Gerar ID com retry em caso de colisão
  String _generateWithRetry({
    String prefix = '', 
    IDType type = IDType.uuid, 
    int attempts = 3
  }) {
    if (attempts <= 0) {
      throw const IDGenerationException('Failed to generate unique ID after multiple attempts');
    }

    final strategy = _getStrategy(type);
    final id = strategy.generate(prefix);
    
    if (_isUnique(id, type.name)) {
      _registerGeneratedId(id, type.name);
      return id;
    }
    
    return _generateWithRetry(prefix: prefix, type: type, attempts: attempts - 1);
  }

  /// Verificar se ID é único
  bool _isUnique(String id, String category) {
    return !_generatedIds.containsKey(category) || 
           !_generatedIds[category]!.contains(id);
  }

  /// Registrar ID gerado para tracking de unicidade
  void _registerGeneratedId(String id, String category) {
    _generatedIds.putIfAbsent(category, () => <String>{}).add(id);
    
    // Limpar cache se ficar muito grande (manter apenas os últimos 10000)
    if (_generatedIds[category]!.length > 10000) {
      final list = _generatedIds[category]!.toList();
      _generatedIds[category] = list.skip(5000).toSet();
    }
  }

  /// Verificar rate limiting
  bool _checkRateLimit(String category) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Segundos
    final key = '${category}_$now';
    
    _rateLimits[key] = (_rateLimits[key] ?? 0) + 1;
    
    // Limpar rate limits antigos
    _rateLimits.removeWhere((k, v) => k != key && 
        int.parse(k.split('_').last) < now - 60); // 1 minuto
    
    return _rateLimits[key]! <= _maxIdsPerSecond;
  }

  /// Obter estratégia de geração baseada no tipo
  IDGenerationStrategy _getStrategy(IDType type) {
    switch (type) {
      case IDType.uuid:
        return UUIDGenerationStrategy();
      case IDType.secure:
        return SecureHashGenerationStrategy();
      case IDType.timestamp:
        return TimestampGenerationStrategy();
      case IDType.nanoid:
        return NanoIDGenerationStrategy();
    }
  }

  /// Log de eventos de segurança (apenas debug)
  void _logSecurityEvent(String event, Map<String, dynamic> details) {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (isDebug) {
      print('IDGenerationService: $event - $details');
    }
  }

  /// Validar se um ID tem formato válido
  bool validateId(String id, IDType expectedType) {
    final strategy = _getStrategy(expectedType);
    return strategy.validate(id);
  }

  /// Limpar cache (para testes ou limpeza de memória)
  void clearCache([String? category]) {
    if (category != null) {
      _generatedIds.remove(category);
      _rateLimits.removeWhere((k, v) => k.startsWith(category));
    } else {
      _generatedIds.clear();
      _rateLimits.clear();
    }
  }

  /// Obter estatísticas de geração
  Map<String, dynamic> getStats() {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (!isDebug) {
      return {'message': 'Stats only available in debug mode'};
    }

    return {
      'total_categories': _generatedIds.length,
      'ids_per_category': _generatedIds.map((k, v) => MapEntry(k, v.length)),
      'rate_limits': _rateLimits,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Tipos de ID disponíveis
enum IDType {
  uuid,      // UUID v4 padrão
  secure,    // Hash SHA-256 de dados aleatórios
  timestamp, // Timestamp + random (para compatibility)
  nanoid,    // NanoID formato compacto
}

/// Estratégia abstrata para geração de IDs
abstract class IDGenerationStrategy {
  String generate(String prefix);
  bool validate(String id);
}

/// Estratégia UUID v4
class UUIDGenerationStrategy implements IDGenerationStrategy {
  final Random _random = Random.secure();

  @override
  String generate(String prefix) {
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final uuid = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
    
    return prefix.isEmpty ? uuid : '${prefix}_$uuid';
  }

  @override
  bool validate(String id) {
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$'
    );
    
    if (id.contains('_')) {
      return uuidPattern.hasMatch(id.split('_').last);
    }
    return uuidPattern.hasMatch(id);
  }
}

/// Estratégia usando Hash simples sem dependências
class SecureHashGenerationStrategy implements IDGenerationStrategy {
  final Random _random = Random.secure();

  @override
  String generate(String prefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomBytes = List.generate(16, (_) => _random.nextInt(256));
    
    // Implementação simples de hash sem crypto package
    var hash = timestamp;
    for (final byte in randomBytes) {
      hash = ((hash << 5) - hash + byte) & 0xFFFFFFFF;
    }
    hash = hash ^ (_random.nextInt(0xFFFFFFFF));
    
    final hashString = hash.abs().toRadixString(16).padLeft(8, '0');
    final additionalRandom = _random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    final finalHash = (hashString + additionalRandom).substring(0, 16);
    
    return prefix.isEmpty ? finalHash : '${prefix}_$finalHash';
  }

  @override
  bool validate(String id) {
    final hashPattern = RegExp(r'^[a-f0-9]{16}$');
    
    if (id.contains('_')) {
      return hashPattern.hasMatch(id.split('_').last);
    }
    return hashPattern.hasMatch(id);
  }
}

/// Estratégia Timestamp (para compatibilidade, mas mais segura)
class TimestampGenerationStrategy implements IDGenerationStrategy {
  final Random _random = Random.secure();

  @override
  String generate(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(999999).toString().padLeft(6, '0');
    final id = '${timestamp}_$randomSuffix';
    
    return prefix.isEmpty ? id : '${prefix}_$id';
  }

  @override
  bool validate(String id) {
    final timestampPattern = RegExp(r'^\d{13}_\d{6}$');
    
    if (id.contains('_') && !id.endsWith('_')) {
      final parts = id.split('_');
      if (parts.length >= 2) {
        final suffix = parts.sublist(parts.length - 2).join('_');
        return timestampPattern.hasMatch(suffix);
      }
    }
    return timestampPattern.hasMatch(id);
  }
}

/// Estratégia NanoID (formato compacto)
class NanoIDGenerationStrategy implements IDGenerationStrategy {
  final Random _random = Random.secure();
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  @override
  String generate(String prefix) {
    const length = 12;
    final result = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      result.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    
    final nanoid = result.toString();
    return prefix.isEmpty ? nanoid : '${prefix}_$nanoid';
  }

  @override
  bool validate(String id) {
    final nanoidPattern = RegExp(r'^[A-Za-z0-9]{12}$');
    
    if (id.contains('_')) {
      return nanoidPattern.hasMatch(id.split('_').last);
    }
    return nanoidPattern.hasMatch(id);
  }
}

/// Exception para erros de geração de ID
class IDGenerationException implements Exception {
  final String message;
  const IDGenerationException(this.message);

  @override
  String toString() => 'IDGenerationException: $message';
}

/// Helper functions para facilitar uso
extension IDGenerationServiceExtension on IDGenerationService {
  /// Gerar ID para Task
  String generateTaskId() => generateSecureId(prefix: 'task', type: IDType.uuid);
  
  /// Gerar ID para User
  String generateUserId() => generateSecureId(prefix: 'user', type: IDType.secure);
  
  /// Gerar ID para TaskList
  String generateTaskListId() => generateSecureId(prefix: 'list', type: IDType.nanoid);
}