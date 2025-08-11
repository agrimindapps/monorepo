import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/plant_form_provider.dart';
import '../../../../core/theme/colors.dart';

class PlantFormCareConfig extends StatefulWidget {
  const PlantFormCareConfig({super.key});

  @override
  State<PlantFormCareConfig> createState() => _PlantFormCareConfigState();
}

class _PlantFormCareConfigState extends State<PlantFormCareConfig> {
  final _wateringController = TextEditingController();
  final _fertilizingController = TextEditingController();
  final _pruningController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlantFormProvider>();
      _wateringController.text = provider.wateringIntervalDays?.toString() ?? '';
      _fertilizingController.text = provider.fertilizingIntervalDays?.toString() ?? '';
      _pruningController.text = provider.pruningIntervalDays?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _wateringController.dispose();
    _fertilizingController.dispose();
    _pruningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<PlantFormProvider>(
        builder: (context, provider, child) {
          final fieldErrors = provider.fieldErrors;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PlantisColors.primary.withValues(alpha: 0.1),
                      PlantisColors.primaryLight.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PlantisColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: PlantisColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cronograma de Cuidados',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure os intervalos de cuidado para sua planta',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Watering interval
              _buildIntervalField(
                controller: _wateringController,
                label: 'Intervalo de Rega',
                description: 'A cada quantos dias regar?',
                icon: Icons.water_drop,
                color: Colors.blue,
                errorText: fieldErrors['wateringInterval'],
                onChanged: (value) {
                  final interval = int.tryParse(value);
                  provider.setWateringInterval(interval);
                },
                examples: ['7 dias - Plantas normais', '3 dias - Plantas tropicais', '14 dias - Suculentas'],
              ),
              
              const SizedBox(height: 24),
              
              // Fertilizing interval
              _buildIntervalField(
                controller: _fertilizingController,
                label: 'Intervalo de Fertilização',
                description: 'A cada quantos dias fertilizar?',
                icon: Icons.eco,
                color: PlantisColors.primary,
                errorText: fieldErrors['fertilizingInterval'],
                onChanged: (value) {
                  final interval = int.tryParse(value);
                  provider.setFertilizingInterval(interval);
                },
                examples: ['30 dias - Mensal', '60 dias - Bimestral', '90 dias - Trimestral'],
              ),
              
              const SizedBox(height: 24),
              
              // Pruning interval
              _buildIntervalField(
                controller: _pruningController,
                label: 'Intervalo de Poda',
                description: 'A cada quantos dias podar?',
                icon: Icons.content_cut,
                color: Colors.orange,
                errorText: fieldErrors['pruningInterval'],
                onChanged: (value) {
                  final interval = int.tryParse(value);
                  provider.setPruningInterval(interval);
                },
                examples: ['90 dias - Trimestral', '180 dias - Semestral', '365 dias - Anual'],
              ),
              
              const SizedBox(height: 32),
              
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Todos os campos são opcionais. Configure apenas os cuidados que deseja acompanhar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntervalField({
    required TextEditingController controller,
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required ValueChanged<String> onChanged,
    required List<String> examples,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Input field
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Ex: 7',
            suffixText: 'dias',
            suffixStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
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
              borderSide: BorderSide(color: color, width: 2),
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
        
        if (examples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: examples.map((example) {
              final parts = example.split(' - ');
              final days = parts[0];
              final description = parts.length > 1 ? parts[1] : '';
              
              return InkWell(
                onTap: () {
                  final dayNumber = RegExp(r'\d+').firstMatch(days)?.group(0);
                  if (dayNumber != null) {
                    controller.text = dayNumber;
                    onChanged(dayNumber);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    example,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}