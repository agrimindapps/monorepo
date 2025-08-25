// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/todoist_colors.dart';
import '../models/background_theme.dart';
import '../providers/theme_controller.dart';

class ThemeSelectorPanel extends StatelessWidget {
  const ThemeSelectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: TodoistColors.surfaceColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child: Obx(() {
                  final themeController = Get.find<TodoistThemeController>();
                  return _buildThemeGrid(context, themeController);
                }),
              ),
            ],
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.palette_outlined,
            color: TodoistColors.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Personalizar Fundo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TodoistColors.textColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TodoistColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: TodoistColors.subtitleColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, TodoistThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolha uma cor de fundo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TodoistColors.subtitleColor,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: themeController.availableThemes.length,
              itemBuilder: (context, index) {
                final theme = themeController.availableThemes[index];
                final isSelected = themeController.isSelected(theme);

                return _buildThemeCard(context, theme, isSelected,
                    () => themeController.changeTheme(theme));
              },
            ),
          ),

          const SizedBox(height: 16),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => themeController.resetToDefault(),
              icon: Icon(
                Icons.refresh,
                size: 18,
                color: TodoistColors.subtitleColor,
              ),
              label: Text(
                'Voltar ao Padrão',
                style: TextStyle(
                  color: TodoistColors.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: TodoistColors.borderColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    BackgroundTheme theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        // Fechar o painel após selecionar
        Navigator.of(context).pop();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : const Color(0xFFE1E1E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview do tema
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.previewColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: Stack(
                  children: [
                    // Solid color preview
                    Container(
                      decoration: BoxDecoration(
                        color: theme.previewColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                    ),

                    // Mock task preview
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 8,
                            width: double.infinity * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selected indicator
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Nome do tema
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TodoistColors.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    theme.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.primaryColor
                          : TodoistColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
