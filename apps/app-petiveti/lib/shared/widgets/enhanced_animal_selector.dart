import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/animals/domain/entities/animal.dart';
import '../../features/animals/domain/entities/animal_enums.dart';
import '../../features/animals/presentation/providers/animals_providers.dart';
import 'animal_selector/animal_selector_dropdown.dart';
import 'animal_selector/animal_selector_empty.dart';
import 'animal_selector/animal_selector_loading.dart';

/// Seletor de pets aprimorado com dropdown, persistência e melhorias visuais
class EnhancedAnimalSelector extends ConsumerStatefulWidget {
  const EnhancedAnimalSelector({
    super.key,
    required this.selectedAnimalId,
    required this.onAnimalChanged,
    this.hintText = 'Selecione um pet',
    this.enabled = true,
    this.autoSelectFirst = true,
  });

  final String? selectedAnimalId;
  final void Function(String?) onAnimalChanged;
  final String? hintText;
  final bool enabled;
  final bool autoSelectFirst;

  @override
  ConsumerState<EnhancedAnimalSelector> createState() =>
      _EnhancedAnimalSelectorState();
}

class _EnhancedAnimalSelectorState extends ConsumerState<EnhancedAnimalSelector>
    with TickerProviderStateMixin {
  static const String _selectedAnimalKey = 'selected_animal_id';
  String? _currentSelectedAnimalId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedAnimalId = widget.selectedAnimalId;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _loadSelectedAnimal();
    _animationController.forward();
  }

  /// Carrega o pet selecionado do SharedPreferences
  Future<void> _loadSelectedAnimal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAnimalId = prefs.getString(_selectedAnimalKey);

      if (mounted) {
        final animalsState = ref.read(animalsProvider);
        final animals = animalsState.animals;

        if (savedAnimalId != null) {
          final animalExists = animals.any((a) => a.id == savedAnimalId);

          if (animalExists) {
            setState(() {
              _currentSelectedAnimalId = savedAnimalId;
            });
            widget.onAnimalChanged(savedAnimalId);
            return;
          } else {
            await prefs.remove(_selectedAnimalKey);
            debugPrint('🗑️ Pet removido das preferências: $savedAnimalId');
          }
        }

        if (_currentSelectedAnimalId == null &&
            animals.isNotEmpty &&
            widget.autoSelectFirst) {
          final animalToSelect = _selectBestAnimal(animals);
          if (animalToSelect != null) {
            setState(() {
              _currentSelectedAnimalId = animalToSelect.id;
            });
            widget.onAnimalChanged(animalToSelect.id);
            await _saveSelectedAnimal(animalToSelect.id);
            debugPrint(
              '🎯 Auto-seleção realizada: ${animalToSelect.name} (${animalToSelect.id})',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar pet selecionado: $e');
    }
  }

  /// Seleciona o melhor pet disponível para auto-seleção
  /// Ordena por data de criação (mais recente primeiro)
  Animal? _selectBestAnimal(List<Animal> animals) {
    if (animals.isEmpty) return null;

    final sortedAnimals = List<Animal>.from(animals)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedAnimals.first;
  }

  /// Salva o pet selecionado no SharedPreferences
  Future<void> _saveSelectedAnimal(String? animalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (animalId != null) {
        await prefs.setString(_selectedAnimalKey, animalId);
      } else {
        await prefs.remove(_selectedAnimalKey);
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar pet selecionado: $e');
    }
  }

  void _onAnimalSelected(String? animalId) {
    HapticFeedback.selectionClick();
    _animationController.reverse().then((_) {
      setState(() {
        _currentSelectedAnimalId = animalId;
        _isExpanded = false;
      });
      widget.onAnimalChanged(animalId);
      _saveSelectedAnimal(animalId);
      _animationController.forward();
    });
  }

  void _onDropdownTap() {
    if (!widget.enabled) return;

    final animalsState = ref.read(animalsProvider);
    final animals = animalsState.animals;

    if (animals.length <= 1) return; // Não abre se só tem 1 animal

    _showAnimalSelectionSheet(context, animals);
  }

  void _showAnimalSelectionSheet(BuildContext context, List<Animal> animals) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Selecionar Pet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];
                  final isSelected = animal.id == _currentSelectedAnimalId;

                  return ListTile(
                    leading: _buildAnimalAvatar(animal),
                    title: Text(
                      animal.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      (animal.breed != null && animal.breed!.isNotEmpty)
                          ? animal.breed!
                          : animal.species.displayName,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      _onAnimalSelected(animal.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalAvatar(Animal animal) {
    final color = _getAnimalColor(animal.species);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(_getAnimalIcon(animal.species), size: 20, color: color),
    );
  }

  IconData _getAnimalIcon(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return Icons.pets;
      case AnimalSpecies.cat:
        return Icons.cruelty_free;
      case AnimalSpecies.bird:
        return Icons.flutter_dash;
      case AnimalSpecies.rabbit:
        return Icons.pets_outlined;
      case AnimalSpecies.hamster:
      case AnimalSpecies.guineaPig:
        return Icons.pets_outlined;
      case AnimalSpecies.fish:
        return Icons.water;
      default:
        return Icons.pets;
    }
  }

  Color _getAnimalColor(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return Colors.brown;
      case AnimalSpecies.cat:
        return Colors.orange;
      case AnimalSpecies.bird:
        return Colors.blue;
      case AnimalSpecies.rabbit:
        return Colors.pink;
      case AnimalSpecies.hamster:
      case AnimalSpecies.guineaPig:
        return Colors.amber;
      case AnimalSpecies.fish:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);

    if (animalsState.isLoading && animalsState.animals.isEmpty) {
      return _buildLoadingState(context);
    }

    if (animalsState.animals.isEmpty) {
      return _buildEmptyState(context);
    }

    // Auto-seleciona o primeiro se necessário
    if (animalsState.animals.isNotEmpty &&
        _currentSelectedAnimalId == null &&
        widget.autoSelectFirst) {
      final animalToSelect = _selectBestAnimal(animalsState.animals);
      if (animalToSelect != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onAnimalSelected(animalToSelect.id);
          }
        });
      }
    }

    return _buildDropdown(context, animalsState.animals);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const AnimalSelectorLoading();
  }

  Widget _buildEmptyState(BuildContext context) {
    return AnimalSelectorEmpty(
      hintText: widget.hintText,
      scaleAnimation: _scaleAnimation,
      fadeAnimation: _fadeAnimation,
    );
  }

  Widget _buildDropdown(BuildContext context, List<Animal> animals) {
    return AnimalSelectorDropdown(
      animals: animals,
      currentSelectedAnimalId: _currentSelectedAnimalId,
      hintText: widget.hintText,
      enabled: widget.enabled,
      fadeAnimation: _fadeAnimation,
      isExpanded: _isExpanded,
      onAnimalSelected: _onAnimalSelected,
      onDropdownTap: _onDropdownTap,
    );
  }
}
