// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/page_header_widget.dart';
import '../../controllers/lista_medicamento_controller.dart';

class MedicamentoAppBarWidget extends StatelessWidget {
  final ListaMedicamentoController controller;

  const MedicamentoAppBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageHeaderWidget(
      title: 'Medicamentos',
      subtitle: 'Consulte informações sobre medicamentos veterinários',
      icon: Icons.medication,
      showBackButton: false,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'favoritos') {
              controller.navigateToFavoritos(context);
            } else if (value == 'recentes') {
              controller.navigateToRecentes(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'favoritos',
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('Favoritos'),
              ),
            ),
            const PopupMenuItem(
              value: 'recentes',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Recentes'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
