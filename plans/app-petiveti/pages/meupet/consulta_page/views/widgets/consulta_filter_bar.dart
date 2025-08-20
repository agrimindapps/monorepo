// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_page_controller.dart';
import '../../utils/consulta_utils.dart';
import '../styles/consulta_page_styles.dart';

class ConsultaFilterBar extends StatelessWidget {
  final ConsultaPageController controller;

  const ConsultaFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasConsultas) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          Expanded(
            child: _buildFilterChips(),
          ),
          if (controller.hasActiveFilters()) ...[
            const SizedBox(width: 8),
            _buildClearFiltersButton(),
          ],
        ],
      );
    });
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDateFilterChip(),
          const SizedBox(width: 8),
          _buildSortChip(),
        ],
      ),
    );
  }

  Widget _buildDateFilterChip() {
    return Obx(() {
      final selectedDate = controller.selectedDate;
      final isSelected = selectedDate != null;

      return FilterChip(
        label: Text(
          isSelected
              ? 'Data: ${ConsultaUtils.formatDate(selectedDate)}'
              : 'Filtrar por data',
        ),
        selected: isSelected,
        onSelected: (_) => _showDatePicker(),
        selectedColor: ConsultaPageStyles.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: ConsultaPageStyles.primaryColor,
        avatar: Icon(
          Icons.date_range,
          size: ConsultaPageStyles.smallIconSize,
          color: isSelected
              ? ConsultaPageStyles.primaryColor
              : ConsultaPageStyles.textSecondaryColor,
        ),
      );
    });
  }

  Widget _buildSortChip() {
    return Obx(() {
      final sortBy = controller.selectedSortBy;
      final isAscending = controller.isAscending;

      String sortLabel;
      switch (sortBy) {
        case 'data':
          sortLabel = 'Data';
          break;
        case 'veterinario':
          sortLabel = 'Veterinário';
          break;
        case 'motivo':
          sortLabel = 'Motivo';
          break;
        default:
          sortLabel = 'Data';
      }

      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$sortLabel '),
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: ConsultaPageStyles.smallIconSize,
            ),
          ],
        ),
        selected: true,
        onSelected: (_) => _showSortOptions(),
        selectedColor: ConsultaPageStyles.secondaryColor.withValues(alpha: 0.2),
        checkmarkColor: ConsultaPageStyles.secondaryColor,
      );
    });
  }

  Widget _buildClearFiltersButton() {
    return IconButton(
      icon: const Icon(Icons.clear_all),
      onPressed: controller.clearFilters,
      tooltip: 'Limpar filtros',
      color: ConsultaPageStyles.textSecondaryColor,
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Filtrar consultas por data',
      cancelText: 'Cancelar',
      confirmText: 'Filtrar',
    );

    if (date != null) {
      controller.onDateFilterChanged(date);
    }
  }

  void _showSortOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: ConsultaPageStyles.titleStyle,
            ),
            const SizedBox(height: 16),
            _buildSortOption('data', 'Data da consulta', Icons.date_range),
            _buildSortOption('veterinario', 'Veterinário', Icons.person),
            _buildSortOption('motivo', 'Motivo', Icons.medical_services),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.onSortChanged(
                        controller.selectedSortBy,
                        ascending: true,
                      );
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Crescente'),
                    style: controller.isAscending
                        ? ConsultaPageStyles.primaryButtonStyle
                        : ConsultaPageStyles.outlineButtonStyle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.onSortChanged(
                        controller.selectedSortBy,
                        ascending: false,
                      );
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Decrescente'),
                    style: !controller.isAscending
                        ? ConsultaPageStyles.primaryButtonStyle
                        : ConsultaPageStyles.outlineButtonStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedSortBy == value;
      
      return ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? ConsultaPageStyles.primaryColor
              : ConsultaPageStyles.textSecondaryColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? ConsultaPageStyles.primaryColor
                : ConsultaPageStyles.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check,
                color: ConsultaPageStyles.primaryColor,
              )
            : null,
        onTap: () {
          controller.onSortChanged(value);
          Get.back();
        },
      );
    });
  }
}
