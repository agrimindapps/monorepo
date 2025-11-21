import 'package:core/core.dart' as core;
import '../../domain/entities/device_session.dart';

/// Resultado da validação de dispositivo
class DeviceValidationResult {
  const DeviceValidationResult({
    required this.isValid,
    this.errorMessage,
    this.requiresTrust = false,
    this.requiresSecurityCheck = false,
  });

  final bool isValid;
  final String? errorMessage;
  final bool requiresTrust;
  final bool requiresSecurityCheck;

  /// Validação bem-sucedida
  factory DeviceValidationResult.success() {
    return const DeviceValidationResult(isValid: true);
  }

  /// Validação falhou
  factory DeviceValidationResult.failure(
    String errorMessage, {
    bool requiresTrust = false,
    bool requiresSecurityCheck = false,
  }) {
    return DeviceValidationResult(
      isValid: false,
      errorMessage: errorMessage,
      requiresTrust: requiresTrust,
      requiresSecurityCheck: requiresSecurityCheck,
    );
  }
}

/// Serviço responsável por validar dispositivos
///
/// Centraliza todas as regras de validação de dispositivos,
/// seguindo o princípio Single Responsibility.

class DeviceValidator {
  DeviceValidator();

  /// Limite máximo de dispositivos por conta (plano gratuito)
  static const int _maxDevicesForFreeAccount = 3;

  /// Limite máximo de dispositivos por conta (plano premium)
  static const int _maxDevicesForPremiumAccount = 10;

  /// Valida se um dispositivo pode ser usado para login
  DeviceValidationResult validateDeviceForLogin(
    core.DeviceEntity device, {
    bool isNewDevice = false,
  }) {
    // Verifica se é um dispositivo físico
    if (!device.isPhysicalDevice) {
      return DeviceValidationResult.failure(
        'Emuladores e dispositivos virtuais não são permitidos',
        requiresSecurityCheck: true,
      );
    }

    // Verifica se o dispositivo está ativo
    if (!device.isActive) {
      return DeviceValidationResult.failure('Este dispositivo foi desativado');
    }

    // Dispositivos novos não confiáveis precisam de aprovação
    if (isNewDevice && !device.isTrusted) {
      return DeviceValidationResult.failure(
        'Dispositivo novo requer aprovação',
        requiresTrust: true,
      );
    }

    return DeviceValidationResult.success();
  }

  /// Valida se um novo dispositivo pode ser registrado
  DeviceValidationResult validateDeviceRegistration(
    core.DeviceEntity device, {
    required int currentDeviceCount,
    required bool isPremiumUser,
  }) {
    // Verifica o limite de dispositivos
    final maxDevices = isPremiumUser
        ? _maxDevicesForPremiumAccount
        : _maxDevicesForFreeAccount;

    if (currentDeviceCount >= maxDevices) {
      return DeviceValidationResult.failure(
        'Limite de dispositivos atingido ($maxDevices dispositivos). '
        '${isPremiumUser ? '' : 'Faça upgrade para adicionar mais.'}',
      );
    }

    // Verifica se é um dispositivo físico
    if (!device.isPhysicalDevice) {
      return DeviceValidationResult.failure(
        'Apenas dispositivos físicos podem ser registrados',
        requiresSecurityCheck: true,
      );
    }

    // Verifica se o dispositivo está ativo
    if (!device.isActive) {
      return DeviceValidationResult.failure(
        'Dispositivo inativo não pode ser registrado',
      );
    }

    return DeviceValidationResult.success();
  }

  /// Valida se uma sessão de dispositivo ainda é válida
  DeviceValidationResult validateDeviceSession(DeviceSession session) {
    // Verifica se a sessão expirou
    if (session.isExpired) {
      return DeviceValidationResult.failure(
        'Sessão expirada. Faça login novamente.',
      );
    }

    // Verifica se o dispositivo está ativo
    if (!session.isActive) {
      return DeviceValidationResult.failure('Sessão inativa ou revogada');
    }

    // Verifica se há informações suspeitas de localização
    if (_hasSuspiciousLocationChange(session)) {
      return DeviceValidationResult.failure(
        'Mudança de localização suspeita detectada',
        requiresSecurityCheck: true,
      );
    }

    return DeviceValidationResult.success();
  }

  /// Valida se um dispositivo pode sincronizar dados offline
  DeviceValidationResult validateOfflineSync(core.DeviceEntity device) {
    if (!device.isTrusted) {
      return DeviceValidationResult.failure(
        'Apenas dispositivos confiáveis podem sincronizar offline',
        requiresTrust: true,
      );
    }

    return DeviceValidationResult.success();
  }

  /// Verifica se um dispositivo pode ter suas credenciais confiáveis
  bool canBeTrusted(core.DeviceEntity device) {
    return device.isPhysicalDevice && device.isActive;
  }

  /// Verifica se há mudança suspeita de localização na sessão
  bool _hasSuspiciousLocationChange(DeviceSession session) {
    // Implementação básica - pode ser expandida com lógica mais complexa
    // Por exemplo, verificar se houve mudança de país/continente em curto período

    // Por enquanto, sempre retorna false (sem verificação real)
    return false;
  }

  /// Calcula o nível de confiança de um dispositivo (0-100)
  int calculateTrustLevel(core.DeviceEntity device) {
    var trustLevel = 0;

    // Dispositivo físico: +30 pontos
    if (device.isPhysicalDevice) trustLevel += 30;

    // Dispositivo confiável: +40 pontos
    if (device.isTrusted) trustLevel += 40;

    // Dispositivo ativo: +10 pontos
    if (device.isActive) trustLevel += 10;

    // Atividade recente: +20 pontos
    final daysSinceActivity = DateTime.now()
        .difference(device.lastActiveAt)
        .inDays;

    if (daysSinceActivity <= 7) {
      trustLevel += 20;
    } else if (daysSinceActivity <= 30) {
      trustLevel += 10;
    }

    return trustLevel.clamp(0, 100);
  }

  /// Verifica se o limite de dispositivos foi atingido
  bool hasReachedDeviceLimit({
    required int currentDeviceCount,
    required bool isPremiumUser,
  }) {
    final maxDevices = isPremiumUser
        ? _maxDevicesForPremiumAccount
        : _maxDevicesForFreeAccount;

    return currentDeviceCount >= maxDevices;
  }

  /// Obtém o número máximo de dispositivos permitidos
  int getMaxDevices({required bool isPremiumUser}) {
    return isPremiumUser
        ? _maxDevicesForPremiumAccount
        : _maxDevicesForFreeAccount;
  }
}
