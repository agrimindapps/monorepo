import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/space_form_provider.dart';
import '../../domain/entities/space.dart';

class SpaceFormPage extends StatefulWidget {
  final String? spaceId;
  
  const SpaceFormPage({
    super.key,
    this.spaceId,
  });

  @override
  State<SpaceFormPage> createState() => _SpaceFormPageState();
}

class _SpaceFormPageState extends State<SpaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _maxPlantsController = TextEditingController();

  bool get _isEditMode => widget.spaceId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SpaceFormProvider>();
      
      if (_isEditMode) {
        provider.initializeForEdit(widget.spaceId!);
      } else {
        provider.initializeForAdd();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _maxPlantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Espaço' : 'Novo Espaço'),
        actions: [
          Consumer<SpaceFormProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.isSaving ? null : _saveSpace,
                child: provider.isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: Consumer<SpaceFormProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Update controllers when form is initialized
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!provider.isLoading && provider.originalSpace != null) {
              _nameController.text = provider.name;
              _descriptionController.text = provider.description;
              _temperatureController.text = provider.temperature?.toString() ?? '';
              _humidityController.text = provider.humidity?.toString() ?? '';
              _maxPlantsController.text = provider.maxPlants?.toString() ?? '';
            }
          });

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error Message
                  if (provider.hasError)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: provider.clearError,
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),

                  // Basic Information Section
                  _buildSectionTitle('Informações Básicas'),
                  const SizedBox(height: 16),

                  // Space Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do espaço *',
                      hintText: 'Ex: Sala de estar, Varanda, Jardim',
                      prefixIcon: Icon(Icons.label),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (value.trim().length < 2) {
                        return 'Nome deve ter pelo menos 2 caracteres';
                      }
                      if (value.trim().length > 50) {
                        return 'Nome não pode ter mais de 50 caracteres';
                      }
                      return null;
                    },
                    onChanged: provider.setName,
                  ),

                  const SizedBox(height: 16),

                  // Space Type
                  DropdownButtonFormField<SpaceType>(
                    value: provider.type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de espaço *',
                      prefixIcon: Icon(Icons.home_work),
                    ),
                    items: SpaceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getSpaceTypeIcon(type),
                              size: 20,
                              color: _getSpaceTypeColor(type),
                            ),
                            const SizedBox(width: 12),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) provider.setType(value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Descreva características do espaço',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    validator: (value) {
                      if (value != null && value.trim().length > 200) {
                        return 'Descrição não pode ter mais de 200 caracteres';
                      }
                      return null;
                    },
                    onChanged: provider.setDescription,
                  ),

                  const SizedBox(height: 24),

                  // Environmental Configuration Section
                  _buildSectionTitle('Configurações Ambientais'),
                  const SizedBox(height: 16),

                  // Temperature
                  TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperatura (°C)',
                      hintText: 'Ex: 22',
                      prefixIcon: Icon(Icons.thermostat),
                      suffixText: '°C',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final temp = double.tryParse(value.trim());
                        if (temp == null) return 'Digite um número válido';
                        if (temp < -50 || temp > 60) {
                          return 'Temperatura deve estar entre -50°C e 60°C';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final temp = double.tryParse(value.trim());
                      provider.setTemperature(temp);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Humidity
                  TextFormField(
                    controller: _humidityController,
                    decoration: const InputDecoration(
                      labelText: 'Umidade (%)',
                      hintText: 'Ex: 60',
                      prefixIcon: Icon(Icons.water_drop),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final humidity = double.tryParse(value.trim());
                        if (humidity == null) return 'Digite um número válido';
                        if (humidity < 0 || humidity > 100) {
                          return 'Umidade deve estar entre 0% e 100%';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final humidity = double.tryParse(value.trim());
                      provider.setHumidity(humidity);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Light Level
                  DropdownButtonFormField<String>(
                    value: provider.lightLevel,
                    decoration: const InputDecoration(
                      labelText: 'Nível de luz',
                      prefixIcon: Icon(Icons.wb_sunny),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Não especificado')),
                      DropdownMenuItem(value: 'low', child: Text('Pouca luz')),
                      DropdownMenuItem(value: 'medium', child: Text('Luz média')),
                      DropdownMenuItem(value: 'high', child: Text('Muita luz')),
                    ],
                    onChanged: provider.setLightLevel,
                  ),

                  const SizedBox(height: 16),

                  // Switches Row
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Luz solar direta'),
                          subtitle: const Text('Recebe sol direto'),
                          value: provider.hasDirectSunlight ?? false,
                          onChanged: provider.setHasDirectSunlight,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Ar condicionado'),
                          subtitle: const Text('Possui climatização'),
                          value: provider.hasAirConditioning ?? false,
                          onChanged: provider.setHasAirConditioning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ventilation
                  DropdownButtonFormField<String>(
                    value: provider.ventilation,
                    decoration: const InputDecoration(
                      labelText: 'Ventilação',
                      prefixIcon: Icon(Icons.air),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Não especificado')),
                      DropdownMenuItem(value: 'poor', child: Text('Pouca')),
                      DropdownMenuItem(value: 'good', child: Text('Boa')),
                      DropdownMenuItem(value: 'excellent', child: Text('Excelente')),
                    ],
                    onChanged: provider.setVentilation,
                  ),

                  const SizedBox(height: 16),

                  // Max Plants
                  TextFormField(
                    controller: _maxPlantsController,
                    decoration: const InputDecoration(
                      labelText: 'Número máximo de plantas',
                      hintText: 'Ex: 10',
                      prefixIcon: Icon(Icons.local_florist),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final maxPlants = int.tryParse(value.trim());
                        if (maxPlants == null) return 'Digite um número válido';
                        if (maxPlants <= 0) {
                          return 'Número deve ser maior que 0';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final maxPlants = int.tryParse(value.trim());
                      provider.setMaxPlants(maxPlants);
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _saveSpace() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SpaceFormProvider>();
    final success = await provider.saveSpace();

    if (success && mounted) {
      context.pop();
    }
  }

  Color _getSpaceTypeColor(SpaceType type) {
    switch (type) {
      case SpaceType.indoor:
        return Colors.blue;
      case SpaceType.outdoor:
        return Colors.green;
      case SpaceType.greenhouse:
        return Colors.teal;
      case SpaceType.balcony:
        return Colors.orange;
      case SpaceType.garden:
        return Colors.lightGreen;
      case SpaceType.room:
        return Colors.purple;
      case SpaceType.kitchen:
        return Colors.red;
      case SpaceType.bathroom:
        return Colors.cyan;
      case SpaceType.office:
        return Colors.indigo;
    }
  }

  IconData _getSpaceTypeIcon(SpaceType type) {
    switch (type) {
      case SpaceType.indoor:
        return Icons.home;
      case SpaceType.outdoor:
        return Icons.nature;
      case SpaceType.greenhouse:
        return Icons.agriculture;
      case SpaceType.balcony:
        return Icons.balcony;
      case SpaceType.garden:
        return Icons.park;
      case SpaceType.room:
        return Icons.bed;
      case SpaceType.kitchen:
        return Icons.kitchen;
      case SpaceType.bathroom:
        return Icons.bathroom;
      case SpaceType.office:
        return Icons.business;
    }
  }
}