/// Configuração de limites de dispositivos para o app
/// 
/// Define quantos dispositivos podem estar ativos simultaneamente
/// e quais plataformas devem ser contadas no limite
class DeviceLimitConfig {
  const DeviceLimitConfig({
    this.maxMobileDevices = 3,
    this.maxWebDevices = -1, // -1 = ilimitado
    this.countWebInLimit = false,
    this.premiumMaxMobileDevices = 6,
    this.premiumMaxWebDevices = -1,
    this.allowEmulators = true,
    this.inactivityDaysForCleanup = 90,
  });

  /// Limite máximo de dispositivos mobile (iOS/Android)
  /// Padrão: 3 dispositivos
  final int maxMobileDevices;

  /// Limite máximo de dispositivos web
  /// -1 significa ilimitado
  final int maxWebDevices;

  /// Se dispositivos web devem contar no limite total
  /// Padrão: false (web não conta)
  final bool countWebInLimit;

  /// Limite de dispositivos mobile para usuários premium
  final int premiumMaxMobileDevices;

  /// Limite de dispositivos web para usuários premium
  final int premiumMaxWebDevices;

  /// Se emuladores/simuladores são permitidos
  final bool allowEmulators;

  /// Dias de inatividade para limpeza automática de dispositivos
  final int inactivityDaysForCleanup;

  /// Verifica se uma plataforma deve ser contada no limite
  bool shouldCountPlatform(String platform) {
    final platformLower = platform.toLowerCase();
    
    // Web nunca conta se countWebInLimit é false
    if (platformLower == 'web' && !countWebInLimit) {
      return false;
    }
    
    // Desktop platforms (windows, macos, linux) seguem a mesma regra do web
    if (['windows', 'macos', 'linux'].contains(platformLower) && !countWebInLimit) {
      return false;
    }
    
    return true;
  }

  /// Verifica se a plataforma é mobile
  bool isMobilePlatform(String platform) {
    final platformLower = platform.toLowerCase();
    return platformLower == 'ios' || platformLower == 'android';
  }

  /// Verifica se a plataforma é web/desktop
  bool isWebOrDesktopPlatform(String platform) {
    final platformLower = platform.toLowerCase();
    return ['web', 'windows', 'macos', 'linux'].contains(platformLower);
  }

  /// Obtém o limite apropriado baseado no tipo de usuário
  int getLimit({required bool isPremium}) {
    return isPremium ? premiumMaxMobileDevices : maxMobileDevices;
  }

  /// Verifica se pode adicionar mais dispositivos
  bool canAddMoreDevices({
    required int currentMobileCount,
    required int currentWebCount,
    required bool isPremium,
    required String newDevicePlatform,
  }) {
    // Se é web/desktop e não conta no limite, sempre pode adicionar
    if (isWebOrDesktopPlatform(newDevicePlatform) && !countWebInLimit) {
      // Verifica limite específico de web se existir
      if (maxWebDevices != -1) {
        final webLimit = isPremium ? premiumMaxWebDevices : maxWebDevices;
        return webLimit == -1 || currentWebCount < webLimit;
      }
      return true;
    }

    // Para mobile, verifica o limite
    final mobileLimit = isPremium ? premiumMaxMobileDevices : maxMobileDevices;
    return currentMobileCount < mobileLimit;
  }

  /// Cria configuração padrão
  factory DeviceLimitConfig.defaultConfig() {
    return const DeviceLimitConfig();
  }

  /// Cria configuração para ambiente de desenvolvimento (mais permissiva)
  factory DeviceLimitConfig.development() {
    return const DeviceLimitConfig(
      maxMobileDevices: 10,
      maxWebDevices: -1,
      countWebInLimit: false,
      allowEmulators: true,
    );
  }

  /// Cria configuração restritiva (para apps que precisam de mais controle)
  factory DeviceLimitConfig.restrictive() {
    return const DeviceLimitConfig(
      maxMobileDevices: 2,
      maxWebDevices: 1,
      countWebInLimit: true,
      allowEmulators: false,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'maxMobileDevices': maxMobileDevices,
      'maxWebDevices': maxWebDevices,
      'countWebInLimit': countWebInLimit,
      'premiumMaxMobileDevices': premiumMaxMobileDevices,
      'premiumMaxWebDevices': premiumMaxWebDevices,
      'allowEmulators': allowEmulators,
      'inactivityDaysForCleanup': inactivityDaysForCleanup,
    };
  }

