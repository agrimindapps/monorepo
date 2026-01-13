import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../providers/weather_provider.dart';

class RainGaugeFormPage extends ConsumerStatefulWidget {
  final String? rainGaugeId;

  const RainGaugeFormPage({super.key, this.rainGaugeId});

  @override
  ConsumerState<RainGaugeFormPage> createState() => _RainGaugeFormPageState();
}

class _RainGaugeFormPageState extends ConsumerState<RainGaugeFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _locationNameController;
  late TextEditingController _deviceIdController;
  late TextEditingController _deviceModelController;

  // State variables
  bool _isActive = true;
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationNameController = TextEditingController();
    _deviceIdController = TextEditingController();
    _deviceModelController = TextEditingController();

    // Load existing data if editing
    if (widget.rainGaugeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRainGaugeData();
      });
    }
  }

  void _loadRainGaugeData() {
    final state = ref.read(weatherProvider);
    final gauge = state.rainGauges.firstWhere(
      (g) => g.id == widget.rainGaugeId,
      orElse: () => RainGaugeEntity.empty(),
    );

    if (gauge.id.isNotEmpty) {
      _locationNameController.text = gauge.locationName;
      _deviceIdController.text = gauge.deviceId;
      _deviceModelController.text = gauge.deviceModel;
      setState(() {
        _isActive = gauge.isActive;
        _status = gauge.status;
      });
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _deviceIdController.dispose();
    _deviceModelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isEditing = widget.rainGaugeId != null;
    final now = DateTime.now();

    try {
      final notifier = ref.read(weatherProvider.notifier);
      final existingGauge = isEditing
          ? ref
                .read(weatherProvider)
                .rainGauges
                .firstWhere(
                  (g) => g.id == widget.rainGaugeId,
                  orElse: () => RainGaugeEntity.empty(),
                )
          : RainGaugeEntity.empty();

      final rainGauge = existingGauge.copyWith(
        id: isEditing ? widget.rainGaugeId : _generateId(),
        locationName: _locationNameController.text,
        deviceId: _deviceIdController.text,
        deviceModel: _deviceModelController.text,
        status: _status,
        isActive: _isActive,
        updatedAt: now,
        // Set creation date for new items
        createdAt: isEditing ? null : now,
        // Initialize required fields for new items if they are empty
        installationDate: isEditing ? null : now,
      );

      bool success;
      if (isEditing) {
        success = await notifier.updateRainGauge(rainGauge);
      } else {
        success = await notifier.createRainGauge(rainGauge);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Pluviômetro atualizado com sucesso!'
                    : 'Pluviômetro criado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(weatherProvider).errorMessage ?? 'Erro ao salvar',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateId() {
    return 'rg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rainGaugeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Pluviômetro' : 'Novo Pluviômetro'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Local',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o nome do local';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'ID do Dispositivo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                helperText: 'Identificador único do sensor',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o ID do dispositivo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deviceModelController,
              decoration: const InputDecoration(
                labelText: 'Modelo do Dispositivo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_input_antenna),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Ativo')),
                        DropdownMenuItem(
                          value: 'maintenance',
                          child: Text('Em Manutenção'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inativo'),
                        ),
                        DropdownMenuItem(
                          value: 'offline',
                          child: Text('Offline'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _status = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Habilitado'),
                      subtitle: const Text('Receber dados deste dispositivo'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Salvando...' : 'Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pluviômetro'),
        content: const Text(
          'Tem certeza que deseja excluir este pluviômetro? Esta ação não pode ser desfeita e todo o histórico de medições pode ser perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final success = await ref
          .read(weatherProvider.notifier)
          .deleteRainGauge(widget.rainGaugeId!);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Pluviômetro excluído')));
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir pluviômetro'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
