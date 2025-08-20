// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/peso_model.dart';

class RegistrosCardWidget extends StatelessWidget {
  final List<PesoModel> registros;
  final String Function(int) formatDateTime;
  final void Function(PesoModel) onEdit;
  final void Function(PesoModel) onDelete;

  const RegistrosCardWidget({
    super.key,
    required this.registros,
    required this.formatDateTime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Registros',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            registros.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final peso = registros[index];
                      return ListTile(
                        dense: true,
                        title:
                            Text('Data: ${formatDateTime(peso.dataRegistro)}'),
                        subtitle: Text('Peso: ${peso.peso} kg'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => onEdit(peso),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => onDelete(peso),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum registro de peso encontrado'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
