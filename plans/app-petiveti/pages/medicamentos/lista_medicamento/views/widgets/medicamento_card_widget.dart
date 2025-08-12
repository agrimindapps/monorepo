// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/lista_medicamento_controller.dart';
import '../../models/medicamento_model.dart';
import '../../utils/medicamento_lista_helpers.dart';

class MedicamentoCardWidget extends StatelessWidget {
  final Medicamento medicamento;
  final ListaMedicamentoController controller;

  const MedicamentoCardWidget({
    super.key,
    required this.medicamento,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = controller.isFavorito(medicamento.nome);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.navigateToDetalhes(context, medicamento),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedicamentoListaHelpers.getTipoColor(medicamento.tipo),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MedicamentoListaHelpers.getTipoIcon(medicamento.tipo),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'medicamento_${medicamento.nome}',
                      child: Text(
                        medicamento.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicamento.tipo,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medicamento.indicacao,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: () => controller.toggleFavorito(medicamento.nome),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
