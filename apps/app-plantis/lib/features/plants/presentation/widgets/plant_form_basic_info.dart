import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_form_provider.dart';
import '../../../../core/theme/colors.dart';

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
    final theme = Theme.of(context);
    
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
    final theme = Theme.of(context);
    
    return Consumer<PlantFormProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Container(
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
              child: provider.imageBase64 != null
                  ? Container() // TODO: Show image
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Adicionar foto da planta',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Opcional',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement camera capture
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de câmera em desenvolvimento'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement gallery picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de galeria em desenvolvimento'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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