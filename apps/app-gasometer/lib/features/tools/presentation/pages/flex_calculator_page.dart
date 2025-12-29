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

  void _clear() {
    setState(() {
      _alcoholController.clear();
      _gasolineController.clear();
      _alcoholPrice = null;
      _gasolinePrice = null;
      _result = null;
      _useAlcohol = null;
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
                    if (_result != null) ...[
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
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Álcool field
            TextField(
              controller: _alcoholController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Preço do Álcool',
                prefixText: 'R\$ ',
                hintText: '0,00',
                prefixIcon: Icon(Icons.local_gas_station, color: Colors.green.shade700),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _alcoholPrice = double.tryParse(value.replaceAll(',', '.'));
                });
              },
            ),
            const SizedBox(height: 16),
            // Gasolina field
            TextField(
              controller: _gasolineController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Preço da Gasolina',
                prefixText: 'R\$ ',
                hintText: '0,00',
                prefixIcon: Icon(Icons.local_gas_station, color: Colors.orange.shade700),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _gasolinePrice = double.tryParse(value.replaceAll(',', '.'));
                });
              },
            ),
            const SizedBox(height: 20),
            // Botões
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
    final useAlcohol = _useAlcohol!;
    final color = useAlcohol ? Colors.green : Colors.orange;
    final icon = useAlcohol ? Icons.check_circle : Icons.info;
    
    final ratio = (_alcoholPrice! / _gasolinePrice!) * 100;

    return Card(
      elevation: 4,
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, color: color.shade700, size: 56),
            const SizedBox(height: 16),
            Text(
              _result!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Relação:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '${ratio.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Limite:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '70%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  'Como funciona?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'O álcool tem poder calorífico menor que a gasolina (rende cerca de 70%). '
              'Por isso, só compensa abastecer com álcool quando o preço for no máximo 70% do preço da gasolina.',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
