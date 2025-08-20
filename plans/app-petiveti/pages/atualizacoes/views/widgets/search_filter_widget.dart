// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/atualizacoes_controller.dart';
import '../../utils/atualizacoes_constants.dart';

class SearchFilterWidget extends StatefulWidget {
  final AtualizacoesController controller;

  const SearchFilterWidget({
    super.key,
    required this.controller,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.controller.searchTerm);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AtualizacoesConstants.searchHint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        suffixIcon: widget.controller.searchTerm.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : null,
      ),
      onChanged: _onSearchChanged,
      onSubmitted: _onSearchSubmitted,
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      onPressed: () => widget.controller.showFilterDialog(context),
      tooltip: AtualizacoesConstants.filterTooltip,
      icon: Icon(
        widget.controller.isFiltered ? Icons.filter_alt : Icons.filter_alt_outlined,
        color: widget.controller.isFiltered ? AtualizacoesConstants.featureColor : null,
      ),
    );
  }

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many updates
    Future.delayed(AtualizacoesConstants.searchDebounceDelay, () {
      if (_searchController.text == value) {
        widget.controller.updateSearchTerm(value);
      }
    });
  }

  void _onSearchSubmitted(String value) {
    widget.controller.updateSearchTerm(value);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.controller.clearSearch();
  }
}
