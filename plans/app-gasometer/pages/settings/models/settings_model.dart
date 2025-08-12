// Flutter imports:
import 'package:flutter/material.dart';

class SettingsModel {
  String? _errorMessage;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'pt-BR';
  String _selectedCurrency = 'BRL';
  bool _isUserLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _userPhotoUrl;
  bool _hasActiveSubscription = false;
  String _subscriptionType = '';
  String _subscriptionPrice = '';
  double _subscriptionProgress = 0.0;
  String _daysRemaining = '';
  DateTime? _renewalDate;

  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String get selectedLanguage => _selectedLanguage;
  String get selectedCurrency => _selectedCurrency;
  bool get isUserLoggedIn => _isUserLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get hasActiveSubscription => _hasActiveSubscription;
  String get subscriptionType => _subscriptionType;
  String get subscriptionPrice => _subscriptionPrice;
  double get subscriptionProgress => _subscriptionProgress;
  String get daysRemaining => _daysRemaining;
  DateTime? get renewalDate => _renewalDate;

  String get appVersion => '1.0.0';
  String get appName => 'GasOMeter';
  String get contactEmail => 'contato@gasometer.com';

  List<PremiumFeature> get premiumFeatures => [
        PremiumFeature(
          icon: Icons.analytics_outlined,
          title: 'Relatórios Avançados',
          description: 'Análises detalhadas de consumo e economia',
        ),
        PremiumFeature(
          icon: Icons.cloud_sync_outlined,
          title: 'Sincronização na Nuvem',
          description: 'Backup automático e acesso em múltiplos dispositivos',
        ),
        PremiumFeature(
          icon: Icons.notifications_none_outlined,
          title: 'Alertas Inteligentes',
          description: 'Notificações personalizadas sobre abastecimento',
        ),
        PremiumFeature(
          icon: Icons.block_outlined,
          title: 'Sem Anúncios',
          description: 'Experiência premium sem interrupções',
        ),
      ];

  List<SettingsSection> get settingsSections => [
        SettingsSection(
          title: 'Desenvolvimento',
          items: [
            SettingsItem(
              icon: Icons.science_outlined,
              title: 'Simular Dados',
              subtitle: 'Inserir dados de teste (2 veículos, 14 meses)',
              type: SettingsItemType.simulateData,
            ),
            SettingsItem(
              icon: Icons.delete_forever_outlined,
              title: 'Remover Dados',
              subtitle: 'Limpar todo o banco de dados local',
              type: SettingsItemType.removeData,
            ),
            SettingsItem(
              icon: Icons.storage_outlined,
              title: 'Inspetor de Banco',
              subtitle: 'Visualizar dados do Hive e SharedPreferences',
              type: SettingsItemType.databaseInspector,
            ),
          ],
        ),
        SettingsSection(
          title: 'Suporte',
          items: [
            SettingsItem(
              icon: Icons.help_outline,
              title: 'Central de Ajuda',
              subtitle: 'Perguntas frequentes e tutoriais',
              type: SettingsItemType.help,
            ),
            SettingsItem(
              icon: Icons.email_outlined,
              title: 'Contato',
              subtitle: 'Entre em contato conosco',
              type: SettingsItemType.contact,
            ),
            SettingsItem(
              icon: Icons.bug_report_outlined,
              title: 'Reportar Bug',
              subtitle: 'Relatar problemas ou sugestões',
              type: SettingsItemType.bugReport,
            ),
            SettingsItem(
              icon: Icons.star_rate_outlined,
              title: 'Avaliar o App',
              subtitle: 'Avalie nossa experiência na loja',
              type: SettingsItemType.appRating,
            ),
          ],
        ),
        SettingsSection(
          title: 'Informações',
          items: [
            SettingsItem(
              icon: Icons.info_outline,
              title: 'Sobre o App',
              subtitle: 'Versão $appVersion',
              type: SettingsItemType.about,
            ),
          ],
        ),
      ];

  void initialize() {
    try {
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao inicializar configurações: $e';
      _isInitialized = false;
    }
  }

  void updateNotifications(bool enabled) {
    _notificationsEnabled = enabled;
  }

  void updateAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
  }

  void updateLanguage(String language) {
    _selectedLanguage = language;
  }

  void updateCurrency(String currency) {
    _selectedCurrency = currency;
  }

  void setError(String? error) {
    _errorMessage = error;
  }

  void setUserLoggedIn(bool loggedIn,
      {String? email, String? name, String? photoUrl}) {
    _isUserLoggedIn = loggedIn;
    _userEmail = email;
    _userName = name;
    _userPhotoUrl = photoUrl;
  }

  void logout() {
    _isUserLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _userPhotoUrl = null;
  }

  void setSubscriptionInfo({
    required bool hasActive,
    String type = '',
    String price = '',
    double progress = 0.0,
    String days = '',
    DateTime? renewal,
  }) {
    _hasActiveSubscription = hasActive;
    _subscriptionType = type;
    _subscriptionPrice = price;
    _subscriptionProgress = progress;
    _daysRemaining = days;
    _renewalDate = renewal;
  }

  String get userInitials {
    if (_userName?.isNotEmpty ?? false) {
      final parts = _userName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return _userName![0].toUpperCase();
    }
    if (_userEmail?.isNotEmpty ?? false) {
      return _userEmail![0].toUpperCase();
    }
    return 'U';
  }

  void dispose() {
    _errorMessage = null;
    _isInitialized = false;
    _isUserLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _userPhotoUrl = null;
  }
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class SettingsSection {
  final String title;
  final List<SettingsItem> items;

  SettingsSection({
    required this.title,
    required this.items,
  });
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final SettingsItemType type;
  final Map<String, dynamic>? data;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    this.data,
  });
}

enum SettingsItemType {
  navigation,
  theme,
  language,
  currency,
  notifications,
  emailNotifications,
  autoSync,
  backup,
  export,
  subscription,
  restore,
  help,
  contact,
  bugReport,
  about,
  privacy,
  terms,
  logout,
  login,
  sync,
  deleteAccount,
  simulateData,
  removeData,
  databaseInspector,
  appRating,
}
