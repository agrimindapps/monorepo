// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../widgets/gasometer_header_widget.dart';
import '../controller/config_controller.dart';
import '../models/config_model.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
      init: ConfigController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ThemeManager().isDark.value
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Header fixo
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: const GasometerHeaderWidget(
                      title: 'Sobre o App',
                      subtitle: 'Informações e configurações',
                      icon: Icons.info_outline,
                      showBackButton: true,
                    ),
                  ),
                ),

                // Conteúdo com scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: 1120,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildLogo(),
                              ...controller.model.configSections.map(
                                (section) =>
                                    _buildSection(context, controller, section),
                              ),
                              const SizedBox(height: 16),
                              _buildCopyright(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Image.asset(
        'lib/core/assets/logo_menu.png',
        height: 60,
      ),
    );
  }

  Widget _buildSection(BuildContext context, ConfigController controller,
      ConfigSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(section.title),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: ThemeManager().isDark.value
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          color: ThemeManager().isDark.value
              ? const Color(0xFF16213E)
              : Colors.white,
          child: Column(
            children: section.items
                .map((item) => _buildListItem(context, controller, item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ThemeManager().isDark.value
              ? Colors.grey.shade300
              : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, ConfigController controller, ConfigItem item) {
    return ListTile(
      leading: _buildItemIcon(item),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      trailing: _buildItemTrailing(item),
      onTap: () => _handleItemTap(context, controller, item),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildItemIcon(ConfigItem item) {
    return Icon(item.icon);
  }

  Widget? _buildItemTrailing(ConfigItem item) {
    switch (item.type) {
      case ConfigItemType.theme:
        return Icon(
          !ThemeManager().isDark.value ? FontAwesome.moon : FontAwesome.sun,
          size: 18,
          color: !ThemeManager().isDark.value
              ? Colors.grey.shade900
              : Colors.amber.shade600,
        );
      default:
        return null;
    }
  }

  void _handleItemTap(
      BuildContext context, ConfigController controller, ConfigItem item) {
    switch (item.type) {
      case ConfigItemType.version:
        controller.navigateToUpdates(context);
        break;
      case ConfigItemType.theme:
        controller.toggleTheme();
        break;
      case ConfigItemType.email:
        controller.openEmail(context);
        break;
      case ConfigItemType.facebook:
        final data = item.data!;
        controller.openExternalLink(data['host'], data['path']);
        break;
      case ConfigItemType.instagram:
        final data = item.data!;
        controller.openExternalLink(data['host'], data['path']);
        break;
      case ConfigItemType.navigation:
        final data = item.data!;
        controller.navigateToRoute(context, data['route']);
        break;
      case ConfigItemType.exit:
        controller.exitApp(context);
        break;
      case ConfigItemType.simulateData:
        controller.simulateTestData(context);
        break;
      case ConfigItemType.removeData:
        controller.removeAllData(context);
        break;
    }
  }

  Widget _buildCopyright() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Copyright @ Agrimind',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Todos os Direitos Reservados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
