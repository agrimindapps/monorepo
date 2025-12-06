import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../../../core/theme/spacing_tokens.dart';
import '../../../../../diagnosticos/presentation/providers/diagnosticos_by_entity_provider.dart';

/// Widget responsável pelos filtros de diagnósticos
///
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
///
/// **MIGRADO** - Agora usa `diagnosticosByEntityProvider` ao invés do deprecated
class DiagnosticoDefensivoFilterWidget extends ConsumerStatefulWidget {
  final List<String>? availableCulturas;
  final DiagnosticosByEntityParams? params;

  const DiagnosticoDefensivoFilterWidget({
    super.key,
    this.availableCulturas,
    this.params,
  });

  @override
  ConsumerState<DiagnosticoDefensivoFilterWidget> createState() =>
      _DiagnosticoDefensivoFilterWidgetState();
}

class _DiagnosticoDefensivoFilterWidgetState
    extends ConsumerState<DiagnosticoDefensivoFilterWidget> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se não tiver params, usa culturas passadas diretamente (modo standalone)
    if (widget.params == null) {
      return _buildStaticFilters(context);
    }

    final stateAsync = ref.watch(diagnosticosByEntityProvider(widget.params!));

    return RepaintBoundary(
      child: stateAsync.when(
        data: (state) {
          // Usa culturas passadas ou do estado
          final List<String> availableCulturas;
          if (widget.availableCulturas != null &&
              widget.availableCulturas!.isNotEmpty) {
            availableCulturas = ['Todas', ...widget.availableCulturas!];
          } else {
            availableCulturas = state.culturas;
          }

          return _buildFilterRow(
            context,
            availableCulturas: availableCulturas,
            selectedCultura: state.selectedCultura,
            onSearchChanged: (query) {
              ref
                  .read(diagnosticosByEntityProvider(widget.params!).notifier)
                  .updateSearchQuery(query);
            },
            onCulturaChanged: (cultura) {
              ref
                  .read(diagnosticosByEntityProvider(widget.params!).notifier)
                  .updateSelectedCultura(cultura);
            },
          );
        },
        loading: () => Container(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Container(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: const SearchField(focusNode: null, onChanged: null),
        ),
      ),
    );
  }

  /// Filtros estáticos quando não há params (modo standalone)
  Widget _buildStaticFilters(BuildContext context) {
    final availableCulturas = widget.availableCulturas != null &&
            widget.availableCulturas!.isNotEmpty
        ? ['Todas', ...widget.availableCulturas!]
        : ['Todas'];

    return _buildFilterRow(
      context,
      availableCulturas: availableCulturas,
      selectedCultura: 'Todas',
      onSearchChanged: null,
      onCulturaChanged: null,
    );
  }

  Widget _buildFilterRow(
    BuildContext context, {
    required List<String> availableCulturas,
    required String selectedCultura,
    required ValueChanged<String>? onSearchChanged,
    required ValueChanged<String>? onCulturaChanged,
  }) {
    // Garante valor válido
    final safeSelectedCultura = availableCulturas.contains(selectedCultura)
        ? selectedCultura
        : 'Todas';

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: Row(
        children: [
          Expanded(
            flex: _isSearchFocused ? 2 : 1,
            child: SearchField(
              focusNode: _searchFocusNode,
              onChanged: onSearchChanged,
            ),
          ),
          if (!_isSearchFocused) ...[
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              flex: 1,
              child: CultureDropdown(
                value: safeSelectedCultura,
                cultures: availableCulturas,
                onChanged: onCulturaChanged != null
                    ? (cultura) => onCulturaChanged(cultura)
                    : (_) {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Campo de busca personalizado com debounce
class SearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  /// Duração do debounce em milissegundos (padrão: 300ms)
  final int debounceDuration;

  const SearchField({
    super.key, 
    required this.onChanged, 
    required this.focusNode,
    this.debounceDuration = 300,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: widget.debounceDuration),
      () {
        if (mounted && widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: _onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Localizar',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

/// Dropdown de seleção de cultura
class CultureDropdown extends StatelessWidget {
  final String value;
  final List<String> cultures;
  final ValueChanged<String> onChanged;

  const CultureDropdown({
    super.key,
    required this.value,
    required this.cultures,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Remove duplicatas e garante ordem única
    final uniqueCultures = cultures.toSet().toList();
    
    // Garante que o valor selecionado existe na lista
    final safeValue = uniqueCultures.contains(value) ? value : 'Todas';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: safeValue,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.eco,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        items: uniqueCultures.map<DropdownMenuItem<String>>((String culture) {
          return DropdownMenuItem<String>(
            value: culture,
            child: Text(
              culture,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
