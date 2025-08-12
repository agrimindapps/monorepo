// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/page_header_widget.dart';
import '../../controllers/lista_medicamento_detalhes_controller.dart';
import '../../models/medicamento_detalhes_model.dart';

class MedicamentoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ListaMedicamentoDetalhesController controller;
  final MedicamentoDetalhes? medicamento;

  const MedicamentoAppBar({
    super.key,
    required this.controller,
    required this.medicamento,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: PageHeaderWidget(
          title: medicamento != null
              ? 'Detalhes: ${medicamento!.nome}'
              : 'Detalhes do Medicamento',
          subtitle: 'Informações completas do medicamento',
          icon: Icons.medication,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.text_decrease),
              tooltip: 'Diminuir texto',
              onPressed: controller.diminuirTexto,
            ),
            IconButton(
              icon: const Icon(Icons.text_increase),
              tooltip: 'Aumentar texto',
              onPressed: controller.aumentarTexto,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartilhar',
              onPressed: () => controller.compartilhar(context),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'print') {
                  controller.imprimir(context);
                } else if (value == 'save') {
                  controller.salvarComoFavorito(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: ListTile(
                    leading: Icon(Icons.print),
                    title: Text('Imprimir'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'save',
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('Salvar como favorito'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
