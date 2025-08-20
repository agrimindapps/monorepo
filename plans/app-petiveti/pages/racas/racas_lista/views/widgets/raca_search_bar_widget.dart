// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../utils/racas_lista_constants.dart';

class RacaSearchBarWidget extends StatelessWidget {
  final RacasListaController controller;

  const RacaSearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RacasListaConstants.searchPadding,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar raça por nome, origem ou temperamento',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: RacasListaConstants.searchBorderRadius,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: controller.updateSearchText,
      ),
    );
  }
}
