// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../utils/racas_lista_constants.dart';

class FilterModalWidget extends StatelessWidget {
  final RacasListaController controller;

  const FilterModalWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: RacasListaConstants.modalInitialSize,
      maxChildSize: RacasListaConstants.modalMaxSize,
      minChildSize: RacasListaConstants.modalMinSize,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: RacasListaConstants.modalBorderRadius,
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: RacasListaConstants.modalPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 24),
                        _buildTamanhoSection(),
                        const SizedBox(height: 24),
                        _buildTemperamentoSection(),
                        const SizedBox(height: 24),
                        _buildCuidadosSection(),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Filtrar Raças',
        style: RacasListaConstants.modalTitle,
      ),
    );
  }

  Widget _buildTamanhoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamanho',
          style: RacasListaConstants.modalSectionTitle,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RacasListaConstants.tamanhoOptions.map((tamanho) {
            final isSelected = controller.tamanhoFiltros.contains(tamanho);
            return FilterChip(
              label: Text(tamanho),
              selected: isSelected,
              onSelected: (selected) => controller.toggleTamanhoFilter(tamanho),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTemperamentoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperamento',
          style: RacasListaConstants.modalSectionTitle,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RacasListaConstants.temperamentoOptions.map((temperamento) {
            final isSelected = controller.temperamentoFiltros.contains(temperamento);
            return FilterChip(
              label: Text(temperamento),
              selected: isSelected,
              onSelected: (selected) => controller.toggleTemperamentoFilter(temperamento),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCuidadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuidados',
          style: RacasListaConstants.modalSectionTitle,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RacasListaConstants.cuidadosOptions.map((cuidado) {
            final isSelected = controller.cuidadosFiltros.contains(cuidado);
            return FilterChip(
              label: Text(cuidado),
              selected: isSelected,
              onSelected: (selected) => controller.toggleCuidadosFilter(cuidado),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              controller.clearAllFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpar Filtros'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }
}
