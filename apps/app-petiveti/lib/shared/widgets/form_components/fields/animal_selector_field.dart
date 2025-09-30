import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/animals/domain/entities/animal.dart';
import '../../../../features/animals/domain/entities/animal_enums.dart';
import '../../../../features/animals/presentation/providers/animals_provider.dart';

/// **Animal Selector Field Component**
///
/// Componente reutilizável para seleção de animais em formulários.
/// Automaticamente carrega a lista de animais e oferece interface consistente.
///
/// **Funcionalidades:**
/// - Carregamento automático de animais
/// - Interface visual com avatar e informações do animal
/// - Estados de loading, error e empty
/// - Validação integrada
/// - Cores por espécie
/// - Navegação para cadastro quando vazio
///
/// **Uso:**
/// ```dart
/// AnimalSelectorField(
///   value: selectedAnimalId,
///   onChanged: (animalId) => setState(() => selectedAnimalId = animalId),
///   validator: (value) => value == null ? 'Selecione um animal' : null,
/// )
/// ```
class AnimalSelectorField extends ConsumerStatefulWidget {
  /// ID do animal atualmente selecionado
  final String? value;

  /// Callback executado quando a seleção muda
  final ValueChanged<String?>? onChanged;

  /// Função de validação
  final String? Function(String?)? validator;

  /// Se o campo está habilitado
  final bool enabled;

  /// Texto de label customizado
  final String? label;

  /// Texto de hint customizado
  final String? hint;

  /// Se deve carregar animais automaticamente
  final bool autoLoad;

  const AnimalSelectorField({
    super.key,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.label,
    this.hint,
    this.autoLoad = true,
  });

  @override
  ConsumerState<AnimalSelectorField> createState() => _AnimalSelectorFieldState();
}

class _AnimalSelectorFieldState extends ConsumerState<AnimalSelectorField> {

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      // Carrega animais automaticamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(animalsProvider.notifier).loadAnimals();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Estado de carregamento
        if (animalsState.isLoading) ...[
          _buildLoadingState(),
        ] else if (animalsState.error != null) ...[
          // Estado de erro
          _buildErrorState(animalsState.error!),
        ] else if (animalsState.animals.isEmpty) ...[
          // Estado vazio
          _buildEmptyState(),
        ] else ...[
          // Dropdown com animais
          _buildAnimalDropdown(animalsState.animals),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Carregando animais...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: AppColors.error),
        title: const Text('Erro ao carregar animais'),
        subtitle: Text(error),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(animalsProvider.notifier).loadAnimals(),
          tooltip: 'Tentar novamente',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.pets, color: AppColors.textSecondary),
        title: const Text('Nenhum animal encontrado'),
        subtitle: const Text('Cadastre seu primeiro pet para continuar'),
        trailing: TextButton(
          onPressed: () => Navigator.pushNamed(context, '/animals/add'),
          child: const Text('Cadastrar'),
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown(List<Animal> animals) {
    return DropdownButtonFormField<String>(
      value: widget.value,
      onChanged: widget.enabled ? widget.onChanged : null,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Selecione um animal',
        prefixIcon: const Icon(Icons.pets, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      items: animals.map((animal) {
        return DropdownMenuItem(
          value: animal.id,
          child: _buildAnimalListItem(animal),
        );
      }).toList(),
    );
  }

  Widget _buildAnimalListItem(Animal animal) {
    return Row(
      children: [
        // Avatar do animal
        CircleAvatar(
          radius: 16,
          backgroundColor: _getSpeciesColor(animal.species.name).withValues(alpha: 0.2),
          child: animal.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    animal.photoUrl!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildAnimalInitial(animal),
                  ),
                )
              : _buildAnimalInitial(animal),
        ),

        const SizedBox(width: 12),

        // Informações do animal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                animal.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${animal.species.displayName} • ${animal.breed ?? 'Sem raça definida'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Indicador de espécie
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getSpeciesColor(animal.species.name),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalInitial(Animal animal) {
    return Text(
      animal.name.substring(0, 1).toUpperCase(),
      style: TextStyle(
        color: _getSpeciesColor(animal.species.name),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Color _getSpeciesColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
      case 'cachorro':
        return const Color(0xFF2196F3); // Azul
      case 'cat':
      case 'gato':
        return const Color(0xFFFF9800); // Laranja
      case 'bird':
      case 'pássaro':
        return const Color(0xFF4CAF50); // Verde
      case 'rabbit':
      case 'coelho':
        return const Color(0xFFE91E63); // Rosa
      case 'hamster':
        return const Color(0xFF9C27B0); // Roxo
      case 'fish':
      case 'peixe':
        return const Color(0xFF00BCD4); // Ciano
      default:
        return const Color(0xFF757575); // Cinza
    }
  }
}

/// **Animal Selector Field Extensions**
///
/// Extensões para facilitar o uso do componente em casos específicos

extension AnimalSelectorFieldExtensions on AnimalSelectorField {
  /// Cria um seletor de animal com validação obrigatória
  static Widget required({
    String? value,
    ValueChanged<String?>? onChanged,
    String label = 'Animal',
    String hint = 'Selecione um animal',
    bool enabled = true,
  }) {
    return AnimalSelectorField(
      value: value,
      onChanged: onChanged,
      label: label,
      hint: hint,
      enabled: enabled,
      validator: (value) => value == null ? 'Selecione um animal' : null,
    );
  }

  /// Cria um seletor de animal opcional
  static Widget optional({
    String? value,
    ValueChanged<String?>? onChanged,
    String label = 'Animal (Opcional)',
    String hint = 'Selecione um animal',
    bool enabled = true,
  }) {
    return AnimalSelectorField(
      value: value,
      onChanged: onChanged,
      label: label,
      hint: hint,
      enabled: enabled,
      validator: null,
    );
  }
}