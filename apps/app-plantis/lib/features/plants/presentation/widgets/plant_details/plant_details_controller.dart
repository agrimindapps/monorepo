import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/plant_details_provider.dart';
import '../../../domain/entities/plant.dart';

/// Controller responsável pela lógica de negócio da tela de detalhes da planta
class PlantDetailsController {
  final BuildContext context;
  final PlantDetailsProvider provider;

  PlantDetailsController({
    required this.context,
    required this.provider,
  });

  /// Carrega a planta por ID
  void loadPlant(String plantId) {
    provider.loadPlant(plantId);
  }

  /// Recarrega a planta atual
  void refresh(String plantId) {
    provider.loadPlant(plantId);
  }

  /// Navega de volta
  void goBack() {
    context.pop();
  }

  /// Mostra opções de edição da planta
  void showEditOptions(Plant plant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Editar ${plant.displayName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar informações'),
              subtitle: const Text('Nome, espécie, notas e configurações'),
              onTap: () {
                context.pop();
                context.push('/plants/edit/${plant.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_outlined),
              title: const Text('Gerenciar fotos'),
              subtitle: const Text('Adicionar, remover ou reorganizar fotos'),
              onTap: () {
                context.pop();
                context.push('/plants/${plant.id}/images');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Editar cronograma'),
              subtitle: const Text('Alterar intervalos de cuidados'),
              onTap: () {
                context.pop();
                context.push('/plants/${plant.id}/schedule');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Mostra mais opções da planta
  void showMoreOptions(Plant plant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Opções',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Compartilhar'),
              subtitle: const Text('Compartilhar informações da planta'),
              onTap: () {
                context.pop();
                _sharePlant(plant);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_outlined),
              title: const Text('Duplicar'),
              subtitle: const Text('Criar uma cópia desta planta'),
              onTap: () {
                context.pop();
                _duplicatePlant(plant);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Excluir',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              subtitle: const Text('Remover permanentemente esta planta'),
              onTap: () {
                context.pop();
                confirmDelete(plant);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Confirma a exclusão da planta
  void confirmDelete(Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir planta'),
        content: Text(
          'Tem certeza que deseja excluir "${plant.displayName}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              deletePlant(plant.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Exclui a planta
  Future<void> deletePlant(String plantId) async {
    try {
      await provider.deletePlant(plantId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir planta: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Compartilha as informações da planta
  void _sharePlant(Plant plant) {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de compartilhamento em desenvolvimento'),
      ),
    );
  }

  /// Duplica a planta
  void _duplicatePlant(Plant plant) {
    // TODO: Implementar duplicação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de duplicação em desenvolvimento'),
      ),
    );
  }

  /// Mostra mensagem de erro
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Mostra mensagem de sucesso
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}