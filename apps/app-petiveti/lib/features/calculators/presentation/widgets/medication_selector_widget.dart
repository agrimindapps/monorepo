import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/medication_data.dart';
import '../providers/medication_dosage_provider.dart';

/// Widget para seleção de medicamentos com busca e favoritos
class MedicationSelectorWidget extends ConsumerStatefulWidget {
  const MedicationSelectorWidget({super.key});

  @override
  ConsumerState<MedicationSelectorWidget> createState() =>
      _MedicationSelectorWidgetState();
}

class _MedicationSelectorWidgetState
    extends ConsumerState<MedicationSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(medicationDosageProviderProvider);

    return Builder(
      builder: (context) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Seleção de Medicamento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _showFavoritesOnly
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: _showFavoritesOnly ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFavoritesOnly = !_showFavoritesOnly;
                        });
                      },
                      tooltip: 'Mostrar apenas favoritos',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar medicamento...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchMedications('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: provider.searchMedications,
                ),
                const SizedBox(height: 16),
                if (!_showFavoritesOnly) _buildCategoryFilters(provider),

                const SizedBox(height: 16),
                if (provider.searchQuery.isEmpty && !_showFavoritesOnly)
                  _buildTopMedicationsSection(provider),
                _buildMedicationsList(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilters(MedicationDosageProvider provider) {
    const categories = [
      'Todos',
      'Antibiótico',
      'Anti-inflamatório',
      'Analgésico',
      'Diurético',
      'Corticoide',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por categoria:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categories.map((category) {
            return FilterChip(
              label: Text(category),
              onSelected: (selected) {
                if (selected || category == 'Todos') {
                  provider.filterByCategory(category);
                }
              },
              selected: false, // Implementar lógica de seleção se necessário
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopMedicationsSection(MedicationDosageProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicamentos mais utilizados:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.topMedications.length,
            itemBuilder: (context, index) {
              final medication = provider.topMedications[index];
              return _buildTopMedicationCard(medication, provider);
            },
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildTopMedicationCard(
    MedicationData medication,
    MedicationDosageProvider provider,
  ) {
    final isSelected = provider.input.medicationId == medication.id;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.red.shade50 : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => provider.updateMedicationId(medication.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _getCategoryIcon(medication.category),
                    _buildFavoriteButton(medication, provider),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  medication.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.red.shade800 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  medication.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsList(MedicationDosageProvider provider) {
    List<MedicationData> medications = _showFavoritesOnly
        ? provider.getFavoriteMedications()
        : provider.filteredMedications;

    if (medications.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _showFavoritesOnly ? Icons.favorite_outline : Icons.search_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _showFavoritesOnly
                    ? 'Nenhum medicamento favorito'
                    : 'Nenhum medicamento encontrado',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _showFavoritesOnly
              ? 'Favoritos (${medications.length})'
              : 'Resultados (${medications.length})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return _buildMedicationTile(medication, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationTile(
    MedicationData medication,
    MedicationDosageProvider provider,
  ) {
    final isSelected = provider.input.medicationId == medication.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 3 : 1,
      color: isSelected ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? Colors.red.shade100
              : Colors.grey.shade200,
          child: _getCategoryIcon(medication.category),
        ),
        title: Text(
          medication.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.red.shade800 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medication.category} • ${medication.activeIngredient}'),
            if (medication.indications.isNotEmpty)
              Text(
                medication.indications.take(2).join(', '),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFavoriteButton(medication, provider),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green.shade600),
          ],
        ),
        onTap: () => provider.updateMedicationId(medication.id),
        selected: isSelected,
      ),
    );
  }

  Widget _buildFavoriteButton(
    MedicationData medication,
    MedicationDosageProvider provider,
  ) {
    final isFavorite = provider.favoriteMedications.contains(medication.id);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_outline,
        color: isFavorite ? Colors.red : Colors.grey,
        size: 20,
      ),
      onPressed: () => provider.toggleFavoriteMedication(medication.id),
      tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color;

    switch (category.toLowerCase()) {
      case 'antibiótico':
      case 'antibiótico quinolona':
        iconData = Icons.biotech;
        color = Colors.blue.shade600;
        break;
      case 'anti-inflamatório':
        iconData = Icons.healing;
        color = Colors.orange.shade600;
        break;
      case 'analgésico':
        iconData = Icons.medication;
        color = Colors.purple.shade600;
        break;
      case 'diurético':
        iconData = Icons.water_drop;
        color = Colors.cyan.shade600;
        break;
      case 'corticoide':
        iconData = Icons.science;
        color = Colors.red.shade600;
        break;
      case 'protetor gástrico':
        iconData = Icons.shield;
        color = Colors.green.shade600;
        break;
      case 'anticonvulsivante':
        iconData = Icons.psychology;
        color = Colors.indigo.shade600;
        break;
      case 'antidiabético':
        iconData = Icons.monitor_heart;
        color = Colors.teal.shade600;
        break;
      case 'antiprotozoário':
        iconData = Icons.bug_report;
        color = Colors.brown.shade600;
        break;
      default:
        iconData = Icons.medication;
        color = Colors.grey.shade600;
    }

    return Icon(iconData, color: color, size: 20);
  }
}
