// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../constants/atualizacao_const.dart';
import '../../../constants/config_const.dart';
import '../../atualizacoes_page.dart';

class ConfigModel {
  String? _errorMessage;
  bool _isInitialized = false;

  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  String get appVersion => atualizacoesText[0]['versao']!;
  String get appName => appEmailContato.split('@').first;
  String get contactEmail => appEmailContato;

  List<ConfigSection> get configSections => [
        ConfigSection(
          title: 'Versão',
          items: [
            ConfigItem(
              icon: Icons.update,
              title: appVersion,
              subtitle: 'Toque para mais detalhes',
              type: ConfigItemType.version,
            ),
          ],
        ),
        ConfigSection(
          title: 'Contato',
          items: [
            ConfigItem(
              icon: Icons.email_outlined,
              title: 'E-mail',
              subtitle: 'Entre em contato conosco',
              type: ConfigItemType.email,
            ),
            ConfigItem(
              icon: Icons.facebook_outlined,
              title: 'Facebook',
              subtitle: 'Siga nossa página',
              type: ConfigItemType.facebook,
              data: {'host': 'm.facebook.com', 'path': 'agrimind.br'},
            ),
            ConfigItem(
              icon: Icons.camera_alt_outlined,
              title: 'Instagram',
              subtitle: 'Veja nossos posts',
              type: ConfigItemType.instagram,
              data: {'host': 'www.instagram.com', 'path': 'agrimind.br'},
            ),
          ],
        ),
        ConfigSection(
          title: 'Informações',
          items: [
            ConfigItem(
              icon: Icons.info_outline,
              title: 'Sobre',
              subtitle: 'Informações do aplicativo',
              type: ConfigItemType.navigation,
              data: {'route': '/sobre'},
            ),
            ConfigItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidade',
              subtitle: 'Termos de privacidade',
              type: ConfigItemType.navigation,
              data: {'route': '/privacidade'},
            ),
            ConfigItem(
              icon: Icons.description_outlined,
              title: 'Termos de Uso',
              subtitle: 'Condições de uso',
              type: ConfigItemType.navigation,
              data: {'route': '/termos'},
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

  void navigateToUpdates(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AtualizacoesAppPage(),
      ),
    );
  }

  void dispose() {
    _errorMessage = null;
    _isInitialized = false;
  }
}

class ConfigSection {
  final String title;
  final List<ConfigItem> items;

  ConfigSection({
    required this.title,
    required this.items,
  });
}

class ConfigItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final ConfigItemType type;
  final Map<String, dynamic>? data;

  ConfigItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
    this.data,
  });
}

enum ConfigItemType {
  version,
  theme,
  email,
  facebook,
  instagram,
  navigation,
  exit,
  simulateData,
  removeData,
}
