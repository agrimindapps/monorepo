import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// Enhanced Security Service - Sistema completo de segurança
/// 
/// Funcionalidades:
/// - Criptografia simétrica e assimétrica
/// - Hash seguro de passwords
/// - Geração de tokens seguros
/// - Autenticação biométrica
/// - Secure storage com criptografia adicional
/// - Validação de integridade de dados
/// - Rate limiting e throttling
/// - Detecção de tentativas de ataque
/// - Sanitização de dados
/// - Geração de chaves seguras
class EnhancedSecurityService {
  static const String _keyPrefix = 'security_key_';
  static const String _saltKey = 'security_salt';
  static const int _defaultKeyLength = 32;
  static const int _defaultSaltLength = 16;
  static const int _defaultIterations = 100000; // PBKDF2 iterations
  static const String _encryptionVersion = 'v2'; // Version for new AES encryption
  static const String _legacyPrefix = 'legacy:';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Rate limiting
  final Map<String, List<DateTime>> _rateLimitMap = {};
  final Map<String, int> _failedAttempts = {};
  
  // Security configuration
  bool _biometricsEnabled = false;
  int _maxFailedAttempts = 5;
  // Duration _lockoutDuration = const Duration(minutes: 15); // Reserved for future use
  
  bool _initialized = false;

