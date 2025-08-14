import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_form_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/image_service.dart';

class PlantFormBasicInfo extends StatefulWidget {
  const PlantFormBasicInfo({super.key});

  @override
  State<PlantFormBasicInfo> createState() => _PlantFormBasicInfoState();
}

class _PlantFormBasicInfoState extends State<PlantFormBasicInfo> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlantFormProvider>();
      _nameController.text = provider.name;
      _speciesController.text = provider.species;
      _notesController.text = provider.notes;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          _buildImageSection(context),
          
          const SizedBox(height: 32),
          
          // Basic information form
          _buildBasicInfoForm(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Consumer<PlantFormProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galeria de imagens ou área para adicionar primeira imagem
            if (provider.hasImages)
              _buildImageGallery(context, provider)
            else
              _buildEmptyImageArea(context, provider),
            
            const SizedBox(height: 16),
            
            // Botões de ação
            _buildImageActionButtons(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildImageGallery(BuildContext context, PlantFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos da Planta (${provider.imageUrls.length}/5)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageService().buildImagePreview(
                        provider.imageUrls[index],
                        width: 160,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showRemoveImageDialog(context, provider, index),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyImageArea(BuildContext context, PlantFormProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Adicionar fotos da planta',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Opcional - Máximo 5 fotos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionButtons(BuildContext context, PlantFormProvider provider) {
    final canAddMore = provider.imageUrls.length < 5;
    
    return Column(
      children: [
        // Botões principais para câmera e galeria
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAddMore && !provider.isUploadingImages
                    ? () => provider.addImageFromCamera()
                    : null,
                icon: provider.isUploadingImages 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.camera_alt),
                label: Text('Câmera'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAddMore && !provider.isUploadingImages
                    ? () => provider.addImageFromGallery()
                    : null,
                icon: provider.isUploadingImages 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.photo_library),
                label: Text('Galeria'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Botão para múltiplas imagens e remover todas
        Row(
          children: [
            if (canAddMore)
              Expanded(
                child: TextButton.icon(
                  onPressed: !provider.isUploadingImages
                      ? () => provider.addMultipleImagesFromGallery()
                      : null,
                  icon: Icon(Icons.photo_library_outlined),
                  label: Text('Múltiplas'),
                ),
              ),
            if (provider.hasImages) ...[
              SizedBox(width: canAddMore ? 16 : 0),
              Expanded(
                child: TextButton.icon(
                  onPressed: !provider.isUploadingImages
                      ? () => _showRemoveAllImagesDialog(context, provider)
                      : null,
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Remover Todas', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showRemoveImageDialog(BuildContext context, PlantFormProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Imagem'),
        content: Text('Deseja remover esta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.removeImage(index);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAllImagesDialog(BuildContext context, PlantFormProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Todas as Imagens'),
        content: Text('Deseja remover todas as imagens da planta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.removeAllImages();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remover Todas'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm(BuildContext context) {
    return Consumer<PlantFormProvider>(
      builder: (context, provider, child) {
        final fieldErrors = provider.fieldErrors;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant name (required)
            _buildTextField(
              controller: _nameController,
              label: 'Nome da planta',
              hint: 'Ex: Minha Rosa Vermelha',
              isRequired: true,
              errorText: fieldErrors['name'],
              onChanged: provider.setName,
              icon: Icons.local_florist,
            ),
            
            const SizedBox(height: 20),
            
            // Plant species (optional)
            _buildTextField(
              controller: _speciesController,
              label: 'Espécie',
              hint: 'Ex: Rosa gallica',
              onChanged: provider.setSpecies,
              icon: Icons.science,
            ),
            
            const SizedBox(height: 20),
            
            // Planting date (optional)
            _buildDateField(
              context: context,
              label: 'Data de plantio',
              value: provider.plantingDate,
              onChanged: provider.setPlantingDate,
              icon: Icons.event,
            ),
            
            const SizedBox(height: 20),
            
            // Notes (optional)
            _buildTextField(
              controller: _notesController,
              label: 'Observações',
              hint: 'Adicione notas sobre a planta...',
              maxLines: 4,
              onChanged: provider.setNotes,
              icon: Icons.note,
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
    required IconData icon,
    String? errorText,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: PlantisColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PlantisColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
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
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: PlantisColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: PlantisColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? _formatDate(value)
                        : 'Selecionar data (opcional)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
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
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}