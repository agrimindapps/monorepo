import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/usecases/spaces_usecases.dart';
import '../providers/plant_form_provider.dart';
import '../providers/spaces_provider.dart';
import 'space_selector_widget.dart';

class PlantFormBasicInfo extends StatefulWidget {
  const PlantFormBasicInfo({super.key});

  @override
  State<PlantFormBasicInfo> createState() => _PlantFormBasicInfoState();
}

class _PlantFormBasicInfoState extends State<PlantFormBasicInfo> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();
  PlantFormProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = context.read<PlantFormProvider>();
      _updateControllers();
      _provider?.addListener(_updateControllers);
    });
  }

  void _updateControllers() {
    if (_provider != null && mounted) {
      if (_nameController.text != _provider!.name) {
        _nameController.text = _provider!.name;
      }
      if (_speciesController.text != _provider!.species) {
        _speciesController.text = _provider!.species;
      }
      if (_notesController.text != _provider!.notes) {
        _notesController.text = _provider!.notes;
      }
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_updateControllers);
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          _buildImageSection(context),

          const SizedBox(height: 20),

          // Basic information form
          _buildBasicInfoForm(context),
        ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Optimized with Selector - only rebuilds when image-related data changes
    return Selector<PlantFormProvider, ({bool hasImages, bool isUploading})>(
      selector: (context, provider) => (
        hasImages: provider.hasImages,
        isUploading: provider.isUploadingImages,
      ),
      builder: (context, data, child) {
        final provider = context.read<PlantFormProvider>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show upload progress or images
            if (data.isUploading)
              _buildUploadProgress(context)
            else if (data.hasImages)
              _buildSingleImage(context, provider)
            else
              _buildEmptyImageArea(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildSingleImage(BuildContext context, PlantFormProvider provider) {
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
                onTap: () => _showRemoveImageDialog(context, provider, 0),
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
              provider.imageUrls.first,
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
    PlantFormProvider provider,
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
        onTap: () => _showImageOptions(context, provider),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
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


  void _showImageOptions(BuildContext context, PlantFormProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
                      provider: provider,
                      icon: Icons.camera_alt,
                      label: 'Câmera',
                      onTap: () {
                        Navigator.of(context).pop();
                        provider.addImageFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageOptionButton(
                      context: context,
                      provider: provider,
                      icon: Icons.photo_library,
                      label: 'Galeria',
                      onTap: () {
                        Navigator.of(context).pop();
                        provider.addImageFromGallery();
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
    required PlantFormProvider provider,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDisabled = provider.hasImages || provider.isUploadingImages;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDisabled 
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
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
            if (provider.isUploadingImages)
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
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : theme.colorScheme.primary,
              ),
            const SizedBox(height: 12),
            Text(
              provider.isUploadingImages ? 'Enviando...' : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDisabled 
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
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
    PlantFormProvider provider,
    int index,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Imagem'),
            content: const Text('Deseja remover esta imagem?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  provider.removeImage(index);
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
    return Consumer<PlantFormProvider>(
      builder: (context, provider, child) {
        final fieldErrors = provider.fieldErrors;
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant name (required) with security validation
            _buildTextField(
              controller: _nameController,
              label: 'Nome da planta',
              hint: 'Ex: Minha Rosa Vermelha',
              isRequired: true,
              errorText: fieldErrors['name'],
              onChanged: (value) {
                // Não sanitizar em tempo real para não interferir na digitação
                provider.setName(value);
              },
              validator: (value) => _validatePlantName(value),
              prefixIcon: Icon(
                Icons.local_florist,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 12),

            // Plant species (optional) with security validation
            _buildTextField(
              controller: _speciesController,
              label: 'Espécie',
              hint: 'Ex: Rosa gallica',
              onChanged: (value) {
                // Não sanitizar em tempo real para não interferir na digitação
                provider.setSpecies(value);
              },
              validator: (value) => _validateSpecies(value),
              prefixIcon: Icon(
                Icons.science,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 12),

            // Space selector
            ChangeNotifierProvider(
              create: (_) => di.sl<SpacesProvider>(),
              child: SpaceSelectorWidget(
                selectedSpaceId: provider.spaceId,
                onSpaceChanged: (spaceId) => _handleSpaceSelection(provider, spaceId),
                errorText: fieldErrors['space'],
              ),
            ),

            const SizedBox(height: 12),

            // Planting date (optional)
            _buildDateField(
              context: context,
              label: 'Data de plantio',
              value: provider.plantingDate,
              onChanged: provider.setPlantingDate,
              prefixIcon: Icon(
                Icons.event,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 12),

            // Notes (optional) with security validation
            _buildTextField(
              controller: _notesController,
              label: 'Observações',
              hint: 'Adicione notas sobre a planta...',
              maxLines: 4,
              onChanged: (value) {
                // Não sanitizar em tempo real para não interferir na digitação
                provider.setNotes(value);
              },
              validator: (value) => _validateNotes(value),
              prefixIcon: Icon(
                Icons.note,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    Widget? prefixIcon,
    String? errorText,
    bool isRequired = false,
    int maxLines = 1,
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
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
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
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
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
                      color:
                          value != null
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
  Future<void> _handleSpaceSelection(PlantFormProvider plantProvider, String? value) async {
    if (value == null) {
      // "Sem espaço" selecionado
      plantProvider.setSpaceId(null);
      return;
    }

    if (value.startsWith('CREATE_NEW:')) {
      // Criar novo espaço
      final spaceName = value.substring('CREATE_NEW:'.length);
      if (spaceName.trim().isEmpty) return;

      try {
        final spacesProvider = di.sl<SpacesProvider>();
        await spacesProvider.loadSpaces(); // Garantir que temos a lista atual
        
        // Verificar se já existe um espaço com esse nome
        final existingSpace = spacesProvider.findSpaceByName(spaceName);
        if (existingSpace != null) {
          // Usar o espaço existente
          plantProvider.setSpaceId(existingSpace.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Espaço "$spaceName" já existe. Usando espaço existente.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          return;
        }

        // Criar novo espaço
        final success = await spacesProvider.addSpace(AddSpaceParams(name: spaceName));
        
        if (success && mounted) {
          // Buscar o espaço recém-criado
          await spacesProvider.loadSpaces();
          final newSpace = spacesProvider.findSpaceByName(spaceName);
          
          if (newSpace != null) {
            plantProvider.setSpaceId(newSpace.id);
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
      // Espaço existente selecionado
      plantProvider.setSpaceId(value);
    }
  }
  
  /// Validates plant name with security checks
  String? _validatePlantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira o nome da planta';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (trimmedValue.length > 100) {
      return 'Nome muito longo (máximo 100 caracteres)';
    }
    
    // Check for potentially malicious characters
    if (RegExp(r'[<>"\\\n\r\t]').hasMatch(trimmedValue)) {
      return 'Nome contém caracteres não permitidos';
    }
    
    return null;
  }
  
  /// Validates plant species with security checks
  String? _validateSpecies(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Species is optional
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length > 100) {
      return 'Espécie muito longa (máximo 100 caracteres)';
    }
    
    // Check for potentially malicious characters
    if (RegExp(r'[<>"\\\n\r\t]').hasMatch(trimmedValue)) {
      return 'Espécie contém caracteres não permitidos';
    }
    
    return null;
  }
  
  /// Validates notes with security checks
  String? _validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length > 1000) {
      return 'Observações muito longas (máximo 1000 caracteres)';
    }
    
    // Check for potentially malicious characters (allow newlines for notes)
    if (RegExp(r'[<>"\\]').hasMatch(trimmedValue)) {
      return 'Observações contêm caracteres não permitidos';
    }
    
    return null;
  }

  /// Build upload progress indicator
  Widget _buildUploadProgress(BuildContext context) {
    final theme = Theme.of(context);

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
                      'Fazendo upload da imagem...',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(2),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

    // For local files or other formats
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
