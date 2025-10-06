import '../entities/security_entity.dart';

/// Interface para operações de segurança
abstract class ISecurityRepository {

  /// Criptografar dados usando uma chave
  Future<EncryptionResult> encrypt({
    required String data,
    required String key,
    EncryptionConfig? config,
  });

  /// Descriptografar dados usando uma chave
  Future<EncryptionResult> decrypt({
    required String encryptedData,
    required String key,
    EncryptionConfig? config,
  });

  /// Gerar hash de uma string
  Future<String> generateHash({
    required String data,
    required HashType type,
    String? salt,
  });

  /// Verificar se uma string corresponde ao hash
  Future<bool> verifyHash({
    required String data,
    required String hash,
    required HashType type,
    String? salt,
  });

  /// Gerar uma chave aleatória
  Future<String> generateKey({
    required int length,
    bool includeSymbols = true,
    bool includeNumbers = true,
    bool includeLowercase = true,
    bool includeUppercase = true,
  });

  /// Gerar salt para hash
  Future<String> generateSalt({int length = 16});

  /// Verificar se biometria está disponível
  Future<BiometricPermissionStatus> getBiometricStatus();

  /// Solicitar permissão para usar biometria
  Future<BiometricPermissionStatus> requestBiometricPermission();

  /// Autenticar usando biometria
  Future<BiometricAuthResult> authenticateWithBiometrics({
    required String reason,
    String? title,
    String? subtitle,
    String? negativeButton,
    bool stickyAuth = true,
  });

  /// Verificar se um tipo específico de biometria está disponível
  Future<bool> isBiometricTypeAvailable(BiometricType type);

  /// Verificar integridade e segurança do dispositivo
  Future<DeviceSecurityResult> checkDeviceSecurity();

  /// Verificar se o dispositivo está com root/jailbreak
  Future<bool> isDeviceCompromised();

  /// Verificar se o app está rodando em emulador
  Future<bool> isRunningOnEmulator();

  /// Verificar se o app está sendo debugado
  Future<bool> isDebugging();

  /// Verificar se a conexão SSL é segura
  Future<bool> isSSLConnectionSecure(String url);

  /// Armazenar dados de forma segura no dispositivo
  Future<bool> storeSecureData({
    required String key,
    required String value,
    SecurityLevel securityLevel = SecurityLevel.standard,
  });

  /// Recuperar dados armazenados de forma segura
  Future<String?> getSecureData({
    required String key,
    SecurityLevel securityLevel = SecurityLevel.standard,
  });

  /// Remover dados seguros
  Future<bool> removeSecureData(String key);

  /// Verificar se uma chave existe no armazenamento seguro
  Future<bool> hasSecureData(String key);

  /// Limpar todos os dados seguros
  Future<bool> clearAllSecureData();

  /// Validar força de uma senha
  Future<double> validatePasswordStrength(String password);

  /// Gerar senha segura
  Future<String> generateSecurePassword({
    int length = 16,
    bool includeSymbols = true,
    bool includeNumbers = true,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool avoidAmbiguous = true,
  });

  /// Validar formato de email
  bool validateEmail(String email);

  /// Validar se uma URL é segura (HTTPS)
  bool validateSecureUrl(String url);
}