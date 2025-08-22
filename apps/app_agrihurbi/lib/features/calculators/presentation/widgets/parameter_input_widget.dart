import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/calculator_parameter.dart';

/// Widget para entrada de parâmetros de calculadora
/// 
/// Renderiza diferentes tipos de input baseado no tipo do parâmetro
/// Inclui validação e formatação adequada para cada tipo
class ParameterInputWidget extends StatefulWidget {
  final CalculatorParameter parameter;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const ParameterInputWidget({
    super.key,
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ParameterInputWidget> createState() => _ParameterInputWidgetState();
}

class _ParameterInputWidgetState extends State<ParameterInputWidget> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(ParameterInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com indicador de obrigatório
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.parameter.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.parameter.required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Descrição do parâmetro
        if (widget.parameter.description.isNotEmpty)
          Text(
            widget.parameter.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

        const SizedBox(height: 8),

        // Input específico por tipo
        _buildInputWidget(),

        // Texto de erro
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],

        // Informações adicionais (min/max, unidade)
        _buildHelpText(),
      ],
    );
  }

  Widget _buildInputWidget() {
    switch (widget.parameter.type) {
      case ParameterType.number:
      case ParameterType.decimal:
        return _buildNumberInput();
      case ParameterType.percentage:
        return _buildPercentageInput();
      case ParameterType.text:
        return _buildTextInput();
      case ParameterType.selection:
        return _buildSelectionInput();
      case ParameterType.boolean:
        return _buildBooleanInput();
      case ParameterType.date:
        return _buildDateInput();
      case ParameterType.area:
      case ParameterType.volume:
      case ParameterType.weight:
        return _buildMeasurementInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildNumberInput() {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.parameter.type == ParameterType.decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (widget.parameter.type == ParameterType.number)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: widget.parameter.defaultValue?.toString(),
        suffixText: _getUnitSymbol(),
        border: const OutlineInputBorder(),
        errorText: _errorText,
      ),
      validator: (value) => _validateInput(value),
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildPercentageInput() {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: widget.parameter.defaultValue?.toString(),
        suffixText: '%',
        border: const OutlineInputBorder(),
        errorText: _errorText,
        helperText: '0 - 100',
      ),
      validator: (value) => _validateInput(value),
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.parameter.defaultValue?.toString(),
        border: const OutlineInputBorder(),
        errorText: _errorText,
      ),
      validator: (value) => _validateInput(value),
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildSelectionInput() {
    return DropdownButtonFormField<String>(
      value: widget.value?.toString(),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: _errorText,
      ),
      items: widget.parameter.options?.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      validator: (value) => _validateInput(value),
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildBooleanInput() {
    return SwitchListTile(
      title: Text(widget.parameter.name),
      subtitle: Text(widget.parameter.description),
      value: widget.value == true,
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildDateInput() {
    return InkWell(
      onTap: () => _selectDate(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.value != null
                    ? _formatDate(widget.value)
                    : 'Selecionar data',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.value != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInput() {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: widget.parameter.defaultValue?.toString(),
        suffixText: _getUnitSymbol(),
        border: const OutlineInputBorder(),
        errorText: _errorText,
      ),
      validator: (value) => _validateInput(value),
      onChanged: (value) => _handleValueChanged(value),
    );
  }

  Widget _buildHelpText() {
    final helpTexts = <String>[];

    if (widget.parameter.minValue != null || widget.parameter.maxValue != null) {
      if (widget.parameter.minValue != null && widget.parameter.maxValue != null) {
        helpTexts.add('${widget.parameter.minValue} - ${widget.parameter.maxValue}');
      } else if (widget.parameter.minValue != null) {
        helpTexts.add('Mínimo: ${widget.parameter.minValue}');
      } else if (widget.parameter.maxValue != null) {
        helpTexts.add('Máximo: ${widget.parameter.maxValue}');
      }
    }

    if (widget.parameter.unit != ParameterUnit.none && 
        widget.parameter.type != ParameterType.percentage) {
      helpTexts.add('Unidade: ${_getUnitSymbol()}');
    }

    if (helpTexts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        helpTexts.join(' • '),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String? _validateInput(dynamic value) {
    if (!widget.parameter.isValid(value)) {
      if (widget.parameter.required && (value == null || value.toString().isEmpty)) {
        return '${widget.parameter.name} é obrigatório';
      }
      return widget.parameter.validationMessage ?? 'Valor inválido';
    }
    return null;
  }

  void _handleValueChanged(dynamic value) {
    setState(() {
      _errorText = _validateInput(value);
    });
    widget.onChanged(value);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.value is DateTime 
          ? widget.value 
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      _handleValueChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  String _getUnitSymbol() {
    switch (widget.parameter.unit) {
      case ParameterUnit.hectare:
        return 'ha';
      case ParameterUnit.metro2:
        return 'm²';
      case ParameterUnit.acre:
        return 'acre';
      case ParameterUnit.litro:
        return 'L';
      case ParameterUnit.metro3:
        return 'm³';
      case ParameterUnit.kg:
        return 'kg';
      case ParameterUnit.tonelada:
        return 't';
      case ParameterUnit.gramas:
        return 'g';
      case ParameterUnit.metro:
        return 'm';
      case ParameterUnit.centimetro:
        return 'cm';
      case ParameterUnit.kilometro:
        return 'km';
      case ParameterUnit.percentual:
        return '%';
      case ParameterUnit.dia:
        return 'dias';
      case ParameterUnit.mes:
        return 'meses';
      case ParameterUnit.ano:
        return 'anos';
      case ParameterUnit.celsius:
        return '°C';
      case ParameterUnit.bar:
        return 'bar';
      case ParameterUnit.atm:
        return 'atm';
      case ParameterUnit.ppm:
        return 'ppm';
      case ParameterUnit.mgL:
        return 'mg/L';
      case ParameterUnit.quilograma:
        return 'kg';
      case ParameterUnit.grama:
        return 'g';
      case ParameterUnit.litrodia:
        return 'L/dia';
      case ParameterUnit.kgdia:
        return 'kg/dia';
      case ParameterUnit.plantasha:
        return 'plantas/ha';
      case ParameterUnit.cabecas:
        return 'cabeças';
      case ParameterUnit.mcalkg:
        return 'Mcal/kg';
      case ParameterUnit.mmh:
        return 'mm/h';
      case ParameterUnit.milimetro:
        return 'mm';
      case ParameterUnit.cmolcdm3:
        return 'cmolc/dm³';
      case ParameterUnit.mgdm3:
        return 'mg/dm³';
      case ParameterUnit.litroha:
        return 'L/ha';
      case ParameterUnit.gcm3:
        return 'g/cm³';
      case ParameterUnit.dsm:
        return 'dS/m';
      case ParameterUnit.escore:
        return 'escore';
      case ParameterUnit.ratio:
        return ':1';
      case ParameterUnit.integer:
        return '';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}