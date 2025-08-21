import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class EmptyPlantsWidget extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final VoidCallback? onAddPlant;

  const EmptyPlantsWidget({
    super.key,
    this.isSearching = false,
    this.searchQuery = '',
    this.onClearSearch,
    this.onAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSearching) {
      // Estado vazio da busca
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de busca vazia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

              const SizedBox(height: 24),

              // Título
              Text(
                'Nenhuma planta encontrada',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Mensagem
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  children: [
                    const TextSpan(text: 'Não encontramos nenhuma planta com '),
                    TextSpan(
                      text: '"$searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.\nTente usar outros termos.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão para limpar busca
              if (onClearSearch != null)
                OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar busca'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PlantisColors.primary,
                    side: BorderSide(color: PlantisColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Estado vazio inicial (sem plantas)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de folha grande e cinza
            Icon(Icons.eco_outlined, size: 120, color: Colors.grey.shade400),

            const SizedBox(height: 32),

            // Título
            Text(
              'Nenhuma planta cadastrada',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Mensagem
            Text(
              'Adicione sua primeira planta para começar a cuidar\ndela com o Grow',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Botão para adicionar
            if (onAddPlant != null)
              ElevatedButton.icon(
                onPressed: onAddPlant,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar primeira planta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
