import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/busca_avancada_notifier.dart';

/// Widget especializado para formulário de filtros da busca avançada
class FiltrosAvancadosWidget extends ConsumerWidget {
  final VoidCallback onBuscarPressed;
  final VoidCallback onLimparPressed;

  const FiltrosAvancadosWidget({
    super.key,
    required this.onBuscarPressed,
    required this.onLimparPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final buscaState = ref.watch(buscaAvancadaNotifierProvider);

    return buscaState.when(
      data: (state) => _buildContent(context, theme, state, ref),
      loading: () => _buildLoadingState(theme),
      error: (error, _) => _buildErrorState(theme, error),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    BuscaAvancadaState state,
    WidgetRef ref,
  ) {
    final notifier = ref.read(buscaAvancadaNotifierProvider.notifier);
    
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
          _buildFiltrosGrid(theme, state, notifier),
          const SizedBox(height: 24),
          _buildBotoes(theme, state),
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

  Widget _buildFiltrosGrid(
    ThemeData theme,
    BuscaAvancadaState state,
    BuscaAvancadaNotifier notifier,
  ) {
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
                items: state.culturas,
                selectedValue: state.culturaIdSelecionada,
                onChanged: notifier.setCulturaId,
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
                items: state.pragas,
                selectedValue: state.pragaIdSelecionada,
                onChanged: notifier.setPragaId,
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
          items: state.defensivos,
          selectedValue: state.defensivoIdSelecionado,
          onChanged: notifier.setDefensivoId,
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

  Widget _buildBotoes(ThemeData theme, BuscaAvancadaState state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : onBuscarPressed,
            icon: state.isLoading
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
              state.isLoading ? 'Buscando...' : 'Buscar',
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
            onPressed: state.isLoading ? null : onLimparPressed,
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

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Erro: $error',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}