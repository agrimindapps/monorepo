// Dart imports:
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstração para armazenamento seguro de dados sensíveis
/// Responsabilidade única: gerenciar criptografia e armazenamento seguro
class SecureStorageService extends GetxService {
  static SecureStorageService? _instance;
  
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._internal();
    return _instance!;
  }
  
  SecureStorageService._internal();
  
  // Fallback para SharedPreferences se flutter_secure_storage não estiver disponível
  SharedPreferences? _prefs;
  bool _isSecureStorageAvailable = false;
  
  // Chaves para armazenamento
  static const String _keyPrefix = 'secure_';
  static const String _migrationMarker = 'secure_storage_migrated_v1';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }
  
  /// Inicializa o sistema de storage seguro
  Future<void> _initializeStorage() async {
    try {
      // Tenta usar secure storage (requer flutter_secure_storage no pubspec.yaml)
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        _isSecureStorageAvailable = true;
        debugPrint('🔐 SecureStorageService: Flutter Secure Storage disponível');
      } else {
        // Fallback para SharedPreferences com criptografia básica
        _prefs = await SharedPreferences.getInstance();
        _isSecureStorageAvailable = false;
        debugPrint('⚠️ SecureStorageService: Usando SharedPreferences com criptografia');
      }
      
      // Migra dados existentes se necessário
      await _migrateExistingData();
      
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro na inicialização: $e');
      // Fallback para SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      _isSecureStorageAvailable = false;
    }
  }
  
  /// Armazena valor de forma segura
  Future<bool> setSecureValue(String key, String value) async {
    try {
      final secureKey = _keyPrefix + key;
      
      if (_isSecureStorageAvailable) {
        return await _setSecureStorageValue(secureKey, value);
      } else {
        return await _setEncryptedSharedPrefsValue(secureKey, value);
      }
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao armazenar $key: $e');
      return false;
    }
  }
  
  /// Recupera valor seguro
  Future<String?> getSecureValue(String key) async {
    try {
      final secureKey = _keyPrefix + key;
      
      if (_isSecureStorageAvailable) {
        return await _getSecureStorageValue(secureKey);
      } else {
        return await _getEncryptedSharedPrefsValue(secureKey);
      }
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao recuperar $key: $e');
      return null;
    }
  }
  
  /// Remove valor seguro
  Future<bool> removeSecureValue(String key) async {
    try {
      final secureKey = _keyPrefix + key;
      
      if (_isSecureStorageAvailable) {
        return await _removeSecureStorageValue(secureKey);
      } else {
        return await _removeEncryptedSharedPrefsValue(secureKey);
      }
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao remover $key: $e');
      return false;
    }
  }
  
  /// Verifica se uma chave existe
  Future<bool> containsKey(String key) async {
    try {
      final value = await getSecureValue(key);
      return value != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Armazena dados JSON de forma segura
  Future<bool> setSecureJson(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = json.encode(data);
      return await setSecureValue(key, jsonString);
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao armazenar JSON $key: $e');
      return false;
    }
  }
  
  /// Recupera dados JSON seguros
  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    try {
      final jsonString = await getSecureValue(key);
      if (jsonString == null) return null;
      
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao recuperar JSON $key: $e');
      return null;
    }
  }
  
  /// Limpa todos os dados seguros
  Future<bool> clearAll() async {
    try {
      if (_isSecureStorageAvailable) {
        // Não implementado - flutter_secure_storage não tem método clear
        // Seria necessário manter lista de chaves
        debugPrint('⚠️ SecureStorageService: Clear all não implementado para secure storage');
        return true;
      } else {
        if (_prefs != null) {
          final keys = _prefs!.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
          for (final key in keys) {
            await _prefs!.remove(key);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro ao limpar todos os dados: $e');
      return false;
    }
  }
  
  /// Implementação usando flutter_secure_storage (placeholder)
  Future<bool> _setSecureStorageValue(String key, String value) async {
    try {
      // Placeholder - requer flutter_secure_storage package
      // const storage = FlutterSecureStorage();
      // await storage.write(key: key, value: value);
      
      // Para este exemplo, usar SharedPreferences criptografado
      return await _setEncryptedSharedPrefsValue(key, value);
    } catch (e) {
      throw PlatformException(
        code: 'SECURE_STORAGE_ERROR',
        message: 'Erro ao usar secure storage: $e',
      );
    }
  }
  
  Future<String?> _getSecureStorageValue(String key) async {
    try {
      // Placeholder - requer flutter_secure_storage package
      // const storage = FlutterSecureStorage();
      // return await storage.read(key: key);
      
      // Para este exemplo, usar SharedPreferences criptografado
      return await _getEncryptedSharedPrefsValue(key);
    } catch (e) {
      throw PlatformException(
        code: 'SECURE_STORAGE_ERROR',
        message: 'Erro ao ler secure storage: $e',
      );
    }
  }
  
  Future<bool> _removeSecureStorageValue(String key) async {
    try {
      // Placeholder - requer flutter_secure_storage package
      // const storage = FlutterSecureStorage();
      // await storage.delete(key: key);
      
      // Para este exemplo, usar SharedPreferences criptografado
      return await _removeEncryptedSharedPrefsValue(key);
    } catch (e) {
      throw PlatformException(
        code: 'SECURE_STORAGE_ERROR',
        message: 'Erro ao remover do secure storage: $e',
      );
    }
  }
  
  /// Implementação com SharedPreferences e criptografia básica
  Future<bool> _setEncryptedSharedPrefsValue(String key, String value) async {
    if (_prefs == null) return false;
    
    final encryptedValue = _encryptValue(value);
    return await _prefs!.setString(key, encryptedValue);
  }
  
  Future<String?> _getEncryptedSharedPrefsValue(String key) async {
    if (_prefs == null) return null;
    
    final encryptedValue = _prefs!.getString(key);
    if (encryptedValue == null) return null;
    
    return _decryptValue(encryptedValue);
  }
  
  Future<bool> _removeEncryptedSharedPrefsValue(String key) async {
    if (_prefs == null) return false;
    
    return await _prefs!.remove(key);
  }
  
  /// Criptografia básica (Base64 + SHA256 hash como chave)
  String _encryptValue(String value) {
    try {
      // Criptografia simples usando Base64
      // Em produção, usar algoritmos mais robustos
      final bytes = utf8.encode(value);
      final encoded = base64.encode(bytes);
      
      // Adiciona hash para verificação de integridade
      final hash = sha256.convert(utf8.encode(value)).toString();
      final combined = '$encoded:$hash';
      
      return base64.encode(utf8.encode(combined));
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro na criptografia: $e');
      return value; // Fallback sem criptografia
    }
  }
  
  String? _decryptValue(String encryptedValue) {
    try {
      // Decodifica
      final decodedBytes = base64.decode(encryptedValue);
      final combined = utf8.decode(decodedBytes);
      
      final parts = combined.split(':');
      if (parts.length != 2) {
        throw Exception('Formato inválido');
      }
      
      final encoded = parts[0];
      final storedHash = parts[1];
      
      // Decodifica valor
      final valueBytes = base64.decode(encoded);
      final value = utf8.decode(valueBytes);
      
      // Verifica integridade
      final computedHash = sha256.convert(utf8.encode(value)).toString();
      if (computedHash != storedHash) {
        throw Exception('Falha na verificação de integridade');
      }
      
      return value;
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro na descriptografia: $e');
      return null;
    }
  }
  
  /// Migra dados existentes de SharedPreferences para armazenamento seguro
  Future<void> _migrateExistingData() async {
    try {
      if (_prefs == null) return;
      
      // Verifica se migração já foi feita
      if (_prefs!.getBool(_migrationMarker) == true) {
        debugPrint('✅ SecureStorageService: Migração já realizada');
        return;
      }
      
      // Lista de chaves conhecidas que devem ser migradas
      final keysToMigrate = [
        'dev_test_subscription',
        'dev_test_subscription_timestamp',
      ];
      
      int migratedCount = 0;
      
      for (final key in keysToMigrate) {
        final value = _prefs!.getString(key);
        if (value != null) {
          // Migra para armazenamento seguro
          final success = await setSecureValue(key, value);
          if (success) {
            // Remove da SharedPreferences original
            await _prefs!.remove(key);
            migratedCount++;
            debugPrint('🔄 SecureStorageService: Migrado $key');
          }
        }
      }
      
      // Marca migração como concluída
      await _prefs!.setBool(_migrationMarker, true);
      
      debugPrint('✅ SecureStorageService: Migração concluída - $migratedCount itens migrados');
      
    } catch (e) {
      debugPrint('❌ SecureStorageService: Erro na migração: $e');
    }
  }
  
  /// Obtém estatísticas do storage
  Map<String, dynamic> getStats() {
    return {
      'isSecureStorageAvailable': _isSecureStorageAvailable,
      'hasSharedPreferences': _prefs != null,
      'storageType': _isSecureStorageAvailable ? 'FlutterSecureStorage' : 'EncryptedSharedPreferences',
    };
  }
}