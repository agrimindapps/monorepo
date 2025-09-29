import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';

/// Widget para barra de busca de calculadoras
/// 
/// Implementa campo de busca com debounce e feedback visual
/// Centraliza lógica de busca em componente reutilizável
class CalculatorSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final bool isLoading;

  const CalculatorSearchBarWidget({
    super.key,
    required controller,
    required onChanged,
    hintText = 'Digite para buscar calculadoras...',
    isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo de busca principal
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: isLoading 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: onChanged,
          ),
          
          const SizedBox(height: 12),
          
          // Dicas de busca
          _buildSearchHints(context),
        ],
      ),
    );
  }

  Widget _buildSearchHints(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Busque por nome, descrição, categoria ou parâmetros',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}