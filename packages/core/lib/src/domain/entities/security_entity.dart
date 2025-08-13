import 'package:equatable/equatable.dart';

/// Resultado de operação de criptografia
class EncryptionResult extends Equatable {
  const EncryptionResult({
    required this.data,
    required this.success,
    this.error,
  });

  final String data;
  final bool success;
  final String? error;

  @override
  List<Object?> get props => [data, success, error];
}

/// Resultado de verificação de integridade do dispositivo
class DeviceSecurityResult extends Equatable {
  const DeviceSecurityResult({
    required this.isSecure,
    required this.isRooted,
    required this.isJailbroken,
    required this.hasSecureHardware,
    this.details,
  });

  final bool isSecure;
  final bool isRooted;
  final bool isJailbroken;
  final bool hasSecureHardware;
  final String? details;

  @override
  List<Object?> get props => [isSecure, isRooted, isJailbroken, hasSecureHardware, details];
}

/// Status de permissão de biometria
class BiometricPermissionStatus extends Equatable {
  const BiometricPermissionStatus({
    required this.isGranted,
    required this.isAvailable,
    required this.biometricTypes,
    this.error,
  });

  final bool isGranted;
  final bool isAvailable;
  final List<BiometricType> biometricTypes;
  final String? error;

  @override
  List<Object?> get props => [isGranted, isAvailable, biometricTypes, error];
}

/// Resultado de autenticação biométrica
class BiometricAuthResult extends Equatable {
  const BiometricAuthResult({
    required this.isAuthenticated,
    required this.method,
    this.error,
  });

  final bool isAuthenticated;
  final BiometricType? method;
  final String? error;

  @override
  List<Object?> get props => [isAuthenticated, method, error];
}

/// Configuração de criptografia
class EncryptionConfig extends Equatable {
  const EncryptionConfig({
    required this.algorithm,
    required this.keySize,
    this.iterations = 10000,
    this.useHardwareEncryption = false,
  });

  final EncryptionAlgorithm algorithm;
  final int keySize;
  final int iterations;
  final bool useHardwareEncryption;

  @override
  List<Object?> get props => [algorithm, keySize, iterations, useHardwareEncryption];
}

/// Tipos de biometria disponíveis
enum BiometricType {
  face('face'),
  fingerprint('fingerprint'),
  iris('iris'),
  voice('voice');

  const BiometricType(this.value);
  final String value;
}

/// Algoritmos de criptografia suportados
enum EncryptionAlgorithm {
  aes256('aes256'),
  aes128('aes128'),
  rsa2048('rsa2048'),
  rsa4096('rsa4096');

  const EncryptionAlgorithm(this.value);
  final String value;
}

/// Tipos de hash suportados
enum HashType {
  sha256('sha256'),
  sha512('sha512'),
  md5('md5'),
  bcrypt('bcrypt'),
  argon2('argon2');

  const HashType(this.value);
  final String value;
}

/// Nível de segurança
enum SecurityLevel {
  basic('basic'),
  standard('standard'),
  high('high'),
  maximum('maximum');

  const SecurityLevel(this.value);
  final String value;
}