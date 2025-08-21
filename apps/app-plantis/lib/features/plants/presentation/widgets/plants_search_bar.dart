import 'package:flutter/material.dart';

class PlantsSearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isSearching;

  const PlantsSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.isSearching = false,
  });

  @override
  State<PlantsSearchBar> createState() => _PlantsSearchBarState();
}

class _PlantsSearchBarState extends State<PlantsSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar plantas...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon:
              widget.isSearching
                  ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                  : Icon(Icons.search, color: theme.colorScheme.primary),
          suffixIcon:
              widget.searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    onPressed: _clearSearch,
                    tooltip: 'Limpar busca',
                  )
                  : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _focusNode.unfocus(),
      ),
    );
  }
}
