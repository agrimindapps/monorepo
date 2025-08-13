// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../widgets/section_title_widget.dart';

class PersonalizacaoSection extends StatelessWidget {
  final ThemeController themeController;

  const PersonalizacaoSection({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Personalização',
          icon: FontAwesome.palette_solid,
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // Usar Obx para tornar o ListTile reativo ao tema
            child: Obx(() => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: !themeController.isDark.value
                        ? Colors.grey.shade200
                        : Colors.grey.shade800,
                    child: Icon(
                      !themeController.isDark.value
                          ? FontAwesome.moon
                          : FontAwesome.sun,
                      size: 18,
                      color: !themeController.isDark.value
                          ? Colors.grey.shade900
                          : Colors.amber.shade600,
                    ),
                  ),
                  title: const Text('Tema'),
                  subtitle: Text(
                    !themeController.isDark.value
                        ? 'Modo claro ativado'
                        : 'Modo escuro ativado',
                  ),
                  trailing: Switch(
                    value: themeController.isDark.value,
                    activeColor: Colors.green.shade700,
                    onChanged: (bool value) {
                      themeController.toggleTheme();
                    },
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    themeController.toggleTheme();
                  },
                )),
          ),
        ),
      ],
    );
  }
}
