// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/atualizacoes_controller.dart';
import '../../utils/atualizacoes_helpers.dart';

class EmptyAtualizacoesWidget extends StatelessWidget {
  final AtualizacoesController controller;

  const EmptyAtualizacoesWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isFiltered && controller.filteredCount == 0) {
      return _buildNoSearchResults();
    }

    return AtualizacoesHelpers.buildEmptyState();
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum resultado encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou termos de pesquisa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (controller.searchTerm.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Pesquisando por: "${controller.searchTerm}"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              children: [
                if (controller.searchTerm.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpar pesquisa'),
                  ),
                if (controller.isFiltered)
                  ElevatedButton.icon(
                    onPressed: controller.clearAllFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Limpar filtros'),
                  ),
                ElevatedButton.icon(
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Recarregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
