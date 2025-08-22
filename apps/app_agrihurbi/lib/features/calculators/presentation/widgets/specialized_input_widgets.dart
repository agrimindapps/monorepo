import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/calculator_parameter.dart';

/// Widget especializado para entrada de coordenadas (GPS)
class CoordinateInputWidget extends StatefulWidget {
  final String label;
  final LatLng? value;
  final ValueChanged<LatLng?> onChanged;
  final bool required;

  const CoordinateInputWidget({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.required = false,
  });

  @override
  State<CoordinateInputWidget> createState() => _CoordinateInputWidgetState();
}

class _CoordinateInputWidgetState extends State<CoordinateInputWidget> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _latController.text = widget.value!.latitude.toStringAsFixed(6);
      _lngController.text = widget.value!.longitude.toStringAsFixed(6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.required)
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: '-23.550520',
                  border: OutlineInputBorder(),
                ),
                onChanged: _updateCoordinates,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-46.633308',
                  border: OutlineInputBorder(),
                ),
                onChanged: _updateCoordinates,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Formato: -23.550520, -46.633308',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _updateCoordinates(String _) {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    
    if (lat != null && lng != null) {
      widget.onChanged(LatLng(lat, lng));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}

/// Widget para entrada de faixa de valores (min/max)
class RangeInputWidget extends StatefulWidget {
  final String label;
  final ValueRange? value;
  final ValueChanged<ValueRange?> onChanged;
  final double? minLimit;
  final double? maxLimit;
  final String? unit;
  final bool required;

  const RangeInputWidget({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.minLimit,
    this.maxLimit,
    this.unit,
    this.required = false,
  });

  @override
  State<RangeInputWidget> createState() => _RangeInputWidgetState();
}

class _RangeInputWidgetState extends State<RangeInputWidget> {
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _minController.text = widget.value!.min.toString();
      _maxController.text = widget.value!.max.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.required)
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Mínimo',
                  suffixText: widget.unit,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _updateRange,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('até'),
            ),
            Expanded(
              child: TextFormField(
                controller: _maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Máximo',
                  suffixText: widget.unit,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _updateRange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateRange(String _) {
    final min = double.tryParse(_minController.text);
    final max = double.tryParse(_maxController.text);
    
    if (min != null && max != null && min <= max) {
      widget.onChanged(ValueRange(min, max));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }
}

/// Widget para entrada de múltiplas opções (checkboxes)
class MultiSelectionWidget extends StatefulWidget {
  final String label;
  final List<String> options;
  final List<String>? selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool required;
  final int? maxSelections;

  const MultiSelectionWidget({
    super.key,
    required this.label,
    required this.options,
    this.selectedValues,
    required this.onChanged,
    this.required = false,
    this.maxSelections,
  });

  @override
  State<MultiSelectionWidget> createState() => _MultiSelectionWidgetState();
}

class _MultiSelectionWidgetState extends State<MultiSelectionWidget> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.selectedValues ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.required)
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
        const SizedBox(height: 8),
        ...widget.options.map((option) {
          final isSelected = _selectedValues.contains(option);
          final canSelect = widget.maxSelections == null || 
              _selectedValues.length < widget.maxSelections! || 
              isSelected;

          return CheckboxListTile(
            value: isSelected,
            title: Text(option),
            onChanged: canSelect ? (value) {
              setState(() {
                if (value == true) {
                  _selectedValues.add(option);
                } else {
                  _selectedValues.remove(option);
                }
              });
              widget.onChanged(_selectedValues);
            } : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
        if (widget.maxSelections != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Máximo ${widget.maxSelections} seleções',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para entrada de dados em slider com valor numérico
class SliderInputWidget extends StatefulWidget {
  final String label;
  final double? value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? unit;
  final bool required;

  const SliderInputWidget({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.divisions,
    this.unit,
    this.required = false,
  });

  @override
  State<SliderInputWidget> createState() => _SliderInputWidgetState();
}

class _SliderInputWidgetState extends State<SliderInputWidget> {
  final _controller = TextEditingController();
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value ?? widget.min;
    _controller.text = _currentValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.required)
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _currentValue,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: '${_currentValue}${widget.unit ?? ''}',
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                    _controller.text = value.toStringAsFixed(
                      widget.divisions != null ? 0 : 1,
                    );
                  });
                  widget.onChanged(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  suffixText: widget.unit,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                onChanged: (value) {
                  final numValue = double.tryParse(value);
                  if (numValue != null && 
                      numValue >= widget.min && 
                      numValue <= widget.max) {
                    setState(() {
                      _currentValue = numValue;
                    });
                    widget.onChanged(numValue);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.min}${widget.unit ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${widget.max}${widget.unit ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Classes auxiliares
class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  @override
  String toString() => '($latitude, $longitude)';
}

class ValueRange {
  final double min;
  final double max;

  ValueRange(this.min, this.max);

  @override
  String toString() => '$min - $max';
}