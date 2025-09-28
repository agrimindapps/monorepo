import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../tokens/list_item_design_tokens.dart';
import 'date_display_widget.dart';
import 'info_item_widget.dart';
import 'type_badge_widget.dart';

/// Widget padronizado para list items em todo o app
/// 
/// Segue o padrão estabelecido pelo OdometerListItem, garantindo
/// consistência visual entre todos os tipos de list items.
class StandardListItemCard extends StatelessWidget {

  const StandardListItemCard({
    super.key,
    required this.date,
    required this.infoItems,
    this.badge,
    this.additionalBadges,
    this.actionWidget,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.dateStyle = DateDisplayStyle.compact,
    this.showRelativeTime = false,
    this.highlightColor,
    this.showShadow = true,
    this.compact = false,
  });
  
  /// Factory para criar list item de combustível
  factory StandardListItemCard.fuel({
    required DateTime date,
    required String fuelType,
    required double liters,
    required double amount,
    required double odometer,
    String? location,
    bool fullTank = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
    Widget? actionWidget,
  }) {
    final infoItems = <InfoItemWidget>[
      InfoItemWidget.fuel(fuelType: fuelType),
      InfoItemWidget.volume(liters: liters),
      InfoItemWidget.money(amount: amount),
      InfoItemWidget.odometer(kilometers: odometer),
      if (location != null) InfoItemWidget.location(location: location),
    ];

    final badges = <TypeBadgeWidget>[
      TypeBadgeWidget.fuel(fuelType: fuelType),
      if (fullTank) 
        TypeBadgeWidget.status(
          status: 'Tanque Cheio',
          icon: Icons.water_drop,
          compact: true,
        ),
    ];

    return StandardListItemCard(
      date: date,
      infoItems: infoItems,
      additionalBadges: badges,
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      actionWidget: actionWidget,
      showRelativeTime: true,
    );
  }
  
  /// Factory para criar list item de despesa
  factory StandardListItemCard.expense({
    required DateTime date,
    required String expenseType,
    required double amount,
    required double odometer,
    String? description,
    String? location,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
    Widget? actionWidget,
  }) {
    final infoItems = <InfoItemWidget>[
      InfoItemWidget.category(category: expenseType),
      InfoItemWidget.money(amount: amount),
      InfoItemWidget.odometer(kilometers: odometer),
      if (description != null && description.isNotEmpty)
        InfoItemWidget(
          label: 'Descrição',
          value: description,
          icon: Icons.description,
          layout: InfoItemLayout.vertical,
          truncateText: true,
        ),
      if (location != null) InfoItemWidget.location(location: location),
    ];

    return StandardListItemCard(
      date: date,
      infoItems: infoItems,
      badge: TypeBadgeWidget.expense(expenseType: expenseType),
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      actionWidget: actionWidget,
      highlightColor: GasometerDesignTokens.colorError,
    );
  }
  
  /// Factory para criar list item de manutenção
  factory StandardListItemCard.maintenance({
    required DateTime date,
    required String maintenanceType,
    required double cost,
    required double odometer,
    String? description,
    String? location,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
    Widget? actionWidget,
  }) {
    final infoItems = <InfoItemWidget>[
      InfoItemWidget.category(category: maintenanceType),
      InfoItemWidget.money(amount: cost, label: 'Custo'),
      InfoItemWidget.odometer(kilometers: odometer),
      if (description != null && description.isNotEmpty)
        InfoItemWidget(
          label: 'Descrição',
          value: description,
          icon: Icons.description,
          layout: InfoItemLayout.vertical,
          truncateText: true,
        ),
      if (location != null) InfoItemWidget.location(location: location),
    ];

    return StandardListItemCard(
      date: date,
      infoItems: infoItems,
      badge: TypeBadgeWidget.maintenance(maintenanceType: maintenanceType),
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      actionWidget: actionWidget,
      highlightColor: GasometerDesignTokens.colorWarning,
    );
  }
  
  /// Factory para criar list item de odômetro (para compatibilidade)
  factory StandardListItemCard.odometer({
    required DateTime date,
    required double odometer,
    String? location,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool isSelected = false,
    Widget? actionWidget,
  }) {
    final infoItems = <InfoItemWidget>[
      InfoItemWidget.odometer(kilometers: odometer),
      if (location != null) InfoItemWidget.location(location: location),
    ];

    return StandardListItemCard(
      date: date,
      infoItems: infoItems,
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      actionWidget: actionWidget,
    );
  }
  /// Data a ser exibida na coluna da esquerda
  final DateTime date;
  
  /// Lista de informações principais a serem exibidas
  final List<InfoItemWidget> infoItems;
  
