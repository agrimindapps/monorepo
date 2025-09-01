import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/busca_avancada_provider.dart';

/// Widget especializado para formulário de filtros da busca avançada
class FiltrosAvancadosWidget extends StatelessWidget {
  final BuscaAvancadaProvider provider;
  final VoidCallback onBuscarPressed;
  final VoidCallback onLimparPressed;

  const FiltrosAvancadosWidget({
    super.key,
    required this.provider,
    required this.onBuscarPressed,
    required this.onLimparPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          _buildFiltrosGrid(theme),
          const SizedBox(height: 24),
          _buildBotoes(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            FontAwesomeIcons.sliders,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros de Busca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Combine filtros para encontrar diagnósticos específicos',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltrosGrid(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                theme: theme,
                label: 'Cultura',
                icon: FontAwesomeIcons.seedling,
                iconColor: Colors.green,
                items: provider.culturas,
                selectedValue: provider.culturaIdSelecionada,
                onChanged: provider.setCulturaId,
                hint: 'Selecione uma cultura',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                theme: theme,
                label: 'Praga',
                icon: FontAwesomeIcons.bug,
                iconColor: Colors.red,
                items: provider.pragas,
                selectedValue: provider.pragaIdSelecionada,
                onChanged: provider.setPragaId,
                hint: 'Selecione uma praga',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          theme: theme,
          label: 'Defensivo',
          icon: FontAwesomeIcons.vial,
          iconColor: Colors.blue,
          items: provider.defensivos,
          selectedValue: provider.defensivoIdSelecionado,
          onChanged: provider.setDefensivoId,
          hint: 'Selecione um defensivo',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
    required String hint,
    bool fullWidth = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedValue != null 
                ? iconColor.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: selectedValue != null ? 2 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              dropdownColor: theme.cardColor,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      item['nome']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotoes(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : onBuscarPressed,
            icon: provider.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.search, size: 20),
            label: Text(
              provider.isLoading ? 'Buscando...' : 'Buscar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: provider.isLoading ? null : onLimparPressed,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text(
              'Limpar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}