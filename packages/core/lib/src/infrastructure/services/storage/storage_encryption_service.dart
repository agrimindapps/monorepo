import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Serviço de criptografia para storage
///
/// Responsabilidades:
/// - Encrypt/decrypt values
/// - Key management
/// - Secure storage preparation
///
/// NOTA: Esta é a implementação da lógica que estava vazia no EnhancedStorageService
class StorageEncryptionService {
  final String _encryptionKey;
  late final List<int> _keyBytes;

  StorageEncryptionService({String? encryptionKey})
    : _encryptionKey = encryptionKey ?? _generateDefaultKey() {
    _keyBytes = _deriveKey(_encryptionKey);
  }

  /// Criptografa uma string
  ///
  /// Retorna a string criptografada em base64
  String encrypt(String value) {
    if (value.isEmpty) return value;

    try {
      // Simple XOR encryption (para produção, usar encrypt package com AES)
      final bytes = utf8.encode(value);
      final encrypted = _xorBytes(bytes, _keyBytes);
      return base64.encode(encrypted);
    } catch (e) {
      // Se falhar, retorna o valor original
      return value;
    }
  }

  /// Descriptografa uma string
  ///
  /// Retorna a string descriptografada
  String decrypt(String encryptedValue) {
    if (encryptedValue.isEmpty) return encryptedValue;

    try {
      final encrypted = base64.decode(encryptedValue);
      final decrypted = _xorBytes(encrypted, _keyBytes);
      return utf8.decode(decrypted);
    } catch (e) {
      // Se falhar, retorna o valor original
      return encryptedValue;
    }
  }

  /// XOR encryption/decryption (simétrico)
  List<int> _xorBytes(List<int> data, List<int> key) {
    final result = List<int>.filled(data.length, 0);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    return result;
  }

  /// Deriva key de 32 bytes usando SHA-256
  List<int> _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }

  /// Gera key default (em produção, usar flutter_secure_storage)
  static String _generateDefaultKey() {
    // TODO(production): Mover para flutter_secure_storage
    return 'core-storage-encryption-key-v1';
  }

  /// Valida se string está criptografada (base64)
  bool isEncrypted(String value) {
    try {
      base64.decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
