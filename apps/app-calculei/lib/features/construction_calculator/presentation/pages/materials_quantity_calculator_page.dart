import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/index.dart';

/// Page for calculating material quantities for construction
class MaterialsQuantityCalculatorPage extends ConsumerStatefulWidget {
  const MaterialsQuantityCalculatorPage({super.key});

  @override
  ConsumerState<MaterialsQuantityCalculatorPage> createState() =>
      _MaterialsQuantityCalculatorPageState();
}

class _MaterialsQuantityCalculatorPageState
    extends ConsumerState<MaterialsQuantityCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  String _selectedBuildingType = 'alvenaria';
  MaterialsQuantityCalculation? _calculation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/construction/selection'),
        ),
        title: const Row(
          children: [
            Icon(Icons.layers, color: Color(0xFF8B4513)),
            SizedBox(width: 8),
            Text('Quantidades de Materiais'),
          ],
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dados da Construção',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        // Area Input
                        TextFormField(
                          controller: _areaController,
                          decoration: const InputDecoration(
                            labelText: 'Área da Construção',
                            suffixText: 'm²',
                            border: OutlineInputBorder(),
                            helperText: 'Informe a área em metros quadrados',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a área';
                            }
                            final area = double.tryParse(value);
                            if (area == null || area <= 0) {
                              return 'Área deve ser maior que zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Building Type Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedBuildingType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Construção',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'alvenaria',
                              child: Text('Alvenaria (Blocos/Tijolos)'),
                            ),
                            DropdownMenuItem(
                              value: 'concreto',
                              child: Text('Concreto (Fundação/Estrutura)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedBuildingType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        // Calculate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleCalculate,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.calculate),
                            label: Text(
                              _isLoading ? 'Calculando...' : 'Calcular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Results
              if (_calculation != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleCalculate() async {
    if (!_formKey.currentState!.validate()) return;

    final area = double.parse(_areaController.text);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate calculation - in real app, would use use case through provider
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple calculation without use case for now
    double brickQuantity = 0;
    double sandQuantity = 0;
    double cementQuantity = 0;
    double mortarQuantity = 0;

    if (_selectedBuildingType == 'alvenaria') {
      brickQuantity = area * 80;
      sandQuantity = area * 0.04;
      cementQuantity = (sandQuantity * 1.4) / 50;
      mortarQuantity = sandQuantity;
    } else if (_selectedBuildingType == 'concreto') {
      sandQuantity = area * 0.03;
      cementQuantity = (sandQuantity * 2) / 50;
    }

    setState(() {
      _calculation = MaterialsQuantityCalculation(
        area: area,
        sandQuantity: sandQuantity,
        cementQuantity: cementQuantity,
        brickQuantity: brickQuantity,
        mortarQuantity: mortarQuantity,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
    });
  }

  Widget _buildResultsCard() {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    final calc = _calculation!;

    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                const SizedBox(width: 8),
                Text(
                  'Resultado da Calculation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildResultItem('Área', '${formatter.format(calc.area)} m²'),
            if (calc.brickQuantity != null && calc.brickQuantity! > 0) ...[
              const Divider(height: 16),
              _buildResultItem(
                'Blocos/Tijolos',
                '${formatter.format(calc.brickQuantity)} unidades',
              ),
            ],
            if (calc.sandQuantity != null && calc.sandQuantity! > 0) ...[
              const Divider(height: 16),
              _buildResultItem(
                'Areia',
                '${formatter.format(calc.sandQuantity)} m³',
              ),
            ],
            if (calc.cementQuantity != null && calc.cementQuantity! > 0) ...[
              const Divider(height: 16),
              _buildResultItem(
                'Cimento',
                '${formatter.format(calc.cementQuantity)} sacos',
              ),
            ],
            if (calc.mortarQuantity != null && calc.mortarQuantity! > 0) ...[
              const Divider(height: 16),
              _buildResultItem(
                'Argamassa',
                '${formatter.format(calc.mortarQuantity)} m³',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
        ),
      ],
    );
  }
}
