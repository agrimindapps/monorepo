// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/months_navigation_widget.dart';
import '../styles/vacina_colors.dart';
import '../styles/vacina_constants.dart';

/// A reusable widget for displaying empty states when no data is available.
/// 
/// This widget provides a consistent and user-friendly way to show empty
/// states throughout the vaccine management interface. It includes an icon,
/// message, and optional action button.
/// 
/// Features:
/// - Customizable icon and message
/// - Optional action button
/// - Responsive design
/// - Theme-aware styling
/// - Accessibility support
class NoDataWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;

  const NoDataWidget({
    super.key,
    this.icon = Icons.vaccines_outlined,
    this.message = 'Nenhuma vacina encontrada',
    this.actionLabel,
    this.onActionPressed,
    this.iconColor,
    this.textColor,
    this.iconSize,
  });

  /// Creates a no data widget specifically for vaccines.
  factory NoDataWidget.vaccines({
    String? message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return NoDataWidget(
      icon: Icons.vaccines_outlined,
      message: message ?? 'Nenhuma vacina cadastrada neste período.',
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Creates a no data widget for search results.
  factory NoDataWidget.searchResults({
    String? searchTerm,
    VoidCallback? onClearSearch,
  }) {
    return NoDataWidget(
      icon: Icons.search_off,
      message: searchTerm?.isNotEmpty == true
          ? 'Nenhuma vacina encontrada para "$searchTerm"'
          : 'Nenhum resultado encontrado',
      actionLabel: 'Limpar busca',
      onActionPressed: onClearSearch,
    );
  }

  /// Creates a no data widget for filtered results.
  factory NoDataWidget.filteredResults({
    VoidCallback? onClearFilters,
  }) {
    return NoDataWidget(
      icon: Icons.filter_list_off,
      message: 'Nenhuma vacina corresponde aos filtros aplicados',
      actionLabel: 'Limpar filtros',
      onActionPressed: onClearFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize ?? VacinaConstants.tamanhoIconeStatus,
              color: iconColor ?? VacinaColors.cinza(context),
            ),
            const SizedBox(height: VacinaConstants.espacamentoPadrao),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? VacinaColors.cinza(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: VacinaConstants.espacamentoPadrao * 2),
              OutlinedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VacinaConstants.espacamentoPadrao * 2,
                    vertical: VacinaConstants.espacamentoPadrao,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A specialized no data widget for vaccine periods with month display.
class NoDataWithMonthWidget extends StatelessWidget {
  final List<DateTime> monthsList;
  final int currentIndex;
  final Function(int) onMonthTap;
  final String message;
  final VoidCallback? onRefresh;

  const NoDataWithMonthWidget({
    super.key,
    required this.monthsList,
    required this.currentIndex,
    required this.onMonthTap,
    this.message = 'Nenhuma vacina cadastrada neste período.',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthsNavigationWidget(
          monthsList: monthsList,
          currentIndex: currentIndex,
          onMonthTap: onMonthTap,
        ),
        const SizedBox(height: VacinaConstants.espacamentoPadrao),
        NoDataWidget(
          message: message,
          actionLabel: onRefresh != null ? 'Atualizar' : null,
          onActionPressed: onRefresh,
        ),
      ],
    );
  }

}
