// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/consulta_page_controller.dart';
import '../styles/consulta_page_styles.dart';

class ConsultaSearchBar extends StatefulWidget {
  final ConsultaPageController controller;

  const ConsultaSearchBar({
    super.key,
    required this.controller,
  });

  @override
  State<ConsultaSearchBar> createState() => _ConsultaSearchBarState();
}

class _ConsultaSearchBarState extends State<ConsultaSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.controller.searchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: ConsultaPageStyles.getSearchDecoration(
        hintText: 'Buscar por veterinário, motivo ou diagnóstico...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.controller.onSearchChanged('');
                },
              )
            : null,
      ),
      onChanged: (value) {
        widget.controller.onSearchChanged(value);
        setState(() {}); // Update to show/hide clear button
      },
      textInputAction: TextInputAction.search,
    );
  }
}