  /// Badge/tag opcional para categoria ou tipo
  final TypeBadgeWidget? badge;
  
  /// Lista de badges adicionais
  final List<TypeBadgeWidget>? additionalBadges;
  
  /// Widget customizado para a área de ação (ex: botões)
  final Widget? actionWidget;
  
  /// Callback para tap no card
  final VoidCallback? onTap;
  
  /// Callback para long press no card
  final VoidCallback? onLongPress;
  
  /// Se o card está selecionado
  final bool isSelected;
  
  /// Estilo da data (compact, standard, full)
  final DateDisplayStyle dateStyle;
  
  /// Se deve mostrar tempo relativo na data
  final bool showRelativeTime;
  
  /// Cor customizada para destacar o card
  final Color? highlightColor;
  
  /// Se deve mostrar sombra
  final bool showShadow;
  
  /// Densidade do conteúdo (compact para listas densas)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: showShadow ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: ListItemDesignTokens.cardBorderRadius,
        side: isSelected 
            ? BorderSide(
                color: highlightColor ?? GasometerDesignTokens.colorPrimary,
                width: 2,
              )
            : BorderSide.none,
      ),
      color: isSelected 
          ? (highlightColor ?? GasometerDesignTokens.colorPrimary).withValues(alpha: 0.05)
          : ListItemDesignTokens.cardBackgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: ListItemDesignTokens.cardBorderRadius,
        child: Container(
          constraints: BoxConstraints(
            minHeight: compact 
                ? ListItemDesignTokens.cardMinHeight * 0.8 
                : ListItemDesignTokens.cardMinHeight,
          ),
          padding: compact 
              ? ListItemDesignTokens.cardPadding * 0.8
              : ListItemDesignTokens.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna da data (lado esquerdo)
              _buildDateColumn(),
              
              // Divisor vertical
              _buildDivider(),
              
              // Conteúdo principal (lado direito)
              Expanded(child: _buildContent()),
              
              // Widget de ação opcional
              if (actionWidget != null) ...[ 
                const SizedBox(width: 8),
                actionWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateColumn() {
    return DateDisplayWidget(
      date: date,
      style: dateStyle,
      showRelativeTime: showRelativeTime,
    );
  }

  Widget _buildDivider() {
    return Container(
      width: ListItemDesignTokens.dividerThickness,
      color: ListItemDesignTokens.dividerColor,
      margin: EdgeInsets.symmetric(
        horizontal: compact 
            ? GasometerDesignTokens.spacingSm * 0.8
            : GasometerDesignTokens.spacingSm,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: compact 
          ? ListItemDesignTokens.contentPadding * 0.8
          : ListItemDesignTokens.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badges na parte superior
          if (badge != null || (additionalBadges?.isNotEmpty ?? false))
            _buildBadgeSection(),
          
          // Informações principais
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildBadgeSection() {
    final allBadges = <TypeBadgeWidget>[
      if (badge != null) badge!,
      ...(additionalBadges ?? []),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: compact 
            ? ListItemDesignTokens.badgeSpacing * 0.8
            : ListItemDesignTokens.badgeSpacing,
      ),
      child: Wrap(
        spacing: GasometerDesignTokens.spacingXs,
        runSpacing: GasometerDesignTokens.spacingXs,
        children: allBadges,
      ),
    );
  }

  Widget _buildInfoSection() {
    // Organize info items in a responsive grid
    return _buildInfoGrid();
  }

  Widget _buildInfoGrid() {
    if (infoItems.isEmpty) return const SizedBox.shrink();

    // Para 1-2 items: linha única
    if (infoItems.length <= 2) {
      return Row(
        children: infoItems
            .map((item) => Expanded(child: item))
            .expand((widget) => [widget, const SizedBox(width: 12)])
            .toList()
          ..removeLast(), // Remove último SizedBox
      );
    }

    // Para 3-4 items: 2x2 grid
    if (infoItems.length <= 4) {
      return Column(
        children: [
          Row(
            children: infoItems
                .take(2)
                .map((item) => Expanded(child: item))
                .expand((widget) => [widget, const SizedBox(width: 12)])
                .toList()
              ..removeLast(),
          ),
          if (infoItems.length > 2) ...[ 
            SizedBox(height: compact ? 8 : 12),
            Row(
              children: infoItems
                  .skip(2)
                  .take(2)
                  .map((item) => Expanded(child: item))
                  .expand((widget) => [widget, const SizedBox(width: 12)])
                  .toList()
                ..removeLast(),
            ),
          ],
        ],
      );
    }

    // Para 5+ items: wrap layout
    return Wrap(
      spacing: 12,
      runSpacing: compact ? 6 : 8,
      children: infoItems,
    );
  }
}