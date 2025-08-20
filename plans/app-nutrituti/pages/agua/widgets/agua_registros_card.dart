// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/beber_agua_model.dart';

class AguaRegistrosCard extends StatelessWidget {
  final RxList<BeberAgua> registros;
  final Function(BeberAgua) onTap;
  final Function(BeberAgua) onDelete;

  const AguaRegistrosCard({
    super.key,
    required this.registros,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Histórico de Registros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() => registros.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      final dataFormatada = DateTime.fromMillisecondsSinceEpoch(
                          registro.dataRegistro);

                      return ListTile(
                        dense: true,
                        title: Text(
                            'Quantidade: ${registro.quantidade.toInt()} ml'),
                        subtitle: Text(
                            'Data: ${dataFormatada.day}/${dataFormatada.month}/${dataFormatada.year} - ${dataFormatada.hour}:${dataFormatada.minute.toString().padLeft(2, '0')}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDelete(registro),
                        ),
                        onTap: () => onTap(registro),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum registro encontrado'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