  /// Cria instância do JSON
  factory DeviceLimitConfig.fromJson(Map<String, dynamic> json) {
    return DeviceLimitConfig(
      maxMobileDevices: json['maxMobileDevices'] as int? ?? 3,
      maxWebDevices: json['maxWebDevices'] as int? ?? -1,
      countWebInLimit: json['countWebInLimit'] as bool? ?? false,
      premiumMaxMobileDevices: json['premiumMaxMobileDevices'] as int? ?? 10,
      premiumMaxWebDevices: json['premiumMaxWebDevices'] as int? ?? -1,
      allowEmulators: json['allowEmulators'] as bool? ?? true,
      inactivityDaysForCleanup: json['inactivityDaysForCleanup'] as int? ?? 90,
    );
  }

  DeviceLimitConfig copyWith({
    int? maxMobileDevices,
    int? maxWebDevices,
    bool? countWebInLimit,
    int? premiumMaxMobileDevices,
    int? premiumMaxWebDevices,
    bool? allowEmulators,
    int? inactivityDaysForCleanup,
  }) {
    return DeviceLimitConfig(
      maxMobileDevices: maxMobileDevices ?? this.maxMobileDevices,
      maxWebDevices: maxWebDevices ?? this.maxWebDevices,
      countWebInLimit: countWebInLimit ?? this.countWebInLimit,
      premiumMaxMobileDevices: premiumMaxMobileDevices ?? this.premiumMaxMobileDevices,
      premiumMaxWebDevices: premiumMaxWebDevices ?? this.premiumMaxWebDevices,
      allowEmulators: allowEmulators ?? this.allowEmulators,
      inactivityDaysForCleanup: inactivityDaysForCleanup ?? this.inactivityDaysForCleanup,
    );
  }

  @override
  String toString() => 'DeviceLimitConfig(mobile: $maxMobileDevices, web: $maxWebDevices, countWeb: $countWebInLimit)';
}

/// Resultado da verificação de limite de dispositivos
class DeviceLimitCheckResult {
  const DeviceLimitCheckResult({
    required this.canAddDevice,
    required this.currentMobileCount,
    required this.currentWebCount,
    required this.mobileLimit,
    required this.webLimit,
    this.message,
  });

  /// Se pode adicionar o dispositivo
  final bool canAddDevice;

  /// Contagem atual de dispositivos mobile
  final int currentMobileCount;

  /// Contagem atual de dispositivos web
  final int currentWebCount;

  /// Limite de dispositivos mobile
  final int mobileLimit;

  /// Limite de dispositivos web (-1 = ilimitado)
  final int webLimit;

  /// Mensagem explicativa
  final String? message;

  /// Slots restantes para mobile
  int get remainingMobileSlots => mobileLimit - currentMobileCount;

  /// Slots restantes para web (-1 se ilimitado)
  int get remainingWebSlots => webLimit == -1 ? -1 : webLimit - currentWebCount;

  /// Total de dispositivos
  int get totalDevices => currentMobileCount + currentWebCount;

  /// Cria resultado de sucesso
  factory DeviceLimitCheckResult.allowed({
    required int currentMobileCount,
    required int currentWebCount,
    required int mobileLimit,
    required int webLimit,
  }) {
    return DeviceLimitCheckResult(
      canAddDevice: true,
      currentMobileCount: currentMobileCount,
      currentWebCount: currentWebCount,
      mobileLimit: mobileLimit,
      webLimit: webLimit,
      message: 'Dispositivo pode ser adicionado',
    );
  }

  /// Cria resultado de limite excedido
  factory DeviceLimitCheckResult.limitExceeded({
    required int currentMobileCount,
    required int currentWebCount,
    required int mobileLimit,
    required int webLimit,
    String? customMessage,
  }) {
    return DeviceLimitCheckResult(
      canAddDevice: false,
      currentMobileCount: currentMobileCount,
      currentWebCount: currentWebCount,
      mobileLimit: mobileLimit,
      webLimit: webLimit,
      message: customMessage ?? 'Limite de $mobileLimit dispositivos móveis atingido. Remova um dispositivo para continuar.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canAddDevice': canAddDevice,
      'currentMobileCount': currentMobileCount,
      'currentWebCount': currentWebCount,
      'mobileLimit': mobileLimit,
      'webLimit': webLimit,
      'message': message,
    };
  }
}
