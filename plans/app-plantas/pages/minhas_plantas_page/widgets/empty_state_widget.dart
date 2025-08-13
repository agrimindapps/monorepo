// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'no_plants_widget.dart';
import 'no_results_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool hasSearchText;
  final String searchText;
  final VoidCallback? onAddPlant;

  const EmptyStateWidget({
    super.key,
    required this.hasSearchText,
    required this.searchText,
    this.onAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    if (hasSearchText) {
      return NoResultsWidget(searchTerm: searchText);
    } else {
      return NoPlantsWidget(onAddPlant: onAddPlant);
    }
  }
}
