/// Configuração de autenticação específica por módulo/app no monorepo
/// Permite que cada projeto tenha suas próprias regras de autenticação
class ModuleAuthConfig {
  const ModuleAuthConfig({
    required this.moduleName,
    required this.homeRoute,
    required this.loginRoute,
    this.allowGuestMode = false,
    this.requireEmailVerification = false,
    this.allowSessionSharing = false,
    this.sessionTimeoutMinutes = 60,
    this.allowSocialLogin = true,
    this.customSettings = const {},
  });

  /// Nome identificador do módulo/app
  final String moduleName;
  
  /// Rota para home após login bem-sucedido
  final String homeRoute;
  
  /// Rota para tela de login
  final String loginRoute;
  
  /// Se permite acesso como convidado/anônimo
  final bool allowGuestMode;
  
  /// Se requer verificação de email obrigatória
  final bool requireEmailVerification;
  
  /// Se permite compartilhar sessão com outros módulos
  final bool allowSessionSharing;
  
  /// Timeout da sessão em minutos
  final int sessionTimeoutMinutes;
  
  /// Se permite login com redes sociais
  final bool allowSocialLogin;
  
  /// Configurações customizadas específicas do módulo
  final Map<String, dynamic> customSettings;

  /// Configuração para o app Plantis
  static const plantis = ModuleAuthConfig(
    moduleName: 'plantis',
    homeRoute: '/plantis/home',
    loginRoute: '/plantis/login',
    allowGuestMode: true,
    requireEmailVerification: false,
    allowSessionSharing: true,
    sessionTimeoutMinutes: 120, // 2 horas
    customSettings: {
      'theme': 'nature',
      'primaryColor': '#4CAF50',
      'allowOfflineMode': true,
    },
  );

  /// Configuração para o app ReceitaAgro
  static const receituagro = ModuleAuthConfig(
    moduleName: 'receituagro',
    homeRoute: '/receituagro/dashboard',
    loginRoute: '/receituagro/auth',
    allowGuestMode: false,
    requireEmailVerification: true,
    allowSessionSharing: true,
    sessionTimeoutMinutes: 60, // 1 hora (mais restritivo)
    customSettings: {
      'theme': 'professional',
      'primaryColor': '#2196F3',
      'requireTwoFactor': false,
    },
  );

  /// Mapa de todas as configurações disponíveis
  static const Map<String, ModuleAuthConfig> _configs = {
    'plantis': plantis,
    'receituagro': receituagro,
  };

  /// Obtém configuração por nome do módulo
  static ModuleAuthConfig? getConfig(String moduleName) {
    return _configs[moduleName];
  }

  /// Lista todos os módulos configurados
  static List<String> get availableModules => _configs.keys.toList();

  /// Verifica se um módulo está configurado
  static bool isModuleConfigured(String moduleName) {
    return _configs.containsKey(moduleName);
  }

  /// Verifica se dois módulos podem compartilhar sessão
  static bool canShareSession(String fromModule, String toModule) {
    final fromConfig = getConfig(fromModule);
    final toConfig = getConfig(toModule);
    
    if (fromConfig == null || toConfig == null) return false;
    
    return fromConfig.allowSessionSharing && 
           toConfig.allowSessionSharing &&
           _hasCompatibleSecurity(fromConfig, toConfig);
  }

  /// Verifica compatibilidade de segurança entre módulos
  static bool _hasCompatibleSecurity(
    ModuleAuthConfig from, 
    ModuleAuthConfig to
  ) {
    if (to.requireEmailVerification && !from.requireEmailVerification) {
      return false;
    }
    if (to.sessionTimeoutMinutes < from.sessionTimeoutMinutes) {
      return false;
    }
    
    return true;
  }

  /// Cria cópia com modificações
  ModuleAuthConfig copyWith({
    String? moduleName,
    String? homeRoute,
    String? loginRoute,
    bool? allowGuestMode,
    bool? requireEmailVerification,
    bool? allowSessionSharing,
    int? sessionTimeoutMinutes,
    bool? allowSocialLogin,
    Map<String, dynamic>? customSettings,
  }) {
    return ModuleAuthConfig(
      moduleName: moduleName ?? this.moduleName,
      homeRoute: homeRoute ?? this.homeRoute,
      loginRoute: loginRoute ?? this.loginRoute,
      allowGuestMode: allowGuestMode ?? this.allowGuestMode,
      requireEmailVerification: requireEmailVerification ?? this.requireEmailVerification,
      allowSessionSharing: allowSessionSharing ?? this.allowSessionSharing,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      allowSocialLogin: allowSocialLogin ?? this.allowSocialLogin,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'moduleName': moduleName,
      'homeRoute': homeRoute,
      'loginRoute': loginRoute,
      'allowGuestMode': allowGuestMode,
      'requireEmailVerification': requireEmailVerification,
      'allowSessionSharing': allowSessionSharing,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'allowSocialLogin': allowSocialLogin,
      'customSettings': customSettings,
    };
  }

  /// Cria instância do JSON
  factory ModuleAuthConfig.fromJson(Map<String, dynamic> json) {
    return ModuleAuthConfig(
      moduleName: json['moduleName'] as String,
      homeRoute: json['homeRoute'] as String,
      loginRoute: json['loginRoute'] as String,
      allowGuestMode: json['allowGuestMode'] as bool? ?? false,
      requireEmailVerification: json['requireEmailVerification'] as bool? ?? false,
      allowSessionSharing: json['allowSessionSharing'] as bool? ?? false,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] as int? ?? 60,
      allowSocialLogin: json['allowSocialLogin'] as bool? ?? true,
      customSettings: json['customSettings'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  String toString() {
    return 'ModuleAuthConfig(moduleName: $moduleName, homeRoute: $homeRoute)';
  }
}
