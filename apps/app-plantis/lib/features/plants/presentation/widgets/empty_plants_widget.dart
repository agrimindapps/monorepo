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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PlantisColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco,
                size: 64,
                color: PlantisColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              'Sua coleção está vazia',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Mensagem
            Text(
              'Que tal adicionar sua primeira planta?\nComece sua jornada verde conosco!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Botão para adicionar
            if (onAddPlant != null)
              ElevatedButton.icon(
                onPressed: onAddPlant,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar minha primeira planta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}