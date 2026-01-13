import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/weather_provider.dart';

class WeatherMeasurementFormPage extends ConsumerStatefulWidget {
  const WeatherMeasurementFormPage({super.key});

  @override
  ConsumerState<WeatherMeasurementFormPage> createState() =>
      _WeatherMeasurementFormPageState();
}

class _WeatherMeasurementFormPageState
    extends ConsumerState<WeatherMeasurementFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _locationNameController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _pressureController = TextEditingController();
  final _windSpeedController = TextEditingController();
  final _windDirectionController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _weatherCondition = 'unknown';

  @override
  void initState() {
    super.initState();
    // Initialize with default values if needed
    _pressureController.text = '1013.2'; // Standard pressure
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    _pressureController.dispose();
    _windSpeedController.dispose();
    _windDirectionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(weatherProvider.notifier);

      // We'll use a generated ID for location for now, or the name as ID if unique
      // Ideally this comes from a Location selection
      final locationId =
          'loc_${_locationNameController.text.toLowerCase().replaceAll(' ', '_')}';

      final success = await notifier.createManualMeasurement(
        locationId: locationId,
        locationName: _locationNameController.text,
        temperature: double.parse(_temperatureController.text),
        humidity: double.tryParse(_humidityController.text) ?? 0,
        pressure: double.tryParse(_pressureController.text) ?? 1013.25,
        windSpeed: double.tryParse(_windSpeedController.text) ?? 0,
        windDirection: double.tryParse(_windDirectionController.text) ?? 0,
        rainfall: double.tryParse(_rainfallController.text) ?? 0,
        latitude: 0, // Default or get from device GPS
        longitude: 0,
        weatherCondition: _weatherCondition,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medição registrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(weatherProvider).errorMessage ??
                    'Erro ao salvar medição',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Medição')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Local e Data'),
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: 'Local',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
                hintText: 'Ex: Sede, Pasto 1',
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Informe o local' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Condições'),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temp. (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Obrigatório';
                      if (double.tryParse(value) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _humidityController,
                    decoration: const InputDecoration(
                      labelText: 'Umidade (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final val = double.tryParse(value);
                        if (val == null || val < 0 || val > 100) return '0-100';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rainfallController,
                    decoration: const InputDecoration(
                      labelText: 'Chuva (mm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pressureController,
                    decoration: const InputDecoration(
                      labelText: 'Pressão (hPa)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weather Condition Dropdown
            DropdownButtonFormField<String>(
              initialValue: _weatherCondition,
              decoration: const InputDecoration(
                labelText: 'Condição do Tempo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              items: const [
                DropdownMenuItem(value: 'unknown', child: Text('Desconhecido')),
                DropdownMenuItem(value: 'sunny', child: Text('Ensolarado')),
                DropdownMenuItem(value: 'cloudy', child: Text('Nublado')),
                DropdownMenuItem(
                  value: 'partly_cloudy',
                  child: Text('Parcialmente Nublado'),
                ),
                DropdownMenuItem(value: 'rain', child: Text('Chuvoso')),
                DropdownMenuItem(
                  value: 'heavy_rain',
                  child: Text('Chuva Forte'),
                ),
                DropdownMenuItem(
                  value: 'thunderstorm',
                  child: Text('Tempestade'),
                ),
                DropdownMenuItem(value: 'fog', child: Text('Neblina')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _weatherCondition = val);
              },
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Vento (Opcional)'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _windSpeedController,
                    decoration: const InputDecoration(
                      labelText: 'Velocidade (km/h)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _windDirectionController,
                    decoration: const InputDecoration(
                      labelText: 'Direção (Graus)',
                      border: OutlineInputBorder(),
                      helperText: '0° = Norte, 90° = Leste',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
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
                label: Text(_isLoading ? 'Salvando...' : 'Salvar Medição'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
