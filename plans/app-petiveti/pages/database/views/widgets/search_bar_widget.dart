// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/database_controller.dart';
import '../../utils/database_helpers.dart';

class SearchBarWidget extends StatefulWidget {
  final DatabaseController controller;

  const SearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
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
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildSearchInfo(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: DatabaseHelpers.getSearchDecoration().copyWith(
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

  Widget _buildSearchInfo() {
    if (!widget.controller.hasData) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.controller.isFiltered ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.controller.isFiltered ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.controller.isFiltered) ...[
            Icon(
              Icons.filter_list,
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.controller.filteredRecords}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            Text(
              'filtrados',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[600],
              ),
            ),
          ] else ...[
            Icon(
              Icons.list,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.controller.totalRecords}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'total',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many updates
    Future.delayed(const Duration(milliseconds: 300), () {
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
