// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../controller/detalhes_diagnostico_controller.dart';

class ImageSection extends StatelessWidget {
  final DetalhesDiagnosticoController controller;

  const ImageSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        final diagnostico = controller.diagnostico.value;
        final isDark = themeController.isDark.value;

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Card(
            elevation: 0,
            color: isDark
                ? const Color(0xFF1E1E22)
                : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.white,
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/imagens/bigsize/${diagnostico.nomeCientifico}.jpg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            color: isDark
                                ? const Color(0xFF2A2A2E)
                                : Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          diagnostico.nomePraga,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${diagnostico.nomeDefensivo} - ${diagnostico.cultura}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
