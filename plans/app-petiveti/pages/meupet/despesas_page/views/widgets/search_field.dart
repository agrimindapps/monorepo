// Flutter imports:
import 'package:flutter/material.dart';

class DespesasSearchField extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? hintText;
  final IconData? prefixIcon;

  const DespesasSearchField({
    super.key,
    required this.onSearchChanged,
    this.hintText,
    this.prefixIcon,
  });

  @override
  State<DespesasSearchField> createState() => _DespesasSearchFieldState();
}

class _DespesasSearchFieldState extends State<DespesasSearchField> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: widget.hintText ?? 'Pesquisar despesas',
          hintText: 'Digite para pesquisar...',
          prefixIcon: Icon(widget.prefixIcon ?? Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {}); // Para atualizar o suffixIcon
        },
      ),
    );
  }
}
