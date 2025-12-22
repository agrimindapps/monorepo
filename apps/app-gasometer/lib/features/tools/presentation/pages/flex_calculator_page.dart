import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/semantic_widgets.dart';

/// Flex Calculator page - calculates if alcohol or gasoline is more economical
class FlexCalculatorPage extends StatefulWidget {
  const FlexCalculatorPage({super.key});

  @override
  State<FlexCalculatorPage> createState() => _FlexCalculatorPageState();
}

class _FlexCalculatorPageState extends State<FlexCalculatorPage> {
  final _alcoholController = TextEditingController();
  final _gasolineController = TextEditingController();

  double? _alcoholPrice;
  double? _gasolinePrice;
  String? _result;
  bool? _useAlcohol;

  @override
  void dispose() {
    _alcoholController.dispose();
    _gasolineController.dispose();
    super.dispose();
  }

  void _calculate() {
    final alcohol = _alcoholPrice;
    final gasoline = _gasolinePrice;

    if (alcohol == null || gasoline == null || gasoline == 0) {
      setState(() {
        _result = null;
        _useAlcohol = null;
      });
      return;
    }

    // Rule: if alcohol <= 70% of gasoline price, use alcohol
    final ratio = alcohol / gasoline;
    final threshold = 0.70;

    setState(() {
      if (ratio <= threshold) {
        _useAlcohol = true;
        _result = 'Abasteça com ÁLCOOL';
      } else {
        _useAlcohol = false;
        _result = 'Abasteça com GASOLINA';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildPriceInputs(),
                    const SizedBox(height: 24),
                    if (_result != null) _buildResult(),
                    const SizedBox(height: 16),
                    _buildExplanation(),
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
                Icons.calculate,
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
                    'Calculadora Flex',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Álcool ou Gasolina?',
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Informe os preços dos combustíveis para descobrir qual compensa mais',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInputs() {
    return Column(
      children: [
        // Alcohol input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_gas_station, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Preço do Álcool',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _alcoholController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _alcoholPrice = double.tryParse(value.replaceAll(',', '.'));
                  });
                  _calculate();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Gasoline input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_gas_station, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Preço da Gasolina',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _gasolineController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _gasolinePrice = double.tryParse(value.replaceAll(',', '.'));
                  });
                  _calculate();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final useAlcohol = _useAlcohol!;
    final color = useAlcohol ? Colors.green : Colors.orange;
    final icon = useAlcohol ? Icons.check_circle : Icons.info;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade700, size: 48),
          const SizedBox(height: 12),
          Text(
            _result!,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildCalculationDetails(),
        ],
      ),
    );
  }

  Widget _buildCalculationDetails() {
    if (_alcoholPrice == null || _gasolinePrice == null) return const SizedBox.shrink();

    final ratio = (_alcoholPrice! / _gasolinePrice!) * 100;
    final threshold = 70.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Relação Álcool/Gasolina:'),
              Text(
                '${ratio.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Limite para compensar:'),
              Text(
                '${threshold.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Como funciona?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'O álcool tem poder calorífico menor que a gasolina (rende cerca de 70%). '
            'Por isso, só compensa abastecer com álcool quando o preço for no máximo 70% do preço da gasolina.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Regra: Álcool ≤ 70% da Gasolina = Compensa',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
