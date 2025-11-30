import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../providers/pluviometer_provider.dart';

/// Página de formulário para criar/editar pluviômetro
class RainGaugeFormPage extends ConsumerStatefulWidget {
  const RainGaugeFormPage({super.key, this.gauge});

  final RainGaugeEntity? gauge;

  @override
  ConsumerState<RainGaugeFormPage> createState() => _RainGaugeFormPageState();
}

class _RainGaugeFormPageState extends ConsumerState<RainGaugeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _capacityController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _groupIdController;

  bool get isEditing => widget.gauge != null;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.gauge?.description ?? '');
    _capacityController =
        TextEditingController(text: widget.gauge?.capacity ?? '');
    _latitudeController =
        TextEditingController(text: widget.gauge?.latitude ?? '');
    _longitudeController =
        TextEditingController(text: widget.gauge?.longitude ?? '');
    _groupIdController =
        TextEditingController(text: widget.gauge?.groupId ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _capacityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _groupIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rainGaugesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Pluviômetro' : 'Novo Pluviômetro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Ex: Pluviômetro do Campo Norte',
                prefixIcon: Icon(Icons.description),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descrição é obrigatória';
                }
                if (value.trim().length < 2) {
                  return 'Descrição deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Capacidade
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidade (mm) *',
                hintText: 'Ex: 150',
                prefixIcon: Icon(Icons.straighten),
                suffixText: 'mm',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Capacidade é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Seção de localização
            Text(
              'Localização GPS (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: '-23.550520',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Latitude inválida';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: '-46.633309',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lon = double.tryParse(value);
                        if (lon == null || lon < -180 || lon > 180) {
                          return 'Longitude inválida';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grupo
            TextFormField(
              controller: _groupIdController,
              decoration: const InputDecoration(
                labelText: 'Grupo (opcional)',
                hintText: 'Ex: Fazenda Sul',
                prefixIcon: Icon(Icons.folder),
              ),
            ),
            const SizedBox(height: 32),

            // Botão de salvar
            FilledButton.icon(
              onPressed: state.isLoading ? null : _saveGauge,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isEditing ? 'Atualizar' : 'Salvar'),
            ),

            // Mensagem de erro
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveGauge() async {
    if (!_formKey.currentState!.validate()) return;

    final gauge = RainGaugeEntity(
      id: widget.gauge?.id ?? '',
      createdAt: widget.gauge?.createdAt,
      updatedAt: widget.gauge?.updatedAt,
      isActive: true,
      description: _descriptionController.text.trim(),
      capacity: _capacityController.text.trim(),
      latitude: _latitudeController.text.trim().isEmpty
          ? null
          : _latitudeController.text.trim(),
      longitude: _longitudeController.text.trim().isEmpty
          ? null
          : _longitudeController.text.trim(),
      groupId: _groupIdController.text.trim().isEmpty
          ? null
          : _groupIdController.text.trim(),
      objectId: widget.gauge?.objectId,
    );

    final notifier = ref.read(rainGaugesProvider.notifier);
    final success =
        isEditing ? await notifier.updateGauge(gauge) : await notifier.createGauge(gauge);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Pluviômetro atualizado com sucesso'
              : 'Pluviômetro criado com sucesso'),
        ),
      );
      Navigator.pop(context);
    }
  }
}
