// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../widgets/bottom_navigator_widget.dart';
import '../../widgets/modern_header_widget.dart';
import 'desenvolvimento_section.dart';
import 'publicidade_section.dart';
import 'site_access_section.dart';
import 'sobre_section.dart';
import 'speech_to_text_section.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigState();
}

class _ConfigState extends State<ConfigPage> {
  // Usar o ThemeController via GetX
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (!GetPlatform.isWeb) const PublicidadeSection(),
                          if (!GetPlatform.isWeb) const SiteAccessSection(),
                          const SpeechToTextSection(),
                          const DesenvolvimentoSection(),
                          const SobreSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigator(
        overrideIndex: 4, // Outros/Config
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Obx(() => ModernHeaderWidget(
      title: 'Opções',
      subtitle: 'Configurações e personalização',
      leftIcon: FontAwesome.gear_solid,
      isDark: _themeController.isDark.value,
      showBackButton: false,
      showActions: true,
      rightIcon: _themeController.isDark.value ? FontAwesome.sun : FontAwesome.moon,
      onRightIconPressed: _themeController.toggleTheme,
    ));
  }
}
