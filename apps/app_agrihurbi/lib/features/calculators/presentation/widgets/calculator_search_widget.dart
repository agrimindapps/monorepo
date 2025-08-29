import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';

/// Widget de busca para calculadoras
/// 
/// Reutiliza o padrão estabelecido no sistema livestock
/// Implementa busca em tempo real com debounce
class CalculatorSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;

  const CalculatorSearchWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar...',
  });

  @override
  State<CalculatorSearchWidget> createState() => _CalculatorSearchWidgetState();
}

class _CalculatorSearchWidgetState extends State<CalculatorSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}