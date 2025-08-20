// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/form_constants.dart';
import '../constants/form_styles.dart';

/// Modelo simplificado de animal para o seletor
class AnimalSelectorModel {
  final String id;
  final String nome;
  final String? raca;
  final String? especie;
  final String? imagePath;

  const AnimalSelectorModel({
    required this.id,
    required this.nome,
    this.raca,
    this.especie,
    this.imagePath,
  });
}

/// Widget de seleção de animal unificado para todos os formulários de cadastro
class SharedAnimalSelector extends StatelessWidget {
  final String label;
  final List<AnimalSelectorModel> animals;
  final String? selectedAnimalId;
  final ValueChanged<String?> onAnimalChanged;
  final String? errorText;
  final bool isRequired;
  final String? hintText;
  final Widget? prefixIcon;
  final EdgeInsets? padding;
  final bool enabled;
  final VoidCallback? onAddAnimal;
  final bool showEmptyState;
  final double? maxHeight;

  const SharedAnimalSelector({
    super.key,
    this.label = 'Animal',
    required this.animals,
    this.selectedAnimalId,
    required this.onAnimalChanged,
    this.errorText,
    this.isRequired = true,
    this.hintText,
    this.prefixIcon,
    this.padding,
    this.enabled = true,
    this.onAddAnimal,
    this.showEmptyState = true,
    this.maxHeight,
  });

  /// Factory para consulta
  factory SharedAnimalSelector.consulta({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal da Consulta',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.pets),
      onAddAnimal: onAddAnimal,
    );
  }

  /// Factory para despesa
  factory SharedAnimalSelector.despesa({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal da Despesa',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.payment),
      onAddAnimal: onAddAnimal,
    );
  }

  /// Factory para lembrete
  factory SharedAnimalSelector.lembrete({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal do Lembrete',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.notification_important),
      onAddAnimal: onAddAnimal,
    );
  }

  /// Factory para medicamento
  factory SharedAnimalSelector.medicamento({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal do Medicamento',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.medication),
      onAddAnimal: onAddAnimal,
    );
  }

  /// Factory para peso
  factory SharedAnimalSelector.peso({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal da Pesagem',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.monitor_weight),
      onAddAnimal: onAddAnimal,
    );
  }

