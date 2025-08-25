import 'dart:async';

import 'package:flutter/material.dart';

/// Widget de busca reutilizável para livestock
/// 
/// Inclui debounce para otimizar performance durante digitação
/// Substitui os antigos widgets GetX de busca
class LivestockSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final Duration debounceDuration;
  final bool showClearButton;
  final IconData searchIcon;

  const LivestockSearchWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Buscar...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.showClearButton = true,
    this.searchIcon = Icons.search,
  });

  @override
  State<LivestockSearchWidget> createState() => _LivestockSearchWidgetState();
}

class _LivestockSearchWidgetState extends State<LivestockSearchWidget> {
  Timer? _debounceTimer;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _showClearButton = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {
      _showClearButton = widget.controller.text.isNotEmpty;
    });

    // Cancela timer anterior se existir
    _debounceTimer?.cancel();

    // Inicia novo timer para debounce
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(widget.controller.text);
    });
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            widget.searchIcon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: widget.showClearButton && _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => widget.onChanged?.call(value),
      ),
    );
  }
}

/// Widget de busca avançada com sugestões
/// 
/// Inclui dropdown com sugestões baseadas no histórico e dados existentes
class AdvancedLivestockSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final List<String> suggestions;
  final String hintText;
  final int maxSuggestions;

  const AdvancedLivestockSearchWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.suggestions = const [],
    this.hintText = 'Buscar...',
    this.maxSuggestions = 5,
  });

  @override
  State<AdvancedLivestockSearchWidget> createState() =>
      _AdvancedLivestockSearchWidgetState();
}

class _AdvancedLivestockSearchWidgetState
    extends State<AdvancedLivestockSearchWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showSuggestions();
    } else {
      _hideSuggestions();
    }
  }

  void _onTextChanged() {
    final query = widget.controller.text;
    
    if (query.isEmpty) {
      _filteredSuggestions = [];
    } else {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()))
          .take(widget.maxSuggestions)
          .toList();
    }

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }

    widget.onChanged?.call(query);
  }

  void _showSuggestions() {
    if (_overlayEntry != null || _filteredSuggestions.isEmpty) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      widget.controller.text = suggestion;
                      _hideSuggestions();
                      widget.onChanged?.call(suggestion);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: LivestockSearchWidget(
        controller: widget.controller,
        onChanged: widget.onChanged,
        hintText: widget.hintText,
        searchIcon: Icons.search,
      ),
    );
  }
}

/// Widget de busca rápida com filtros predefinidos
/// 
/// Inclui chips com filtros rápidos comuns
class QuickSearchWidget extends StatelessWidget {
  final ValueChanged<String>? onQuickSearch;
  final List<String> quickFilters;

  const QuickSearchWidget({
    super.key,
    this.onQuickSearch,
    this.quickFilters = const [
      'Leiteira',
      'Corte',
      'Brasil',
      'Holanda',
      'Nelore',
      'Gir',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              onSelected: (selected) {
                if (selected) {
                  onQuickSearch?.call(filter);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }
}

/// Widget de contador de resultados de busca
/// 
/// Mostra quantidade de resultados encontrados
class SearchResultsCounter extends StatelessWidget {
  final int totalResults;
  final int filteredResults;
  final String searchQuery;
  final bool hasActiveFilters;

  const SearchResultsCounter({
    super.key,
    required this.totalResults,
    required this.filteredResults,
    this.searchQuery = '',
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalResults == 0) return const SizedBox.shrink();

    String resultText;
    if (searchQuery.isNotEmpty || hasActiveFilters) {
      resultText = '$filteredResults de $totalResults resultados';
    } else {
      resultText = '$totalResults itens';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8.0),
          Text(
            resultText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (searchQuery.isNotEmpty || hasActiveFilters) ...[
            const Spacer(),
            TextButton(
              onPressed: () {
                // Callback para limpar filtros seria passado aqui
              },
              child: const Text('Limpar'),
            ),
          ],
        ],
      ),
    );
  }
}