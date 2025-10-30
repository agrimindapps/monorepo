import 'package:flutter/material.dart';

/// Builds UI components for plant sort options
class PlantsSortBuilder {
  /// Build sort options modal content
  static Widget buildSortModal({
    required String currentSort,
    required Map<String, String> sortOptions,
    required VoidCallback Function(String) onSortSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordenar por',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...sortOptions.entries.map(
            (entry) => ListTile(
              title: Text(entry.value),
              trailing: currentSort == entry.key
                  ? const Icon(Icons.check)
                  : null,
              onTap: onSortSelected(entry.key),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sort button for app bar
  static Widget buildSortButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.sort, color: Colors.white, size: 18),
      ),
    );
  }

  /// Build group/ungroup button
  static Widget buildGroupButton({
    required bool isGrouped,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isGrouped
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.category, color: Colors.white, size: 18),
      ),
    );
  }
}