  /// Factory para vacina
  factory SharedAnimalSelector.vacina({
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    required ValueChanged<String?> onAnimalChanged,
    String? errorText,
    VoidCallback? onAddAnimal,
  }) {
    return SharedAnimalSelector(
      label: 'Animal da Vacina',
      animals: animals,
      selectedAnimalId: selectedAnimalId,
      onAnimalChanged: onAnimalChanged,
      errorText: errorText,
      prefixIcon: const Icon(Icons.vaccines),
      onAddAnimal: onAddAnimal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: FormStyles.smallSpacing),
          _buildSelector(),
          if (errorText != null) ...[
            const SizedBox(height: FormStyles.smallSpacing),
            _buildErrorText(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      isRequired ? '$label *' : label,
      style: FormStyles.subtitleTextStyle.copyWith(
        fontSize: FormStyles.bodyFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSelector() {
    if (animals.isEmpty && showEmptyState) {
      return _buildEmptyState();
    }

    return DropdownButtonFormField<String>(
      value: selectedAnimalId?.isEmpty == true ? null : selectedAnimalId,
      decoration: FormStyles.getInputDecoration(
        labelText: hintText ?? FormConstants.selectAnimalPlaceholder,
        errorText: null, // Handled separately
        prefixIcon: prefixIcon,
        enabled: enabled,
      ),
      items: _buildDropdownItems(),
      onChanged: enabled ? onAnimalChanged : null,
      validator: isRequired ? _validateSelection : null,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      style: FormStyles.bodyTextStyle,
      dropdownColor: FormStyles.surfaceColor,
      menuMaxHeight: maxHeight ?? 300,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: FormStyles.inputHeight,
      padding: FormStyles.horizontalPadding,
      decoration: BoxDecoration(
        border: Border.all(color: FormStyles.borderColor),
        borderRadius: BorderRadius.circular(FormStyles.borderRadius),
        color: FormStyles.backgroundColor,
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: FormStyles.smallSpacing),
          ],
          const Icon(
            Icons.info_outline,
            color: FormStyles.warningColor,
            size: 20,
          ),
          const SizedBox(width: FormStyles.smallSpacing),
          Expanded(
            child: Text(
              'Nenhum animal cadastrado',
              style: FormStyles.bodyTextStyle.copyWith(
                color: FormStyles.disabledColor,
              ),
            ),
          ),
          if (onAddAnimal != null) ...[
            const SizedBox(width: FormStyles.smallSpacing),
            IconButton(
              onPressed: onAddAnimal,
              icon: const Icon(Icons.add),
              tooltip: 'Adicionar Animal',
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return animals.map((animal) {
      return DropdownMenuItem<String>(
        value: animal.id,
        child: _buildAnimalItem(animal),
      );
    }).toList();
  }

  Widget _buildAnimalItem(AnimalSelectorModel animal) {
    return Row(
      children: [
        _buildAnimalAvatar(animal),
        const SizedBox(width: FormStyles.smallSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                animal.nome,
                style: FormStyles.bodyTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
              if (animal.raca?.isNotEmpty == true || animal.especie?.isNotEmpty == true)
                Text(
                  _getSubtitle(animal),
                  style: FormStyles.captionTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimalAvatar(AnimalSelectorModel animal) {
    if (animal.imagePath?.isNotEmpty == true) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(animal.imagePath!),
        onBackgroundImageError: (_, __) => _buildDefaultAvatar(animal),
      );
    }
    
    return _buildDefaultAvatar(animal);
  }

  Widget _buildDefaultAvatar(AnimalSelectorModel animal) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: _getAvatarColor(animal.nome),
      child: Text(
        animal.nome.isNotEmpty ? animal.nome[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: FormStyles.bodyFontSize,
        ),
      ),
    );
  }

  Widget _buildErrorText() {
    return Text(
      errorText!,
      style: FormStyles.errorTextStyle,
    );
  }

  String? _validateSelection(String? value) {
    if (value == null || value.isEmpty) {
      return FormConstants.requiredFieldMessage;
    }
    return null;
  }

  String _getSubtitle(AnimalSelectorModel animal) {
    final parts = <String>[];
    if (animal.raca?.isNotEmpty == true) {
      parts.add(animal.raca!);
    }
    if (animal.especie?.isNotEmpty == true) {
      parts.add(animal.especie!);
    }
    return parts.join(' • ');
  }

  Color _getAvatarColor(String name) {
    // Gera uma cor baseada no hash do nome para consistência
    final hash = name.hashCode;
    final colors = [
      FormStyles.primaryColor,
      FormStyles.successColor,
      FormStyles.warningColor,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Método estático para mostrar dialog de seleção de animal
  static Future<String?> showSelectionDialog({
    required BuildContext context,
    required List<AnimalSelectorModel> animals,
    String? selectedAnimalId,
    String title = 'Selecionar Animal',
    VoidCallback? onAddAnimal,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _AnimalSelectionDialog(
        animals: animals,
        selectedAnimalId: selectedAnimalId,
        title: title,
        onAddAnimal: onAddAnimal,
      ),
    );
  }
}

/// Dialog de seleção de animal
class _AnimalSelectionDialog extends StatefulWidget {
  final List<AnimalSelectorModel> animals;
  final String? selectedAnimalId;
  final String title;
  final VoidCallback? onAddAnimal;

  const _AnimalSelectionDialog({
    required this.animals,
    this.selectedAnimalId,
    required this.title,
    this.onAddAnimal,
  });

  @override
  State<_AnimalSelectionDialog> createState() => _AnimalSelectionDialogState();
}

class _AnimalSelectionDialogState extends State<_AnimalSelectionDialog> {
  String? selectedId;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedId = widget.selectedAnimalId;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnimals = widget.animals.where((animal) {
      return animal.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
             (animal.raca?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: FormStyles.getInputDecoration(
                labelText: 'Buscar animal...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: FormStyles.mediumSpacing),
            Flexible(
              child: filteredAnimals.isEmpty
                  ? const Center(child: Text('Nenhum animal encontrado'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = filteredAnimals[index];
                        return RadioListTile<String>(
                          value: animal.id,
                          groupValue: selectedId,
                          onChanged: (value) {
                            setState(() {
                              selectedId = value;
                            });
                          },
                          title: Text(animal.nome),
                          subtitle: animal.raca?.isNotEmpty == true
                              ? Text(animal.raca!)
                              : null,
                          secondary: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Text(
                              animal.nome.isNotEmpty
                                  ? animal.nome[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.onAddAnimal != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAddAnimal!();
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Animal'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(FormConstants.cancelLabel),
        ),
        ElevatedButton(
          onPressed: selectedId != null
              ? () => Navigator.of(context).pop(selectedId)
              : null,
          child: const Text('Selecionar'),
        ),
      ],
    );
  }
}
