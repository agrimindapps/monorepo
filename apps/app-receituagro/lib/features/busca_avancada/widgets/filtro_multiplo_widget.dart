import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget especializado para filtros múltiplos em cascata
/// Permite selecionar cultura, praga e defensivo simultaneamente
class FiltroMultiploWidget extends StatelessWidget {
  final List<Map<String, String>> culturas;
  final List<Map<String, String>> pragas;
  final List<Map<String, String>> defensivos;
  final String? culturaIdSelecionada;
  final String? pragaIdSelecionada;
  final String? defensivoIdSelecionado;
  final ValueChanged<String?> onCulturaChanged;
  final ValueChanged<String?> onPragaChanged;
  final ValueChanged<String?> onDefensivoChanged;
  final VoidCallback onBuscarPressed;
  final VoidCallback onLimparPressed;
  final bool isLoading;

  const FiltroMultiploWidget({
    super.key,
    required this.culturas,
    required this.pragas,
    required this.defensivos,
    this.culturaIdSelecionada,
    this.pragaIdSelecionada,
    this.defensivoIdSelecionado,
    required this.onCulturaChanged,
    required this.onPragaChanged,
    required this.onDefensivoChanged,
    required this.onBuscarPressed,
    required this.onLimparPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildFiltrosGrid(theme),
            const SizedBox(height: 20),
            _buildBotoes(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final filtrosAtivos = [
      if (culturaIdSelecionada != null) 'cultura',
      if (pragaIdSelecionada != null) 'praga',
      if (defensivoIdSelecionado != null) 'defensivo',
    ].length;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.8),
                theme.colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.tune,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$filtrosAtivos filtro(s) ativo(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosGrid(ThemeData theme) {
    return Column(
      children: [
        // Primeira linha: Cultura e Praga
        Row(
          children: [
            Expanded(
              child: _buildDropdownFiltro(
                theme: theme,
                label: 'Cultura',
                hint: 'Selecione uma cultura',
                icon: FontAwesomeIcons.seedling,
                color: Colors.green,
                items: culturas,
                selectedValue: culturaIdSelecionada,
                onChanged: onCulturaChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFiltro(
                theme: theme,
                label: 'Praga',
                hint: 'Selecione uma praga',
                icon: FontAwesomeIcons.bug,
                color: Colors.red,
                items: pragas,
                selectedValue: pragaIdSelecionada,
                onChanged: onPragaChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Segunda linha: Defensivo (full width)
        _buildDropdownFiltro(
          theme: theme,
          label: 'Defensivo',
          hint: 'Selecione um defensivo',
          icon: FontAwesomeIcons.vial,
          color: Colors.blue,
          items: defensivos,
          selectedValue: defensivoIdSelecionado,
          onChanged: onDefensivoChanged,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDropdownFiltro({
    required ThemeData theme,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> items,
    String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool isFullWidth = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedValue != null 
              ? color.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: selectedValue != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selectedValue != null 
            ? color.withValues(alpha: 0.05)
            : theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do filtro
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selectedValue != null 
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selectedValue != null 
                        ? color 
                        : theme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedValue != null 
                        ? color 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (selectedValue != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: theme.cardColor,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'],
                  child: Text(
                    item['nome']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoes(ThemeData theme) {
    final temFiltroAtivo = culturaIdSelecionada != null ||
        pragaIdSelecionada != null ||
        defensivoIdSelecionado != null;

    return Row(
      children: [
        // Botão Limpar
        if (temFiltroAtivo)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onLimparPressed,
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpar Filtros'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        if (temFiltroAtivo) const SizedBox(width: 16),
        
        // Botão Buscar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (!temFiltroAtivo || isLoading) ? null : onBuscarPressed,
            icon: isLoading 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(isLoading ? 'Buscando...' : 'Buscar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: temFiltroAtivo ? 4 : 0,
            ),
          ),
        ),
      ],
    );
  }
}