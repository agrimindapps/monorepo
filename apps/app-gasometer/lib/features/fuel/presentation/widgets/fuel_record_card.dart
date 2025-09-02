import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/fuel_record_entity.dart';

/// Reusable fuel record card widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying a fuel record
/// Follows OCP: Open for extension via callback functions
class FuelRecordCard extends StatelessWidget {
  const FuelRecordCard({
    super.key,
    required this.record,
    required this.vehicleName,
    this.onTap,
    this.onLongPress,
  });

  final FuelRecordEntity record;
  final String vehicleName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final date = record.data;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final semanticLabel = 'Abastecimento $vehicleName em $formattedDate, ${record.litros.toStringAsFixed(1)} litros, R\$ ${record.valorTotal.toStringAsFixed(2)}${record.tanqueCheio ? ', tanque cheio' : ''}';

    return SemanticCard(
      semanticLabel: semanticLabel,
      semanticHint: 'Toque para ver detalhes completos, mantenha pressionado para editar ou excluir',
      onTap: onTap,
      onLongPress: onLongPress,
      margin: EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
      child: Column(
        children: [
          _buildRecordHeader(context, vehicleName, formattedDate),
          _buildRecordDivider(context),
          _buildRecordStats(context),
        ],
      ),
    );
  }

  Widget _buildRecordHeader(BuildContext context, String vehicleName, String formattedDate) {
    return Row(
      children: [
        _buildRecordIcon(context),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SemanticText.heading(
                    vehicleName,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeLg,
                      fontWeight: GasometerDesignTokens.fontWeightBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SemanticText.label(
                    formattedDate,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeMd,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: GasometerDesignTokens.opacitySecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              SemanticText.subtitle(
                record.nomePosto ?? 'Posto não informado',
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeMd,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: GasometerDesignTokens.opacitySecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordIcon(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusLg),
      ),
      child: Icon(
        Icons.local_gas_station,
        color: Theme.of(context).colorScheme.primary,
        size: GasometerDesignTokens.iconSizeMd,
      ),
    );
  }

  Widget _buildRecordDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GasometerDesignTokens.spacingMd),
      child: Divider(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),
    );
  }

  Widget _buildRecordStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            context,
            Icons.water_drop,
            '${record.litros.toStringAsFixed(1)} L',
            'Litros',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            context,
            Icons.attach_money,
            'R\$ ${record.valorTotal.toStringAsFixed(2)}',
            'Total',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            context,
            Icons.trending_up,
            'R\$ ${(record.valorTotal / record.litros).toStringAsFixed(2)}',
            'Preço/L',
          ),
        ),
        if (record.tanqueCheio) _buildFullTankBadge(context),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: GasometerDesignTokens.iconSizeSm,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: GasometerDesignTokens.opacitySecondary,
              ),
            ),
            const SizedBox(width: 4),
            SemanticText(
              value,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeMd,
                fontWeight: GasometerDesignTokens.fontWeightSemiBold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        SemanticText.label(
          label,
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeXs,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacitySecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullTankBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.opacity,
            size: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Tanque Cheio',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}