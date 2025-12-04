import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/spaces_providers.dart';
import '../../../../core/providers/state/plant_form_state_notifier.dart';
import '../../domain/usecases/spaces_usecases.dart';
import 'space_selector_widget.dart';

class PlantFormBasicInfo extends ConsumerStatefulWidget {
  const PlantFormBasicInfo({super.key});

  @override
  ConsumerState<PlantFormBasicInfo> createState() => _PlantFormBasicInfoState();
}

class _PlantFormBasicInfoState extends ConsumerState<PlantFormBasicInfo> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();

  // FocusNodes para navegação por Tab
  final _nameFocusNode = FocusNode();
  final _speciesFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateControllers();
      _setupStateListener();
    });
  }

  void _setupStateListener() {
    ref.listenManual(plantFormStateNotifierProvider, (previous, next) {
      if (mounted) {
        _syncControllersWithState(next);
      }
    });
  }

  void _updateControllers() {
    if (mounted) {
      final formState = ref.read(plantFormStateNotifierProvider);
      _syncControllersWithState(formState);
    }
  }

  void _syncControllersWithState(PlantFormState formState) {
    if (_nameController.text != formState.name) {
      _updateControllerSafely(_nameController, formState.name);
    }
    if (_speciesController.text != formState.species) {
      _updateControllerSafely(_speciesController, formState.species);
    }
    if (_notesController.text != formState.notes) {
      _updateControllerSafely(_notesController, formState.notes);
    }
  }

  /// Atualiza controller preservando posição do cursor
  void _updateControllerSafely(
    TextEditingController controller,
    String newValue,
  ) {
    final selection = controller.selection;
    controller.text = newValue;
    if (selection.isValid && selection.baseOffset <= newValue.length) {
      controller.selection = selection;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    _speciesFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(context),
        const SizedBox(height: 20),
        _buildBasicInfoForm(context),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final formState = ref.watch(plantFormStateNotifierProvider);
    final formNotifier = ref.read(plantFormStateNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formState.isUploadingImages)
          _buildUploadProgress(context)
        else if (formState.imageUrls.isNotEmpty)
          _buildSingleImage(context, formState, formNotifier)
        else
          _buildEmptyImageArea(context, formNotifier),
      ],
    );
  }

  Widget _buildSingleImage(
    BuildContext context,
    PlantFormState formState,
    PlantFormStateNotifier formNotifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF), // Branco puro para modo claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Foto da Planta',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () => _showRemoveImageDialog(context, formNotifier, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildNetworkImageWithFallback(
              formState.imageUrls.first,
              width: double.infinity,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImageArea(
    BuildContext context,
    PlantFormStateNotifier formNotifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF), // Branco puro para modo claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: InkWell(
        onTap: () => _showImageOptions(context, formNotifier),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicionar foto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Selecione uma foto da sua planta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageOptions(
    BuildContext context,
    PlantFormStateNotifier formNotifier,
  ) {
    final isWebOrDesktop = MediaQuery.of(context).size.width > 600;
    
    if (isWebOrDesktop) {
      _showImageOptionsDialog(context, formNotifier);
    } else {
      _showImageOptionsBottomSheet(context, formNotifier);
    }
  }

  void _showImageOptionsDialog(
    BuildContext context,
    PlantFormStateNotifier formNotifier,
  ) {
    final theme = Theme.of(context);
    final formState = ref.read(plantFormStateNotifierProvider);
    final isDisabled =
        formState.imageUrls.isNotEmpty || formState.isUploadingImages;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Adicionar Foto'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escolha como deseja adicionar a foto da sua planta',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogImageOption(
                        context: dialogContext,
                        theme: theme,
                        icon: Icons.camera_alt,
                        label: 'Câmera',
                        subtitle: 'Tirar uma foto',
                        isDisabled: isDisabled,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          formNotifier.captureImageFromCamera();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDialogImageOption(
                        context: dialogContext,
                        theme: theme,
                        icon: Icons.photo_library,
                        label: 'Galeria',
                        subtitle: 'Escolher arquivo',
                        isDisabled: isDisabled,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          formNotifier.selectImageFromGallery();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogImageOption({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDisabled
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isDisabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageOptionsBottomSheet(
    BuildContext context,
    PlantFormStateNotifier formNotifier,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Adicionar Foto',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOptionButton(
                      context: context,
                      formNotifier: formNotifier,
                      icon: Icons.camera_alt,
                      label: 'Câmera',
                      onTap: () {
                        Navigator.of(context).pop();
                        formNotifier.captureImageFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageOptionButton(
                      context: context,
                      formNotifier: formNotifier,
                      icon: Icons.photo_library,
                      label: 'Galeria',
                      onTap: () {
                        Navigator.of(context).pop();
                        formNotifier.selectImageFromGallery();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOptionButton({
    required BuildContext context,
    required PlantFormStateNotifier formNotifier,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final formState = ref.read(plantFormStateNotifierProvider);
    final isDisabled =
        formState.imageUrls.isNotEmpty || formState.isUploadingImages;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                )
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            if (formState.isUploadingImages)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(
                icon,
                size: 32,
                color: isDisabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      )
                    : theme.colorScheme.primary,
              ),
            const SizedBox(height: 12),
            Text(
              formState.isUploadingImages ? 'Enviando...' : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      )
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveImageDialog(
    BuildContext context,
    PlantFormStateNotifier formNotifier,
    int index,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Imagem'),
        content: const Text('Deseja remover esta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              formNotifier.removeImage(index);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm(BuildContext context) {
    final formState = ref.watch(plantFormStateNotifierProvider);
    final formNotifier = ref.read(plantFormStateNotifierProvider.notifier);
    final fieldErrors = formState.fieldErrors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          label: 'Nome da planta',
          hint: 'Ex: Minha Rosa Vermelha',
          isRequired: true,
          autofocus: true,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _speciesFocusNode.requestFocus(),
          errorText: fieldErrors['name'],
          onChanged: (value) {
            formNotifier.setName(value);
          },
          validator: (value) => _validatePlantName(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _speciesController,
          focusNode: _speciesFocusNode,
          label: 'Espécie',
          hint: 'Ex: Rosa gallica',
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _notesFocusNode.requestFocus(),
          onChanged: (value) {
            formNotifier.setSpecies(value);
          },
          validator: (value) => _validateSpecies(value),
        ),
        const SizedBox(height: 16),
        SpaceSelectorWidget(
          selectedSpaceId: formState.spaceId,
          onSpaceChanged: (spaceId) =>
              _handleSpaceSelection(formNotifier, spaceId),
          errorText: fieldErrors['space'],
        ),
        const SizedBox(height: 16),
        _buildDateField(
          context: context,
          label: 'Data de plantio',
          value: formState.plantingDate,
          onChanged: formNotifier.setPlantingDate,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          focusNode: _notesFocusNode,
          label: 'Observações',
          hint: 'Adicione notas sobre a planta...',
          maxLines: 4,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            formNotifier.setNotes(value);
          },
          validator: (value) => _validateNotes(value),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    Widget? prefixIcon,
    String? errorText,
    bool isRequired = false,
    bool autofocus = false,
    int maxLines = 1,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          autofocus: autofocus,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              locale: const Locale('pt', 'BR'),
            );

            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value != null
                        ? _formatDate(value)
                        : 'Selecionar data (opcional)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Handles space selection including creating new spaces
  Future<void> _handleSpaceSelection(
    PlantFormStateNotifier formNotifier,
    String? value,
  ) async {
    if (value == null) {
      formNotifier.setSpaceId(null);
      return;
    }

    if (value.startsWith('CREATE_NEW:')) {
      final spaceName = value.substring('CREATE_NEW:'.length);
      if (spaceName.trim().isEmpty) return;

      try {
        final spacesNotifier = ref.read(spacesNotifierProvider.notifier);
        await spacesNotifier.loadSpaces(); // Garantir que temos a lista atual
        final spacesState = ref.read(spacesNotifierProvider);
        final existingSpace = spacesState.maybeWhen(
          data: (state) => state.findSpaceByName(spaceName),
          orElse: () => null,
        );

        if (existingSpace != null) {
          formNotifier.setSpaceId(existingSpace.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Espaço "$spaceName" já existe. Usando espaço existente.',
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          return;
        }
        final success = await spacesNotifier.addSpace(
          AddSpaceParams(name: spaceName),
        );

        if (success && mounted) {
          await spacesNotifier.loadSpaces();
          final updatedState = ref.read(spacesNotifierProvider);
          final newSpace = updatedState.maybeWhen(
            data: (state) => state.findSpaceByName(spaceName),
            orElse: () => null,
          );

          if (newSpace != null) {
            formNotifier.setSpaceId(newSpace.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Espaço "$spaceName" criado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao criar espaço. Tente novamente.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro inesperado: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      formNotifier.setSpaceId(value);
    }
  }

  /// Validates plant name using centralized validator
  String? _validatePlantName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome da planta é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    return null;
  }

  /// Validates plant species using centralized validator
  String? _validateSpecies(String? value) {
    if (value != null && value.length > 100) {
      return 'Espécie deve ter no máximo 100 caracteres';
    }
    return null;
  }

  /// Validates notes using centralized validator
  String? _validateNotes(String? value) {
    if (value != null && value.length > 1000) {
      return 'Notas devem ter no máximo 1000 caracteres';
    }
    return null;
  }

  /// Build upload progress indicator
  Widget _buildUploadProgress(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(plantFormStateNotifierProvider);

    final currentImage = (formState.uploadingImageIndex ?? 0) + 1;
    final totalImages = formState.totalImagesToUpload ?? 1;
    final progress = formState.uploadProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviando imagem $currentImage de $totalImages',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(2),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build network image with fallback
  Widget _buildNetworkImageWithFallback(
    String imageUrl, {
    required double width,
    required double height,
  }) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
          );
        },
      );
    }
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}
