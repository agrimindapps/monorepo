// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/database_controller.dart';
import '../../utils/database_helpers.dart';

class DatabaseEmptyStateWidget extends StatelessWidget {
  final DatabaseController controller;

  const DatabaseEmptyStateWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSelectedBox) {
      return _buildNoBoxSelectedState();
    }

    if (controller.isEmpty) {
      return _buildEmptyBoxState();
    }

    if (controller.isFiltered && controller.filteredRecords == 0) {
      return _buildNoSearchResultsState();
    }

    return const SizedBox.shrink();
  }

  Widget _buildNoBoxSelectedState() {
    return DatabaseHelpers.buildEmptyState(
      icon: Icons.storage,
      title: 'Selecione uma box para visualizar seus dados',
      subtitle: 'Escolha uma das boxes disponíveis no seletor acima',
    );
  }

  Widget _buildEmptyBoxState() {
    final selectedBox = controller.selectedBox!;
    
    return DatabaseHelpers.buildEmptyState(
      icon: Icons.inbox,
      title: 'A box "${selectedBox.displayName}" está vazia',
      subtitle: 'Nenhum registro encontrado nesta box',
      action: ElevatedButton.icon(
        onPressed: () => controller.refreshData(),
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Recarregar'),
      ),
    );
  }

  Widget _buildNoSearchResultsState() {
    return DatabaseHelpers.buildEmptyState(
      icon: Icons.search_off,
      title: 'Nenhum resultado encontrado',
      subtitle: 'Tente ajustar os termos de pesquisa ou limpe o filtro',
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => controller.clearSearch(),
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Limpar pesquisa'),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesquisando por: "${controller.searchTerm}"',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
