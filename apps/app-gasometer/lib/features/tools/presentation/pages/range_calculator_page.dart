import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/semantic_widgets.dart';

/// Simple Range calculator - no database required
class RangeCalculatorPage extends StatefulWidget {
  const RangeCalculatorPage({super.key});

  @override
  State<RangeCalculatorPage> createState() => _RangeCalculatorPageState();
}

class _RangeCalculatorPageState extends State<RangeCalculatorPage> {
  final _fuelRemainingController = TextEditingController();
  final _consumptionController = TextEditingController();

  double? _fuelRemaining;
  double? _consumption;
  double? _rangeKm;

  @override
  void dispose() {
    _fuelRemainingController.dispose();
    _consumptionController.dispose();
    super.dispose();
  }

  void _calculate() {
    final fuel = _fuelRemaining;
    final consumption = _consumption;

    if (fuel == null || consumption == null || consumption == 0) {
      setState(() {
        _rangeKm = null;
      });
      return;
    }

    setState(() {
      _rangeKm = fuel * consumption;
    });
  }

  void _clear() {
    setState(() {
      _fuelRemainingController.clear();
      _consumptionController.clear();
      _fuelRemaining = null;
      _consumption = null;
      _rangeKm = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputCard(theme),
                    const SizedBox(height: 16),
                    if (_rangeKm != null) ...[
                      _buildResultCard(theme),
                      const SizedBox(height: 16),
                    ],
                    _buildInfoCard(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.speed,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Autonomia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Quantos km pode rodar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fuel Remaining field
            TextField(
              controller: _fuelRemainingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              decoration: InputDecoration(
                labelText: 'Combustível Restante (Litros)',
                hintText: '0,0',
                prefixIcon: Icon(Icons.local_gas_station, color: theme.colorScheme.primary),
                border: const OutlineInputBorder(),
                helperText: 'Quantos litros restam no tanque',
              ),
              onChanged: (value) {
                setState(() {
                  _fuelRemaining = double.tryParse(value.replaceAll(',', '.'));
                });
              },
            ),
            const SizedBox(height: 16),
            // Consumption field
            TextField(
              controller: _consumptionController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              decoration: InputDecoration(
                labelText: 'Consumo Médio (Km/L)',
                hintText: '0,0',
                prefixIcon: Icon(Icons.eco, color: theme.colorScheme.tertiary),
                border: const OutlineInputBorder(),
                helperText: 'Quantos km seu carro faz por litro',
              ),
              onChanged: (value) {
                setState(() {
                  _consumption = double.tryParse(value.replaceAll(',', '.'));
                });
              },
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final rangeKm = _rangeKm!;
    final canReach100km = rangeKm >= 100;
    
    return Card(
      elevation: 4,
      color: canReach100km 
          ? theme.colorScheme.tertiaryContainer 
          : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              canReach100km ? Icons.check_circle : Icons.warning,
              color: canReach100km 
                  ? theme.colorScheme.onTertiaryContainer 
                  : theme.colorScheme.onErrorContainer,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Você pode rodar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: (canReach100km 
                    ? theme.colorScheme.onTertiaryContainer 
                    : theme.colorScheme.onErrorContainer).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rangeKm.toStringAsFixed(0)} km',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: canReach100km 
                    ? theme.colorScheme.onTertiaryContainer 
                    : theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Divider(
              color: (canReach100km 
                  ? theme.colorScheme.onTertiaryContainer 
                  : theme.colorScheme.onErrorContainer).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Combustível',
                      style: TextStyle(
                        fontSize: 12,
                        color: (canReach100km 
                            ? theme.colorScheme.onTertiaryContainer 
                            : theme.colorScheme.onErrorContainer).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fuelRemaining!.toStringAsFixed(1)} L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canReach100km 
                            ? theme.colorScheme.onTertiaryContainer 
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: (canReach100km 
                      ? theme.colorScheme.onTertiaryContainer 
                      : theme.colorScheme.onErrorContainer).withValues(alpha: 0.2),
                ),
                Column(
                  children: [
                    Text(
                      'Consumo',
                      style: TextStyle(
                        fontSize: 12,
                        color: (canReach100km 
                            ? theme.colorScheme.onTertiaryContainer 
                            : theme.colorScheme.onErrorContainer).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_consumption!.toStringAsFixed(1)} km/L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canReach100km 
                            ? theme.colorScheme.onTertiaryContainer 
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!canReach100km) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atenção: Autonomia baixa! Considere abastecer.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Como usar?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1. Verifique quantos litros restam no tanque\n'
              '2. Informe o consumo médio do seu veículo (km/L)\n'
              '3. O resultado mostrará quantos km você pode rodar',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fórmula: Litros × Km/L = Autonomia',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dica: O consumo médio pode variar conforme estilo de direção e condições da via',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
