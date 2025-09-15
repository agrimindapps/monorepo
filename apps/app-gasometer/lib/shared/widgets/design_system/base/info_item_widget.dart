import 'package:flutter/material.dart';
import '../tokens/list_item_design_tokens.dart';

/// Tipos de layout para info items
enum InfoItemLayout {
  /// Vertical: label acima do valor
  vertical,
  /// Horizontal: label ao lado do valor
  horizontal,
  /// Inline: valor em linha com ícone
  inline,
}

/// Widget reutilizável para exibir informações formatadas
/// 
/// Usado para mostrar dados como "Combustível: Gasolina", "Valor: R$ 45,80"
/// de forma consistente em todos os list items.
class InfoItemWidget extends StatelessWidget {
  /// Texto do rótulo/label
  final String label;
  
  /// Valor a ser exibido
  final String value;
  
  /// Ícone opcional
  final IconData? icon;
  
  /// Cor customizada para o valor
  final Color? valueColor;
  
  /// Cor customizada para o ícone
  final Color? iconColor;
  
  /// Estilo customizado para o valor
  final TextStyle? customValueStyle;
  
  /// Estilo customizado para o label
  final TextStyle? customLabelStyle;
  
  /// Layout do componente
  final InfoItemLayout layout;
  
  /// Se deve truncar texto longo
  final bool truncateText;
  
  /// Máximo de linhas para o valor
  final int? maxLines;

  const InfoItemWidget({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.iconColor,
    this.customValueStyle,
    this.customLabelStyle,
    this.layout = InfoItemLayout.vertical,
    this.truncateText = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case InfoItemLayout.vertical:
        return _buildVerticalLayout(context);
      case InfoItemLayout.horizontal:
        return _buildHorizontalLayout(context);
      case InfoItemLayout.inline:
        return _buildInlineLayout(context);
    }
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context),
        const SizedBox(height: 2),
        Row(
          children: [
            if (icon != null) ...[
              _buildIcon(),
              const SizedBox(width: 4),
            ],
            Expanded(child: _buildValue(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          _buildIcon(),
          const SizedBox(width: 4),
        ],
        _buildLabel(context),
        const SizedBox(width: 8),
        Expanded(child: _buildValue(context)),
      ],
    );
  }

  Widget _buildInlineLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          _buildIcon(),
          const SizedBox(width: 4),
        ],
        _buildValue(context),
      ],
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon,
      size: 14,
      color: iconColor ?? ListItemDesignTokens.infoLabelStyle.color,
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Text(
      label,
      style: customLabelStyle ?? ListItemDesignTokens.infoLabelStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValue(BuildContext context) {
    final effectiveStyle = customValueStyle ?? 
        ListItemDesignTokens.infoValueStyle.copyWith(
          color: valueColor ?? ListItemDesignTokens.infoValueStyle.color,
        );

    return Text(
      value,
      style: effectiveStyle,
      maxLines: maxLines ?? (truncateText ? 1 : null),
      overflow: truncateText ? TextOverflow.ellipsis : null,
      textAlign: layout == InfoItemLayout.horizontal ? TextAlign.end : TextAlign.start,
    );
  }
  
  /// Factory para criar item de combustível
  factory InfoItemWidget.fuel({
    required String fuelType,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Combustível',
      value: fuelType,
      icon: Icons.local_gas_station,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item de valor monetário
  factory InfoItemWidget.money({
    required double amount,
    String? label,
    Color? color,
  }) {
    return InfoItemWidget(
      label: label ?? 'Valor',
      value: 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
      icon: Icons.attach_money,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item de odômetro
  factory InfoItemWidget.odometer({
    required double kilometers,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Odômetro',
      value: '${kilometers.toStringAsFixed(0)} km',
      icon: Icons.speed,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item de volume
  factory InfoItemWidget.volume({
    required double liters,
    String? unit,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Volume',
      value: '${liters.toStringAsFixed(1)} ${unit ?? 'L'}',
      icon: Icons.water_drop,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item de localização
  factory InfoItemWidget.location({
    required String location,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Local',
      value: location,
      icon: Icons.location_on,
      valueColor: color,
      layout: InfoItemLayout.vertical,
      truncateText: true,
    );
  }
  
  /// Factory para criar item de categoria
  factory InfoItemWidget.category({
    required String category,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Categoria',
      value: category,
      icon: Icons.category,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item de eficiência
  factory InfoItemWidget.efficiency({
    required double kmPerLiter,
    Color? color,
  }) {
    return InfoItemWidget(
      label: 'Eficiência',
      value: '${kmPerLiter.toStringAsFixed(1)} km/L',
      icon: Icons.trending_up,
      valueColor: color,
      layout: InfoItemLayout.vertical,
    );
  }
  
  /// Factory para criar item customizado inline
  factory InfoItemWidget.inline({
    required String value,
    IconData? icon,
    Color? color,
  }) {
    return InfoItemWidget(
      label: '',
      value: value,
      icon: icon,
      valueColor: color,
      layout: InfoItemLayout.inline,
    );
  }
}