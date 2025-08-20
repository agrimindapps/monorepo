// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';

/// Modelo de dados para um item de estatística
/// Representa os dados necessários para exibir uma estatística individual
class EstatisticaItemModel {
  final String label;
  final String valor;
  final IconData icon;

  const EstatisticaItemModel({
    required this.label,
    required this.valor,
    required this.icon,
  });

  static List<EstatisticaItemModel> fromPluviometriaMap(
          Map<String, dynamic> estatisticasMap) =>
      [
        EstatisticaItemModel(
          label: 'Total',
          valor: '${estatisticasMap['total'].toStringAsFixed(1)} mm',
          icon: Icons.water_drop,
        ),
        EstatisticaItemModel(
          label: 'Média',
          valor: '${estatisticasMap['media'].toStringAsFixed(1)} mm',
          icon: Icons.water,
        ),
        EstatisticaItemModel(
          label: 'Máximo',
          valor: '${estatisticasMap['maximo'].toStringAsFixed(1)} mm',
          icon: Icons.arrow_upward,
        ),
        EstatisticaItemModel(
          label: 'Dias com Chuva',
          valor: '${estatisticasMap['diasChuva']}',
          icon: Icons.calendar_today,
        ),
      ];
}

/// Widget para exibir um item de estatística
/// Renderiza um ícone, valor e label de forma visualmente organizada
class EstatisticaItemWidget extends StatelessWidget {
  final EstatisticaItemModel item;
  final Color cor;

  const EstatisticaItemWidget({
    super.key,
    required this.item,
    this.cor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: cor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          item.valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ShadcnStyle.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            color: ShadcnStyle.labelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
