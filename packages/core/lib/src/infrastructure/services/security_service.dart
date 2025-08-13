import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart' as platform_biometric;
import 'package:local_auth_platform_interface/types/auth_messages.dart';

import '../../domain/entities/security_entity.dart' as domain;
import '../../domain/repositories/i_security_repository.dart';

/// Implementação do serviço de segurança
class SecurityService implements ISecurityRepository {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  static const String _keyPrefix = 'app_secure_';

  // ==========================================================================
  // CRIPTOGRAFIA E HASHING
  // ==========================================================================

  @override
  Future<domain.EncryptionResult> encrypt({
    required String data,
    required String key,
    domain.EncryptionConfig? config,
  }) async {
    try {
      // Implementação básica usando base64 + hash da chave
      // Para produção, use uma biblioteca de criptografia mais robusta
      final keyBytes = utf8.encode(key);
      final keyHash = sha256.convert(keyBytes).bytes;
      final dataBytes = utf8.encode(data);
      
      // XOR simples para demonstração - usar AES em produção
      final encryptedBytes = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ keyHash[i % keyHash.length]);
      }
      
      final encryptedData = base64Encode(encryptedBytes);
      
      return domain.EncryptionResult(
        data: encryptedData,
        success: true,
      );
    } catch (e) {
      debugPrint('❌ Error encrypting data: $e');
      return domain.EncryptionResult(
        data: '',
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<domain.EncryptionResult> decrypt({
    required String encryptedData,
    required String key,
    domain.EncryptionConfig? config,
  }) async {
    try {
      final keyBytes = utf8.encode(key);
      final keyHash = sha256.convert(keyBytes).bytes;
      final encryptedBytes = base64Decode(encryptedData);
      
      // XOR reverso
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyHash[i % keyHash.length]);
      }
      
      final decryptedData = utf8.decode(decryptedBytes);
      
      return domain.EncryptionResult(
        data: decryptedData,
        success: true,
      );
    } catch (e) {
      debugPrint('❌ Error decrypting data: $e');
      return domain.EncryptionResult(
        data: '',
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<String> generateHash({
    required String data,
    required domain.HashType type,
    String? salt,
  }) async {
    try {
      final input = salt != null ? data + salt : data;
      final bytes = utf8.encode(input);

      switch (type) {
        case domain.HashType.sha256:
          return sha256.convert(bytes).toString();
        case domain.HashType.sha512:
          return sha512.convert(bytes).toString();
        case domain.HashType.md5:
          return md5.convert(bytes).toString();
        case domain.HashType.bcrypt:
          // Implementação simplificada - usar biblioteca bcrypt real em produção
          return sha256.convert(bytes).toString();
        case domain.HashType.argon2:
          // Implementação simplificada - usar biblioteca argon2 real em produção
          return sha512.convert(bytes).toString();
      }
    } catch (e) {
      debugPrint('❌ Error generating hash: $e');
      return '';
    }
  }

  @override
  Future<bool> verifyHash({
    required String data,
    required String hash,
    required domain.HashType type,
    String? salt,
  }) async {
    try {
      final generatedHash = await generateHash(
        data: data,
        type: type,
        salt: salt,
      );
      return generatedHash == hash;
    } catch (e) {
      debugPrint('❌ Error verifying hash: $e');
      return false;
    }
  }

  @override
  Future<String> generateKey({
    required int length,
    bool includeSymbols = true,
    bool includeNumbers = true,
    bool includeLowercase = true,
    bool includeUppercase = true,
  }) async {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    String chars = '';
    if (includeLowercase) chars += lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;
    
    if (chars.isEmpty) chars = lowercase + uppercase + numbers;
    
    final Random random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  @override
  Future<String> generateSalt({int length = 16}) async {
    return await generateKey(
      length: length,
      includeSymbols: true,
      includeNumbers: true,
      includeLowercase: true,
      includeUppercase: true,
    );
  }

  // ==========================================================================
  // BIOMETRIA
  // ==========================================================================

  @override
  Future<domain.BiometricPermissionStatus> getBiometricStatus() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<domain.BiometricType> availableTypes = [];
      
      if (isAvailable) {
        final List<platform_biometric.domain.BiometricType> deviceBiometrics = 
            await _localAuth.getAvailableBiometrics();
        
        for (var biometric in deviceBiometrics) {
          switch (biometric) {
            case platform_biometric.domain.BiometricType.face:
              availableTypes.add(domain.BiometricType.face);
              break;
            case platform_biometric.domain.BiometricType.fingerprint:
              availableTypes.add(domain.BiometricType.fingerprint);
              break;
            case platform_biometric.domain.BiometricType.iris:
              availableTypes.add(domain.BiometricType.iris);
              break;
            case platform_biometric.domain.BiometricType.voice:
              availableTypes.add(domain.BiometricType.voice);
              break;
            default:
              // Tipo não reconhecido
              break;
          }
        }
      }
      
      return domain.BiometricPermissionStatus(
        isGranted: isAvailable && availableTypes.isNotEmpty,
        isAvailable: isAvailable,
        biometricTypes: availableTypes,
      );
    } catch (e) {
      debugPrint('❌ Error getting biometric status: $e');
      return domain.BiometricPermissionStatus(
        isGranted: false,
        isAvailable: false,
        biometricTypes: [],
        error: e.toString(),
      );
    }
  }

  @override
  Future<domain.BiometricPermissionStatus> requestBiometricPermission() async {
    // A permissão é solicitada automaticamente quando usamos biometria
    return await getBiometricStatus();
  }

  @override
  Future<domain.BiometricAuthResult> authenticateWithBiometrics({
    required String reason,
    String? title,
    String? subtitle,
    String? negativeButton,
    bool stickyAuth = true,
  }) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: title ?? 'Autenticação Biométrica',
            cancelButton: negativeButton ?? 'Cancelar',
            deviceCredentialsRequiredTitle: 'Credenciais do Dispositivo',
            deviceCredentialsSetupDescription: 'Configure suas credenciais nas configurações do dispositivo',
            goToSettingsButton: 'Configurações',
            goToSettingsDescription: 'Configure suas credenciais biométricas',
          ),
          IOSAuthMessages(
            cancelButton: negativeButton ?? 'Cancelar',
            goToSettingsButton: 'Configurações',
            goToSettingsDescription: 'Configure suas credenciais biométricas',
            lockOut: 'Tente novamente',
          ),
        ],
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );

      domain.BiometricType? usedMethod;
      if (isAuthenticated) {
        // Determinar qual método foi usado (simplificado)
        final status = await getBiometricStatus();
        usedMethod = status.biometricTypes.isNotEmpty 
            ? status.biometricTypes.first 
            : null;
      }

      return domain.BiometricAuthResult(
        isAuthenticated: isAuthenticated,
        method: usedMethod,
      );
    } catch (e) {
      debugPrint('❌ Error authenticating with biometrics: $e');
      return domain.BiometricAuthResult(
        isAuthenticated: false,
        method: null,
        error: e.toString(),
      );
    }
  }

  @override
  Future<bool> isdomain.BiometricTypeAvailable(domain.BiometricType type) async {
    try {
      final status = await getBiometricStatus();
      return status.biometricTypes.contains(type);
    } catch (e) {
      debugPrint('❌ Error checking biometric type availability: $e');
      return false;
    }
  }

  // ==========================================================================
  // SEGURANÇA DO DISPOSITIVO
  // ==========================================================================

  @override
  Future<domain.DeviceSecurityResult> checkDeviceSecurity() async {
    try {
      final bool isCompromised = await isDeviceCompromised();
      final bool isEmulator = await isRunningOnEmulator();
      final bool isDebuggingActive = await isDebugging();
      
      // Verificar se tem hardware seguro (simplificado)
      final bool hasSecureHardware = !isEmulator && !isCompromised;
      
      final bool isSecure = !isCompromised && !isDebuggingActive;
      
      return domain.DeviceSecurityResult(
        isSecure: isSecure,
        isRooted: Platform.isAndroid ? isCompromised : false,
        isJailbroken: Platform.isIOS ? isCompromised : false,
        hasSecureHardware: hasSecureHardware,
        details: isSecure 
            ? 'Dispositivo seguro' 
            : 'Possíveis problemas de segurança detectados',
      );
    } catch (e) {
      debugPrint('❌ Error checking device security: $e');
      return const domain.DeviceSecurityResult(
        isSecure: false,
        isRooted: false,
        isJailbroken: false,
        hasSecureHardware: false,
        details: 'Erro ao verificar segurança do dispositivo',
      );
    }
  }

  @override
  Future<bool> isDeviceCompromised() async {
    try {
      // Verificação básica de root/jailbreak
      // Em produção, usar uma biblioteca especializada como freeRASP
      
      if (Platform.isAndroid) {
        // Verificações básicas para root
        const rootPaths = [
          '/system/app/Superuser.apk',
          '/sbin/su',
          '/system/bin/su',
          '/system/xbin/su',
          '/data/local/xbin/su',
          '/data/local/bin/su',
          '/system/sd/xbin/su',
          '/system/bin/failsafe/su',
          '/data/local/su',
        ];
        
        for (String path in rootPaths) {
          if (await File(path).exists()) {
            return true;
          }
        }
      }
      
      if (Platform.isIOS) {
        // Verificações básicas para jailbreak
        const jailbreakPaths = [
          '/Applications/Cydia.app',
          '/Library/MobileSubstrate/MobileSubstrate.dylib',
          '/bin/bash',
          '/usr/sbin/sshd',
          '/etc/apt',
          '/private/var/lib/apt/',
        ];
        
        for (String path in jailbreakPaths) {
          if (await File(path).exists()) {
            return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking device compromise: $e');
      return false;
    }
  }

  @override
  Future<bool> isRunningOnEmulator() async {
    try {
      if (Platform.isAndroid) {
        // Verificação básica para Android
        return Platform.environment.containsKey('ANDROID_EMULATOR');
      }
      
      if (Platform.isIOS) {
        // Verificação básica para iOS Simulator
        return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking emulator: $e');
      return false;
    }
  }

  @override
  Future<bool> isDebugging() async {
    // Verificar se está em modo debug
    return kDebugMode;
  }

  @override
  Future<bool> isSSLConnectionSecure(String url) async {
    try {
      return url.toLowerCase().startsWith('https://');
    } catch (e) {
      debugPrint('❌ Error checking SSL connection: $e');
      return false;
    }
  }

  // ==========================================================================
  // ARMAZENAMENTO SEGURO
  // ==========================================================================

  @override
  Future<bool> storeSecureData({
    required String key,
    required String value,
    domain.SecurityLevel securityLevel = domain.SecurityLevel.standard,
  }) async {
    try {
      final secureKey = _keyPrefix + key;
      await _secureStorage.write(key: secureKey, value: value);
      return true;
    } catch (e) {
      debugPrint('❌ Error storing secure data: $e');
      return false;
    }
  }

  @override
  Future<String?> getSecureData({
    required String key,
    domain.SecurityLevel securityLevel = domain.SecurityLevel.standard,
  }) async {
    try {
      final secureKey = _keyPrefix + key;
      return await _secureStorage.read(key: secureKey);
    } catch (e) {
      debugPrint('❌ Error getting secure data: $e');
      return null;
    }
  }

  @override
  Future<bool> removeSecureData(String key) async {
    try {
      final secureKey = _keyPrefix + key;
      await _secureStorage.delete(key: secureKey);
      return true;
    } catch (e) {
      debugPrint('❌ Error removing secure data: $e');
      return false;
    }
  }

  @override
  Future<bool> hasSecureData(String key) async {
    try {
      final secureKey = _keyPrefix + key;
      return await _secureStorage.containsKey(key: secureKey);
    } catch (e) {
      debugPrint('❌ Error checking secure data: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing all secure data: $e');
      return false;
    }
  }

  // ==========================================================================
  // VALIDAÇÕES
  // ==========================================================================

  @override
  Future<double> validatePasswordStrength(String password) async {
    double strength = 0.0;
    
    // Comprimento
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.1;
    
    // Caracteres diversos
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;
    
    return strength.clamp(0.0, 1.0);
  }

  @override
  Future<String> generateSecurePassword({
    int length = 16,
    bool includeSymbols = true,
    bool includeNumbers = true,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool avoidAmbiguous = true,
  }) async {
    String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String numbers = '0123456789';
    String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    if (avoidAmbiguous) {
      lowercase = lowercase.replaceAll(RegExp(r'[il1Lo0O]'), '');
      uppercase = uppercase.replaceAll(RegExp(r'[il1Lo0O]'), '');
      numbers = numbers.replaceAll(RegExp(r'[10O]'), '');
    }
    
    String chars = '';
    if (includeLowercase) chars += lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;
    
    if (chars.isEmpty) chars = lowercase + uppercase + numbers;
    
    final Random random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  @override
  bool validateEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }

  @override
  bool validateSecureUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
}