// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../models/pluviometros_models.dart';

class PluviometroCard extends StatelessWidget {
  final Pluviometro pluviometro;
  final Function(String action, Pluviometro pluviometro) onMenuAction;
  final Function(Pluviometro pluviometro) onTap;

  const PluviometroCard({
    super.key,
    required this.pluviometro,
    required this.onMenuAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(pluviometro),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ShadcnStyle.textColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pluviometro.descricao,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacidade: ${pluviometro.quantidade} mm',
                      style: TextStyle(
                        color: ShadcnStyle.labelColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onMenuAction('edit', pluviometro),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Editar',
                    color: ShadcnStyle.labelColor,
                  ),
                  IconButton(
                    onPressed: () => onMenuAction('delete', pluviometro),
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Excluir',
                    color: ShadcnStyle.labelColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
