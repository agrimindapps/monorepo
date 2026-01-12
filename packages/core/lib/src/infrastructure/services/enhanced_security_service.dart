import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../shared/enums/error_severity.dart';
import '../../shared/utils/app_error.dart';
import '../../shared/utils/failure.dart';

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
  static const int _defaultIterations = 100000; // PBKDF2 iterations
  static const String _encryptionVersion =
      'v2'; // Version for new AES encryption
  static const String _legacyPrefix = 'legacy:';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();
  final Map<String, List<DateTime>> _rateLimitMap = {};
  final Map<String, int> _failedAttempts = {};
  bool _biometricsEnabled = false;
  int _maxFailedAttempts = 5;

  bool _initialized = false;

  /// Inicializa o security service
  Future<Either<Failure, void>> initialize({
    bool enableBiometrics = true,
    int maxFailedAttempts = 5,
    Duration lockoutDuration = const Duration(minutes: 15),
  }) async {
    if (_initialized) return const Right(null);

    try {
      _maxFailedAttempts = maxFailedAttempts;
      if (enableBiometrics) {
        final isAvailable = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        _biometricsEnabled = isAvailable && isDeviceSupported;
      }
      await _ensureMasterSalt();

      _initialized = true;
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao inicializar security service: ${e.toString()}',
          code: 'SECURITY_INIT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Criptografa dados usando AES-256-GCM
  Future<Either<Failure, String>> encrypt(
    String data, {
    String? customKey,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      final keyString = customKey ?? await _getOrCreateKey('default');
      final keyBytes = _deriveKey(keyString, await _getMasterSalt());
      final key = Key(keyBytes);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(data, iv: iv);
      final result = '$_encryptionVersion:${iv.base64}:${encrypted.base64}';

      return Right(result);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao criptografar dados: ${e.toString()}',
          code: 'ENCRYPT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Descriptografa dados (suporta tanto AES quanto legacy Base64)
  Future<Either<Failure, String>> decrypt(
    String encryptedData, {
    String? customKey,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      if (encryptedData.startsWith(_legacyPrefix) ||
          !encryptedData.contains(':')) {
        return _decryptLegacyData(encryptedData, customKey);
      }

      final parts = encryptedData.split(':');
      if (parts.length < 3) {
        return Left(
          SecurityError(
            message: 'Formato de dados criptografados inválido',
            code: 'INVALID_ENCRYPTED_FORMAT',
          ).toFailure(),
        );
      }

      final version = parts[0];
      if (version == _encryptionVersion) {
        return _decryptAESData(parts, customKey);
      } else {
        return _decryptLegacyData(encryptedData, customKey);
      }
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao descriptografar dados: ${e.toString()}',
          code: 'DECRYPT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Gera hash seguro de senha usando PBKDF2
  Future<Either<Failure, String>> hashPassword(
    String password, {
    String? customSalt,
  }) async {
    try {
      final salt = customSalt ?? await _getMasterSalt();
      final bytes = utf8.encode(password + salt);
      List<int> hash = bytes;
      for (int i = 0; i < _defaultIterations; i++) {
        hash = sha256.convert(hash).bytes;
      }

      final hashedPassword = base64Encode(hash);
      return Right('$salt:$hashedPassword');
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao fazer hash da senha: ${e.toString()}',
          code: 'HASH_PASSWORD_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Verifica senha contra hash
  Future<Either<Failure, bool>> verifyPassword(
    String password,
    String hashedPassword,
  ) async {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) {
        return Left(
          SecurityError(
            message: 'Formato de hash inválido',
            code: 'INVALID_HASH_FORMAT',
          ).toFailure(),
        );
      }

      final salt = parts[0];
      final expectedHash = parts[1];

      final newHashResult = await hashPassword(password, customSalt: salt);
      final leftError = newHashResult.fold((l) => l, (_) => null);
      if (leftError != null) return Left(leftError);

      final newHashData = newHashResult.fold(
        (l) => throw Exception(),
        (r) => r,
      );
      final newHashParts = newHashData.split(':');
      final newHash = newHashParts[1];

      final isValid = _constantTimeCompare(expectedHash, newHash);
      return Right(isValid);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao verificar senha: ${e.toString()}',
          code: 'VERIFY_PASSWORD_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Gera token seguro
  Future<Either<Failure, String>> generateSecureToken({int length = 32}) async {
    try {
      final random = Random.secure();
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

      final token = List.generate(
        length,
        (_) => chars[random.nextInt(chars.length)],
      ).join();

      return Right(token);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao gerar token: ${e.toString()}',
          code: 'TOKEN_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Gera chave criptográfica segura
  Future<Either<Failure, String>> generateCryptoKey({
    int length = _defaultKeyLength,
  }) async {
    try {
      final random = Random.secure();
      final bytes = List.generate(length, (_) => random.nextInt(256));
      final key = base64Encode(bytes);

      return Right(key);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao gerar chave criptográfica: ${e.toString()}',
          code: 'CRYPTO_KEY_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Gera UUID seguro
  Future<Either<Failure, String>> generateSecureUUID() async {
    try {
      final random = Random.secure();
      final bytes = List.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;

      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final uuid =
          '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';

      return Right(uuid);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao gerar UUID: ${e.toString()}',
          code: 'UUID_GENERATION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Verifica se biometria está disponível
  Future<Either<Failure, BiometricInfo>> getBiometricInfo() async {
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

      return Right(info);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao verificar biometria: ${e.toString()}',
          code: 'BIOMETRIC_CHECK_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Autentica usando biometria
  Future<Either<Failure, bool>> authenticateWithBiometrics({
    String reason = 'Autenticação necessária',
  }) async {
    if (!_biometricsEnabled) {
      return Left(
        SecurityError(
          message: 'Biometria não está habilitada',
          code: 'BIOMETRIC_NOT_ENABLED',
        ).toFailure(),
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

      return Right(isAuthenticated);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro na autenticação biométrica: ${e.toString()}',
          code: 'BIOMETRIC_AUTH_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Armazena dados com criptografia adicional
  Future<Either<Failure, void>> secureStore(
    String key,
    String value, {
    bool requireBiometrics = false,
  }) async {
    try {
      if (requireBiometrics && _biometricsEnabled) {
        final authResult = await authenticateWithBiometrics(
          reason: 'Autenticação necessária para armazenar dados',
        );

        final authError = authResult.fold(
          (failure) => failure,
          (isAuthenticated) => isAuthenticated
              ? null
              : const ServerFailure('Autenticação falhou'),
        );
        if (authError != null) {
          return Left(authError);
        }
      }
      final encryptResult = await encrypt(value);

      final encryptError = encryptResult.fold((l) => l, (_) => null);
      if (encryptError != null) return Left(encryptError);

      final encryptedData = encryptResult.fold((_) => '', (r) => r);
      await _secureStorage.write(key: key, value: encryptedData);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao armazenar dados seguros: ${e.toString()}',
          code: 'SECURE_STORE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Recupera dados com descriptografia
  Future<Either<Failure, String?>> secureRetrieve(
    String key, {
    bool requireBiometrics = false,
  }) async {
    try {
      if (requireBiometrics && _biometricsEnabled) {
        final authResult = await authenticateWithBiometrics(
          reason: 'Autenticação necessária para acessar dados',
        );

        final authError = authResult.fold(
          (failure) => failure,
          (isAuthenticated) => isAuthenticated
              ? null
              : const ServerFailure('Autenticação falhou'),
        );
        if (authError != null) {
          return Left(authError);
        }
      }

      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue == null) {
        return const Right(null);
      }
      final decryptResult = await decrypt(encryptedValue);

      return decryptResult.fold((l) => Left(l), (r) => Right(r));
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao recuperar dados seguros: ${e.toString()}',
          code: 'SECURE_RETRIEVE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Remove dados seguros
  Future<Either<Failure, void>> secureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao deletar dados seguros: ${e.toString()}',
          code: 'SECURE_DELETE_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Verifica se operação está sendo feita com muita frequência
  Future<Either<Failure, bool>> checkRateLimit(
    String operation, {
    int maxAttempts = 10,
    Duration timeWindow = const Duration(minutes: 1),
  }) async {
    try {
      final now = DateTime.now();
      final attempts = _rateLimitMap[operation] ?? [];
      attempts.removeWhere((attempt) => now.difference(attempt) > timeWindow);

      if (attempts.length >= maxAttempts) {
        return const Right(false); // Rate limit exceeded
      }

      attempts.add(now);
      _rateLimitMap[operation] = attempts;

      return const Right(true); // Within rate limit
    } catch (e) {
      return const Right(true); // Em caso de erro, permite a operação
    }
  }

  /// Registra tentativa falhada
  Future<Either<Failure, void>> recordFailedAttempt(String identifier) async {
    try {
      final currentAttempts = _failedAttempts[identifier] ?? 0;
      _failedAttempts[identifier] = currentAttempts + 1;

      return const Right(null);
    } catch (e) {
      return const Right(null); // Falha não crítica
    }
  }

  /// Verifica se identificador está bloqueado
  Future<Either<Failure, bool>> isBlocked(String identifier) async {
    try {
      final attempts = _failedAttempts[identifier] ?? 0;
      return Right(attempts >= _maxFailedAttempts);
    } catch (e) {
      return const Right(false); // Em caso de erro, não bloqueia
    }
  }

  /// Limpa tentativas falhadas
  Future<Either<Failure, void>> clearFailedAttempts(String identifier) async {
    try {
      _failedAttempts.remove(identifier);
      return const Right(null);
    } catch (e) {
      return const Right(null); // Falha não crítica
    }
  }

  /// Sanitiza input removendo caracteres perigosos
  String sanitizeInput(String input, {bool allowHtml = false}) {
    if (allowHtml) {
      return input.replaceAll(
        RegExp(
          r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
          caseSensitive: false,
        ),
        '',
      );
    } else {
      return input
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'&[^;]+;'), '')
          .trim();
    }
  }

  /// Valida se string contém apenas caracteres seguros
  bool isInputSafe(String input) {
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
  Future<Either<Failure, String>> generateIntegrityHash(String data) async {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return Right(digest.toString());
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao gerar hash de integridade: ${e.toString()}',
          code: 'INTEGRITY_HASH_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Verifica integridade dos dados
  Future<Either<Failure, bool>> verifyIntegrity(
    String data,
    String expectedHash,
  ) async {
    try {
      final hashResult = await generateIntegrityHash(data);
      final hashError = hashResult.fold((l) => l, (_) => null);
      if (hashError != null) return Left(hashError);

      final hashData = hashResult.fold((_) => '', (r) => r);
      final isValid = _constantTimeCompare(hashData, expectedHash);
      return Right(isValid);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao verificar integridade: ${e.toString()}',
          code: 'INTEGRITY_VERIFY_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Deriva chave usando PBKDF2
  Uint8List _deriveKey(String key, String salt) {
    final keyBytes = utf8.encode(key);
    final saltBytes = utf8.encode(salt);
    List<int> derivedKey = [...keyBytes, ...saltBytes];
    for (int i = 0; i < _defaultIterations; i++) {
      derivedKey = sha256.convert(derivedKey).bytes;
    }
    return Uint8List.fromList(derivedKey.take(32).toList());
  }

  /// Descriptografa dados legacy usando Base64
  Future<Either<Failure, String>> _decryptLegacyData(
    String encryptedData,
    String? customKey,
  ) async {
    try {
      final data = encryptedData.startsWith(_legacyPrefix)
          ? encryptedData.substring(_legacyPrefix.length)
          : encryptedData;
      final decoded = utf8.decode(base64Decode(data));

      return Right(decoded);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao descriptografar dados legacy: ${e.toString()}',
          code: 'DECRYPT_LEGACY_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Descriptografa dados AES
  Future<Either<Failure, String>> _decryptAESData(
    List<String> parts,
    String? customKey,
  ) async {
    try {
      if (parts.length < 3) {
        return Left(
          SecurityError(
            message: 'Formato AES inválido - partes insuficientes',
            code: 'INVALID_AES_FORMAT',
          ).toFailure(),
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

      return Right(decrypted);
    } catch (e, stackTrace) {
      return Left(
        SecurityError(
          message: 'Erro ao descriptografar dados AES: ${e.toString()}',
          code: 'DECRYPT_AES_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  Future<String> _getOrCreateKey(String keyName) async {
    final keyKey = '$_keyPrefix$keyName';
    String? key = await _secureStorage.read(key: keyKey);

    if (key == null) {
      final keyResult = await generateCryptoKey();

      key = keyResult.fold(
        (l) => throw Exception('Failed to generate crypto key: ${l.message}'),
        (r) => r,
      );

      await _secureStorage.write(key: keyKey, value: key);
    }

    return key!;
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

  bool get hasFingerprintSupport =>
      availableTypes.contains(BiometricType.fingerprint);
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
