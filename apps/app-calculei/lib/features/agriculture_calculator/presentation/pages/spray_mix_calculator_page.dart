import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/spray_mix_calculator.dart';

/// Página da calculadora de calda de pulverização
class SprayMixCalculatorPage extends StatefulWidget {
  const SprayMixCalculatorPage({super.key});

  @override
  State<SprayMixCalculatorPage> createState() =>
      _SprayMixCalculatorPageState();
}

class _SprayMixCalculatorPageState extends State<SprayMixCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController(text: '10');
  final _applicationRateController = TextEditingController(text: '200');
  final _tankCapacityController = TextEditingController(text: '2000');

  // Lista de produtos (até 3 produtos por vez)
  final List<_ProductInput> _products = [
    _ProductInput(
      nameController: TextEditingController(text: 'Herbicida'),
      doseController: TextEditingController(text: '2000'),
      unit: ProductUnit.mL,
    ),
  ];

  SprayMixCalculation? _result;

  @override
  void dispose() {
    _areaController.dispose();
    _applicationRateController.dispose();
    _tankCapacityController.dispose();
    for (final product in _products) {
      product.nameController.dispose();
      product.doseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Calda de Pulverização',
      subtitle: 'Preparo de Calda',
      icon: Icons.water_drop,
      accentColor: const Color(0xFF4CAF50), // Green accent
      currentCategory: 'agricultura',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Area and application settings
              _buildAreaSection(),
              const SizedBox(height: 24),

              // Products section
              _buildProductsSection(),
              const SizedBox(height: 32),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: const Color(0xFF4CAF50),
              ),

              const SizedBox(height: 24),

              if (_result != null)
                _SprayMixResultCard(result: _result!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Parâmetros da Aplicação',
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 160,
                  child: AdaptiveInputField(
                    label: 'Área',
                    controller: _areaController,
                    suffix: 'ha',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Obrigatório';
                      final value = double.tryParse(v!);
                      if (value == null || value <= 0) {
                        return 'Área deve ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AdaptiveInputField(
                    label: 'Volume de calda',
                    controller: _applicationRateController,
                    suffix: 'L/ha',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}'),
                      ),
                    ],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Obrigatório';
                      final value = double.tryParse(v!);
                      if (value == null || value <= 0) {
                        return 'Volume deve ser > 0';
                      }
                      if (value < 50 || value > 600) {
                        return 'Típico: 50-600 L/ha';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AdaptiveInputField(
                    label: 'Capacidade do tanque',
                    controller: _tankCapacityController,
                    suffix: 'L',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,1}'),
                      ),
                    ],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Obrigatório';
                      final value = double.tryParse(v!);
                      if (value == null || value <= 0) {
                        return 'Capacidade deve ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Produtos (${_products.length}/3)',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_products.length < 3)
                  TextButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar produto'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _products.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProductInput(index),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductInput(int index) {
    final product = _products[index];

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.science,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Produto ${index + 1}',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_products.length > 1)
                    IconButton(
                      onPressed: () => _removeProduct(index),
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red.withValues(alpha: 0.7),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 200,
                    child: AdaptiveInputField(
                      label: 'Nome do produto',
                      controller: product.nameController,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: AdaptiveInputField(
                      label: 'Dose por hectare',
                      controller: product.doseController,
                      suffix: SprayMixCalculator.getUnitLabel(product.unit),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Obrigatório';
                        final value = double.tryParse(v!);
                        if (value == null || value <= 0) {
                          return 'Dose deve ser > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Unidade de medida',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProductUnit.values.map((unit) {
                  return DarkChoiceChip(
                    label: SprayMixCalculator.getUnitName(unit),
                    isSelected: product.unit == unit,
                    onSelected: () {
                      setState(() {
                        _products[index] = product.copyWith(unit: unit);
                      });
                    },
                    accentColor: const Color(0xFF4CAF50),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addProduct() {
    if (_products.length < 3) {
      setState(() {
        _products.add(
          _ProductInput(
            nameController: TextEditingController(),
            doseController: TextEditingController(),
            unit: ProductUnit.mL,
          ),
        );
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      _products[index].nameController.dispose();
      _products[index].doseController.dispose();
      _products.removeAt(index);
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final products = _products
        .map((p) => SprayProduct(
              name: p.nameController.text.trim(),
              dosePerHa: double.parse(p.doseController.text),
              unit: p.unit,
            ))
        .toList();

    final result = SprayMixCalculator.calculate(
      areaHa: double.parse(_areaController.text),
      applicationRateLHa: double.parse(_applicationRateController.text),
      tankCapacityL: double.parse(_tankCapacityController.text),
      products: products,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _areaController.text = '10';
    _applicationRateController.text = '200';
    _tankCapacityController.text = '2000';

    // Limpa produtos mantendo apenas 1
    for (var i = _products.length - 1; i > 0; i--) {
      _products[i].nameController.dispose();
      _products[i].doseController.dispose();
      _products.removeAt(i);
    }

    _products[0].nameController.text = 'Herbicida';
    _products[0].doseController.text = '2000';
    _products[0].unit = ProductUnit.mL;

    setState(() {
      _result = null;
    });
  }
}

class _ProductInput {
  final TextEditingController nameController;
  final TextEditingController doseController;
  ProductUnit unit;

  _ProductInput({
    required this.nameController,
    required this.doseController,
    required this.unit,
  });

  _ProductInput copyWith({ProductUnit? unit}) {
    return _ProductInput(
      nameController: nameController,
      doseController: doseController,
      unit: unit ?? this.unit,
    );
  }
}

class _SprayMixResultCard extends StatelessWidget {
  final SprayMixCalculation result;

  const _SprayMixResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    'Resultado - Calda de Pulverização',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ShareButton(
                    text: _formatShareText(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Volume total e tanques
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      const Color(0xFF4CAF50).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _ResultRow(
                      label: 'Volume total de calda',
                      value: '${result.totalSprayVolume.toStringAsFixed(1)} L',
                      highlight: true,
                    ),
                    Divider(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                      height: 24,
                    ),
                    _ResultRow(
                      label: 'Número de tanques',
                      value: '${result.numberOfTanks}',
                      highlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Por tanque
              Text(
                'Por Tanque (${result.tankCapacity.toStringAsFixed(0)} L)',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _ResultRow(
                      label: 'Água',
                      value: '${result.waterPerTank.toStringAsFixed(1)} L',
                    ),
                    const SizedBox(height: 8),
                    ...result.productsPerTank.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _ResultRow(
                          label: product.productName,
                          value:
                              '${product.quantityPerTank.toStringAsFixed(2)} ${SprayMixCalculator.getUnitLabel(product.unit)}',
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total de produtos
              if (result.productsPerTank.isNotEmpty) ...[
                Text(
                  'Total de Produtos',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: result.productsPerTank.map((product) {
                      final total = product.quantityPerTank * result.numberOfTanks;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ResultRow(
                          label: product.productName,
                          value:
                              '${total.toStringAsFixed(2)} ${SprayMixCalculator.getUnitLabel(product.unit)}',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Application tips
              if (result.applicationTips.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: const Color(0xFF4CAF50),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dicas de Aplicação',
                            style: TextStyle(
                              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...result.applicationTips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: const Color(0xFF4CAF50),
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatShareText() {
    final buffer = StringBuffer();
    buffer.writeln('📊 CALDA DE PULVERIZAÇÃO');
    buffer.writeln('');
    buffer.writeln('🌾 Parâmetros:');
    buffer.writeln('Área: ${result.areaToSpray.toStringAsFixed(1)} ha');
    buffer.writeln(
        'Volume de calda: ${result.applicationRate.toStringAsFixed(1)} L/ha');
    buffer.writeln(
        'Capacidade do tanque: ${result.tankCapacity.toStringAsFixed(0)} L');
    buffer.writeln('');
    buffer.writeln('📈 Resultado:');
    buffer.writeln(
        'Volume total: ${result.totalSprayVolume.toStringAsFixed(1)} L');
    buffer.writeln('Número de tanques: ${result.numberOfTanks}');
    buffer.writeln('');
    buffer.writeln('💧 Por Tanque:');
    buffer.writeln('Água: ${result.waterPerTank.toStringAsFixed(1)} L');
    for (final product in result.productsPerTank) {
      buffer.writeln(
          '${product.productName}: ${product.quantityPerTank.toStringAsFixed(2)} ${SprayMixCalculator.getUnitLabel(product.unit)}');
    }

    return buffer.toString();
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: highlight ? 0.9 : 0.7) : Colors.black.withValues(alpha: highlight ? 0.9 : 0.7),
            fontSize: highlight ? 15 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFF4CAF50) : (isDark ? Colors.white70 : Colors.black54),
            fontSize: highlight ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


