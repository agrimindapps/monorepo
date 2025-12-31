import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/ui_constants.dart';
import '../../features/animals/domain/entities/animal.dart';
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
      duration: AppDurations.normal,
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
    setState(() {
      _isExpanded = !_isExpanded;
    });
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
