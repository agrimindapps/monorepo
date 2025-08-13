// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../controller/comentarios_controller.dart';

class SearchCommentsWidget extends StatelessWidget {
  final ComentariosController controller;

  const SearchCommentsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDark.value;
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 20.0,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Verifica se o controller ainda é válido
                    if (controller.isClosed ||
                        controller.isControllerDisposed) {
                      return const SizedBox.shrink();
                    }

                    return TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar comentários...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  // Verifica se o controller ainda é válido
                  if (controller.isClosed || controller.isControllerDisposed) {
                    return const SizedBox(width: 36);
                  }

                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: () {
                            if (!controller.isClosed &&
                                !controller.isControllerDisposed) {
                              controller.searchController.clear();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              size: 20.0,
                            ),
                          ),
                        );
                      }
                      return const SizedBox(width: 36);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