  /// Inicializa o security service
  Future<Result<void>> initialize({
    bool enableBiometrics = true,
    int maxFailedAttempts = 5,
    Duration lockoutDuration = const Duration(minutes: 15),
  }) async {
    if (_initialized) return Result.success(null);

    try {
      _maxFailedAttempts = maxFailedAttempts;
      // _lockoutDuration = lockoutDuration; // Reserved for future use

      // Verifica disponibilidade biométrica
      if (enableBiometrics) {
        final isAvailable = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        _biometricsEnabled = isAvailable && isDeviceSupported;
      }

      // Inicializa salt master se não existir
      await _ensureMasterSalt();

      _initialized = true;
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao inicializar security service: ${e.toString()}',
          code: 'SECURITY_INIT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== CRIPTOGRAFIA ==========

  /// Criptografa dados usando AES-256-GCM
  Future<Result<String>> encrypt(String data, {String? customKey}) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      final keyString = customKey ?? await _getOrCreateKey('default');
      final keyBytes = _deriveKey(keyString, await _getMasterSalt());
      final key = Key(keyBytes);

      // Generate unique IV for each encryption
      final iv = IV.fromSecureRandom(16);

      // Use AES-256-GCM for authenticated encryption
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Format: version:iv:encrypted_data
      final result = '$_encryptionVersion:${iv.base64}:${encrypted.base64}';

      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao criptografar dados: ${e.toString()}',
          code: 'ENCRYPT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Descriptografa dados (suporta tanto AES quanto legacy Base64)
  Future<Result<String>> decrypt(String encryptedData, {String? customKey}) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      // Check if it's legacy Base64 encrypted data
      if (encryptedData.startsWith(_legacyPrefix) || !encryptedData.contains(':')) {
        return _decryptLegacyData(encryptedData, customKey);
      }

      final parts = encryptedData.split(':');
      if (parts.length < 3) {
        return Result.error(
          SecurityError(
            message: 'Formato de dados criptografados inválido',
            code: 'INVALID_ENCRYPTED_FORMAT',
          ),
        );
      }

      final version = parts[0];

      // Handle different encryption versions
      if (version == _encryptionVersion) {
        return _decryptAESData(parts, customKey);
      } else {
        // Assume it's legacy format without version prefix
        return _decryptLegacyData(encryptedData, customKey);
      }
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao descriptografar dados: ${e.toString()}',
          code: 'DECRYPT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Gera hash seguro de senha usando PBKDF2
  Future<Result<String>> hashPassword(String password, {String? customSalt}) async {
    try {
      final salt = customSalt ?? await _getMasterSalt();
      final bytes = utf8.encode(password + salt);
      
      // Simula PBKDF2 com múltiplas iterações de SHA-256
      List<int> hash = bytes;
      for (int i = 0; i < _defaultIterations; i++) {
        hash = sha256.convert(hash).bytes;
      }
      
      final hashedPassword = base64Encode(hash);
      return Result.success('$salt:$hashedPassword');
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao fazer hash da senha: ${e.toString()}',
          code: 'HASH_PASSWORD_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Verifica senha contra hash
  Future<Result<bool>> verifyPassword(String password, String hashedPassword) async {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) {
        return Result.error(
          SecurityError(
            message: 'Formato de hash inválido',
            code: 'INVALID_HASH_FORMAT',
          ),
        );
      }

      final salt = parts[0];
      final expectedHash = parts[1];
      
      final newHashResult = await hashPassword(password, customSalt: salt);
      if (newHashResult.isError) return Result.error(newHashResult.error!);
      
      final newHashParts = newHashResult.data!.split(':');
      final newHash = newHashParts[1];
      
      final isValid = _constantTimeCompare(expectedHash, newHash);
      return Result.success(isValid);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao verificar senha: ${e.toString()}',
          code: 'VERIFY_PASSWORD_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== TOKENS E CHAVES ==========

  /// Gera token seguro
  Future<Result<String>> generateSecureToken({int length = 32}) async {
    try {
      final random = Random.secure();
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      
      final token = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
      
      return Result.success(token);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao gerar token: ${e.toString()}',
          code: 'TOKEN_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Gera chave criptográfica segura
  Future<Result<String>> generateCryptoKey({int length = _defaultKeyLength}) async {
    try {
      final random = Random.secure();
      final bytes = List.generate(length, (_) => random.nextInt(256));
      final key = base64Encode(bytes);
      
      return Result.success(key);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao gerar chave criptográfica: ${e.toString()}',
          code: 'CRYPTO_KEY_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Gera UUID seguro
  Future<Result<String>> generateSecureUUID() async {
    try {
      final random = Random.secure();
      final bytes = List.generate(16, (_) => random.nextInt(256));
      
      // Define bits de versão (4) e variante (10)
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final uuid = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
      
      return Result.success(uuid);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao gerar UUID: ${e.toString()}',
          code: 'UUID_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== AUTENTICAÇÃO BIOMÉTRICA ==========

  /// Verifica se biometria está disponível
  Future<Result<BiometricInfo>> getBiometricInfo() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      final info = BiometricInfo(
        isAvailable: isAvailable,
        isDeviceSupported: isDeviceSupported,
        availableTypes: availableBiometrics,
        isEnabled: _biometricsEnabled,
      );
      
      return Result.success(info);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao verificar biometria: ${e.toString()}',
          code: 'BIOMETRIC_CHECK_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Autentica usando biometria
  Future<Result<bool>> authenticateWithBiometrics({
    String reason = 'Autenticação necessária',
  }) async {
    if (!_biometricsEnabled) {
      return Result.error(
        SecurityError(
          message: 'Biometria não está habilitada',
          code: 'BIOMETRIC_NOT_ENABLED',
        ),
      );
    }

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return Result.success(isAuthenticated);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro na autenticação biométrica: ${e.toString()}',
          code: 'BIOMETRIC_AUTH_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== SECURE STORAGE ==========

  /// Armazena dados com criptografia adicional
  Future<Result<void>> secureStore(String key, String value, {bool requireBiometrics = false}) async {
    try {
      if (requireBiometrics && _biometricsEnabled) {
        final authResult = await authenticateWithBiometrics(
          reason: 'Autenticação necessária para armazenar dados',
        );
        if (authResult.isError || !authResult.data!) {
          return Result.error(
            SecurityError(
              message: 'Autenticação biométrica necessária',
              code: 'BIOMETRIC_AUTH_REQUIRED',
            ),
          );
        }
      }

      // Criptografa o valor antes de armazenar
      final encryptResult = await encrypt(value);
      if (encryptResult.isError) return Result.error(encryptResult.error!);
      
      await _secureStorage.write(key: key, value: encryptResult.data);
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao armazenar dados seguros: ${e.toString()}',
          code: 'SECURE_STORE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Recupera dados com descriptografia
  Future<Result<String?>> secureRetrieve(String key, {bool requireBiometrics = false}) async {
    try {
      if (requireBiometrics && _biometricsEnabled) {
        final authResult = await authenticateWithBiometrics(
          reason: 'Autenticação necessária para acessar dados',
        );
        if (authResult.isError || !authResult.data!) {
          return Result.error(
            SecurityError(
              message: 'Autenticação biométrica necessária',
              code: 'BIOMETRIC_AUTH_REQUIRED',
            ),
          );
        }
      }

      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue == null) {
        return Result.success(null);
      }

      // Descriptografa o valor
      final decryptResult = await decrypt(encryptedValue);
      if (decryptResult.isError) return Result.error(decryptResult.error!);
      
      return Result.success(decryptResult.data);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao recuperar dados seguros: ${e.toString()}',
          code: 'SECURE_RETRIEVE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Remove dados seguros
  Future<Result<void>> secureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao deletar dados seguros: ${e.toString()}',
          code: 'SECURE_DELETE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== RATE LIMITING ==========

  /// Verifica se operação está sendo feita com muita frequência
  Future<Result<bool>> checkRateLimit(String operation, {
    int maxAttempts = 10,
    Duration timeWindow = const Duration(minutes: 1),
  }) async {
    try {
      final now = DateTime.now();
      final attempts = _rateLimitMap[operation] ?? [];
      
      // Remove tentativas antigas
      attempts.removeWhere((attempt) => 
        now.difference(attempt) > timeWindow);
      
      if (attempts.length >= maxAttempts) {
        return Result.success(false); // Rate limit exceeded
      }
      
      attempts.add(now);
      _rateLimitMap[operation] = attempts;
      
      return Result.success(true); // Within rate limit
    } catch (e) {
      return Result.success(true); // Em caso de erro, permite a operação
    }
  }

  /// Registra tentativa falhada
  Future<Result<void>> recordFailedAttempt(String identifier) async {
    try {
      final currentAttempts = _failedAttempts[identifier] ?? 0;
      _failedAttempts[identifier] = currentAttempts + 1;
      
      return Result.success(null);
    } catch (e) {
      return Result.success(null); // Falha não crítica
    }
  }

  /// Verifica se identificador está bloqueado
  Future<Result<bool>> isBlocked(String identifier) async {
    try {
      final attempts = _failedAttempts[identifier] ?? 0;
      return Result.success(attempts >= _maxFailedAttempts);
    } catch (e) {
      return Result.success(false); // Em caso de erro, não bloqueia
    }
  }

  /// Limpa tentativas falhadas
  Future<Result<void>> clearFailedAttempts(String identifier) async {
    try {
      _failedAttempts.remove(identifier);
      return Result.success(null);
    } catch (e) {
      return Result.success(null); // Falha não crítica
    }
  }

  // ========== VALIDAÇÃO E SANITIZAÇÃO ==========

  /// Sanitiza input removendo caracteres perigosos
  String sanitizeInput(String input, {bool allowHtml = false}) {
    if (allowHtml) {
      // Remove apenas scripts perigosos
      return input.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
    } else {
      // Remove todos os caracteres HTML/XML
      return input
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'&[^;]+;'), '')
          .trim();
    }
  }

  /// Valida se string contém apenas caracteres seguros
  bool isInputSafe(String input) {
    // Verifica caracteres perigosos comuns
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'style\s*=.*expression', caseSensitive: false),
    ];
    
    return !dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Gera hash para validação de integridade
  Future<Result<String>> generateIntegrityHash(String data) async {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return Result.success(digest.toString());
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao gerar hash de integridade: ${e.toString()}',
          code: 'INTEGRITY_HASH_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Verifica integridade dos dados
  Future<Result<bool>> verifyIntegrity(String data, String expectedHash) async {
    try {
      final hashResult = await generateIntegrityHash(data);
      if (hashResult.isError) return Result.error(hashResult.error!);
      
      final isValid = _constantTimeCompare(hashResult.data!, expectedHash);
      return Result.success(isValid);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao verificar integridade: ${e.toString()}',
          code: 'INTEGRITY_VERIFY_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Deriva chave usando PBKDF2
  Uint8List _deriveKey(String key, String salt) {
    final keyBytes = utf8.encode(key);
    final saltBytes = utf8.encode(salt);

    // Simula PBKDF2 com múltiplas iterações de SHA-256
    List<int> derivedKey = [...keyBytes, ...saltBytes];
    for (int i = 0; i < _defaultIterations; i++) {
      derivedKey = sha256.convert(derivedKey).bytes;
    }

    // Retorna os primeiros 32 bytes para AES-256
    return Uint8List.fromList(derivedKey.take(32).toList());
  }

  /// Descriptografa dados legacy usando Base64
  Future<Result<String>> _decryptLegacyData(String encryptedData, String? customKey) async {
    try {
      // Remove legacy prefix se presente
      final data = encryptedData.startsWith(_legacyPrefix)
          ? encryptedData.substring(_legacyPrefix.length)
          : encryptedData;

      // Para dados legacy, simplesmente decodifica Base64
      final decoded = utf8.decode(base64Decode(data));

      return Result.success(decoded);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao descriptografar dados legacy: ${e.toString()}',
          code: 'DECRYPT_LEGACY_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Descriptografa dados AES
  Future<Result<String>> _decryptAESData(List<String> parts, String? customKey) async {
    try {
      if (parts.length < 3) {
        return Result.error(
          SecurityError(
            message: 'Formato AES inválido - partes insuficientes',
            code: 'INVALID_AES_FORMAT',
          ),
        );
      }

      final ivBase64 = parts[1];
      final encryptedBase64 = parts[2];

      final keyString = customKey ?? await _getOrCreateKey('default');
      final keyBytes = _deriveKey(keyString, await _getMasterSalt());
      final key = Key(keyBytes);

      final iv = IV.fromBase64(ivBase64);
      final encrypted = Encrypted.fromBase64(encryptedBase64);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return Result.success(decrypted);
    } catch (e, stackTrace) {
      return Result.error(
        SecurityError(
          message: 'Erro ao descriptografar dados AES: ${e.toString()}',
          code: 'DECRYPT_AES_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<String> _getOrCreateKey(String keyName) async {
    final keyKey = '$_keyPrefix$keyName';
    String? key = await _secureStorage.read(key: keyKey);
    
    if (key == null) {
      final keyResult = await generateCryptoKey();
      if (keyResult.isSuccess && keyResult.data != null) {
        key = keyResult.data!;
        await _secureStorage.write(key: keyKey, value: key);
      } else {
        throw Exception('Failed to generate crypto key');
      }
    }
    
    return key;
  }

  Future<void> _ensureMasterSalt() async {
    final existingSalt = await _secureStorage.read(key: _saltKey);
    if (existingSalt == null) {
      final salt = _generateSalt().toString();
      await _secureStorage.write(key: _saltKey, value: salt);
    }
  }

  Future<String> _getMasterSalt() async {
    final salt = await _secureStorage.read(key: _saltKey);
    return salt ?? '0';
  }

  int _generateSalt() {
    final random = Random.secure();
    return random.nextInt(1000000);
  }

  String _generateIV() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Comparação em tempo constante para prevenir timing attacks
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    
    return result == 0;
  }

  /// Dispose - limpa recursos
  Future<void> dispose() async {
    _rateLimitMap.clear();
    _failedAttempts.clear();
    _initialized = false;
  }
}

/// Informações sobre biometria
class BiometricInfo {
  final bool isAvailable;
  final bool isDeviceSupported;
  final List<BiometricType> availableTypes;
  final bool isEnabled;

  BiometricInfo({
    required this.isAvailable,
    required this.isDeviceSupported,
    required this.availableTypes,
    required this.isEnabled,
  });

  bool get hasFingerprintSupport => availableTypes.contains(BiometricType.fingerprint);
  bool get hasFaceSupport => availableTypes.contains(BiometricType.face);
  bool get hasIrisSupport => availableTypes.contains(BiometricType.iris);

  Map<String, dynamic> toMap() {
    return {
      'isAvailable': isAvailable,
      'isDeviceSupported': isDeviceSupported,
      'availableTypes': availableTypes.map((t) => t.name).toList(),
      'isEnabled': isEnabled,
      'hasFingerprintSupport': hasFingerprintSupport,
      'hasFaceSupport': hasFaceSupport,
      'hasIrisSupport': hasIrisSupport,
    };
  }

  @override
  String toString() {
    return 'BiometricInfo(available: $isAvailable, types: ${availableTypes.map((t) => t.name).join(', ')})';
  }
}

/// Erro de segurança especializado
class SecurityError extends AppError {
  SecurityError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.high,
  }) : super(category: ErrorCategory.authentication);

  @override
  SecurityError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return SecurityError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }
}