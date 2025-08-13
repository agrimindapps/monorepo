// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controller/detalhes_defensivos_controller.dart';
import '../../widgets/classificacao_card_widget.dart';
import '../../widgets/info_card_widget.dart';

class InformacoesTab extends StatefulWidget {
  final DetalhesDefensivosController controller;

  const InformacoesTab({
    super.key,
    required this.controller,
  });

  @override
  State<InformacoesTab> createState() => _InformacoesTabState();
}

class _InformacoesTabState extends State<InformacoesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (widget.controller.defensivo.value.caracteristicas.isEmpty) {
        return const Center(
          key: ValueKey('no_info'),
          child: Text('Não há informações disponíveis'),
        );
      }

      final caracteristicas = widget.controller.defensivo.value.caracteristicas;

      return Column(
        key: const ValueKey('info_content'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCardWidget(
            key: const ValueKey('info_card'),
            caracteristicas: caracteristicas,
          ),
          ClassificacaoCardWidget(
            key: const ValueKey('classification_card'),
            caracteristicas: caracteristicas,
          ),
        ],
      );
    });
  }

  Widget _buildInfoSectionHeader(
      String title, IconData icon, BuildContext context) {
    final isDark = widget.controller.isDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.green.shade300 : Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
