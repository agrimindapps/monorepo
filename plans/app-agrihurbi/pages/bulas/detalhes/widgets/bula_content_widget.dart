// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/bulas_detalhes_controller.dart';
import 'bula_info_section_widget.dart';

class BulaContentWidget extends StatelessWidget {
  final BulasDetalhesController controller;

  const BulaContentWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bula = controller.bula;
    if (bula == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (bula.imagens != null && bula.imagens!.isNotEmpty)
              Card(
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Image.network(
                    bula.imagens![0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BulaInfoSectionWidget(
                      label: 'Medicamento',
                      content: bula.descricao,
                    ),
                    BulaInfoSectionWidget(
                      label: 'Fabricante',
                      content: bula.fabricante ?? 'Não informado',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
