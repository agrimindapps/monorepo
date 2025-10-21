// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../controllers/agua_controller.dart';
import '../models/beber_agua_model.dart';

class AguaRegistrosCard extends ConsumerWidget {
  const AguaRegistrosCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aguaAsync = ref.watch(aguaNotifierProvider);

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
            aguaAsync.when(
              data: (state) {
                final registros = state.registros;

                if (registros.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum registro encontrado'),
                    ),
                  );
                }

                return ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 1),
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
                        onPressed: () => _deleteRegistro(context, ref, registro),
                      ),
                      onTap: () => _showRegistroDialog(context, ref, registro),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Erro ao carregar registros'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRegistro(BuildContext context, WidgetRef ref, BeberAgua registro) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(aguaNotifierProvider.notifier).deleteRegistro(registro);
    }
  }

  Future<void> _showRegistroDialog(BuildContext context, WidgetRef ref, BeberAgua registro) async {
    // This method will be implemented by the parent widget
    // For now, just a placeholder to show the tap is handled
  }
}
