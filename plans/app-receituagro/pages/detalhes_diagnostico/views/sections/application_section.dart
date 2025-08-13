// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../controller/detalhes_diagnostico_controller.dart';

class ApplicationSection extends StatelessWidget {
  final DetalhesDiagnosticoController controller;
  
  const ApplicationSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        final diagnostico = controller.diagnostico.value;
        final isDark = themeController.isDark.value;
        
        return Container(
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 20),
          decoration: _cardDecoration(context, isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: _createTertiaryGradient(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            FontAwesome.file_solid,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Modo de Aplicação',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    _buildTtsButton(diagnostico.tecnologia),
                  ],
                ),
              ),

              // Conteúdo do card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  diagnostico.tecnologia.isNotEmpty
                      ? _replaceHtmlBrTags(diagnostico.tecnologia).trim()
                      : 'Não há informações',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context, bool isDark) {
    
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  LinearGradient _createTertiaryGradient() {
    return const LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildTtsButton(String content) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Obx(() {
        final isSpeaking = controller.isTtsSpeaking.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSpeaking
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSpeaking
                    ? FontAwesome.pause_solid
                    : FontAwesome.volume_high_solid,
                key: ValueKey(isSpeaking),
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: () {
              controller.toggleTts(content);
            },
            tooltip: isSpeaking ? 'Pausar narração' : 'Ouvir texto',
          ),
        );
      }),
    );
  }

  String _replaceHtmlBrTags(String text) {
    return text
        .replaceAll('<br />', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n');
  }
}
