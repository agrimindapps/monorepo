// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../services/formatters/medicoes_formatters.dart';

class QuantidadeSectionWidget extends StatefulWidget {
  final double quantidade;
  final Function(double) onQuantidadeChanged;

  const QuantidadeSectionWidget({
    super.key,
    required this.quantidade,
    required this.onQuantidadeChanged,
  });

  @override
  State<QuantidadeSectionWidget> createState() =>
      _QuantidadeSectionWidgetState();
}

class _QuantidadeSectionWidgetState extends State<QuantidadeSectionWidget> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isEditingText = false;

  static final _formatter = MedicoesFormatters();

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.quantidade.toStringAsFixed(1));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditingText) {
      _validateAndUpdateFromText();
    }
  }

  void _validateAndUpdateFromText() {
    final text = _textController.text.replaceAll(',', '.');
    final value = double.tryParse(text);

    if (value != null && value >= 0 && value <= 500) {
      widget.onQuantidadeChanged(value);
      setState(() {
        _isEditingText = false;
      });
    } else {
      // Reset to current value if invalid
      _textController.text = widget.quantidade.toStringAsFixed(1);
      setState(() {
        _isEditingText = false;
      });

      // Show error feedback
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor deve estar entre 0 e 500 mm'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  double get _maxRange {
    // Range adaptativo baseado no valor atual
    if (widget.quantidade <= 10) return 20;
    if (widget.quantidade <= 50) return 100;
    if (widget.quantidade <= 100) return 200;
    return 500;
  }

  @override
  Widget build(BuildContext context) {
    // Atualizar controller quando quantidade muda externamente
    if (!_isEditingText) {
      _textController.text = widget.quantidade.toStringAsFixed(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Quantidade (mm)',
          style: ShadcnStyle.labelStyle,
        ),
        const SizedBox(height: 8),

        // Input direto com validação
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Input de texto
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.0',
                    isDense: true,
                  ),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  onTap: () {
                    setState(() {
                      _isEditingText = true;
                    });
                  },
                  onSubmitted: (value) {
                    _validateAndUpdateFromText();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text('mm', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Botões de incremento rápido
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton('0.5', 0.5),
            _buildPresetButton('1.0', 1.0),
            _buildPresetButton('5.0', 5.0),
            _buildPresetButton('10.0', 10.0),
          ],
        ),

        const SizedBox(height: 16),

        // Slider melhorado
        SliderTheme(
          data: ShadcnStyle.sliderTheme.copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: widget.quantidade.clamp(0.0, _maxRange),
            min: 0.0,
            max: _maxRange,
            divisions: (_maxRange * 10).round(),
            label: _formatter.formatQuantidade(widget.quantidade),
            onChanged: (value) {
              HapticFeedback.selectionClick();
              widget.onQuantidadeChanged(value);
            },
          ),
        ),

        // Indicadores de range
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 mm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('${_maxRange.toStringAsFixed(0)} mm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),

        // Botões de incremento/decremento
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIncrementButton('-1', -1),
            _buildIncrementButton('-0.1', -0.1),
            const SizedBox(width: 20),
            _buildIncrementButton('+0.1', 0.1),
            _buildIncrementButton('+1', 1),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, double value) {
    final isSelected = (widget.quantidade - value).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onQuantidadeChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementButton(String label, double increment) {
    final newValue = widget.quantidade + increment;
    final isEnabled = newValue >= 0 && newValue <= 500;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onQuantidadeChanged(newValue);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? Colors.blue[300]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.blue[700] : Colors.grey[500],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
