import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../../../core/theme/spacing_tokens.dart';
import '../../../../../diagnosticos/presentation/providers/diagnosticos_notifier.dart';

/// Widget responsável pelos filtros de diagnósticos
///
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
class DiagnosticoDefensivoFilterWidget extends ConsumerStatefulWidget {
  final List<String>? availableCulturas;

  const DiagnosticoDefensivoFilterWidget({super.key, this.availableCulturas});

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
    final diagnosticosAsync = ref.watch(diagnosticosNotifierProvider);

    return RepaintBoundary(
      child: diagnosticosAsync.when(
        data: (diagnosticosState) {
          // Usa culturas passadas ou extrai dos diagnósticos como fallback
          final List<String> availableCulturas;
          if (widget.availableCulturas != null &&
              widget.availableCulturas!.isNotEmpty) {
            availableCulturas = ['Todas', ...widget.availableCulturas!];
          } else {
            final diagnosticosParaCulturas =
                diagnosticosState.searchQuery.isNotEmpty
                    ? diagnosticosState.searchResults
                    : diagnosticosState.filteredDiagnosticos;

            final culturasFromDiagnosticos =
                diagnosticosParaCulturas
                    .map((d) => d.nomeCultura)
                    .where((cultura) => cultura != null && cultura.isNotEmpty)
                    .cast<String>()
                    .toSet()
                    .toList()
                  ..sort();

            availableCulturas =
                culturasFromDiagnosticos.isEmpty
                    ? ['Todas']
                    : ['Todas', ...culturasFromDiagnosticos];
          }

          final selectedCultura = diagnosticosState.contextoCultura ?? 'Todas';

          return Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            child: Row(
              children: [
                Expanded(
                  flex: _isSearchFocused ? 2 : 1,
                  child: SearchField(
                    focusNode: _searchFocusNode,
                    onChanged: (query) {
                      ref
                          .read(diagnosticosNotifierProvider.notifier)
                          .searchByPattern(query);
                    },
                  ),
                ),
                if (!_isSearchFocused) ...[
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    flex: 1,
                    child: CultureDropdown(
                      value: selectedCultura,
                      cultures: availableCulturas,
                      onChanged: (cultura) {
                        if (cultura == 'Todas') {
                          ref
                              .read(diagnosticosNotifierProvider.notifier)
                              .filterByCultura(null);
                        } else {
                          ref
                              .read(diagnosticosNotifierProvider.notifier)
                              .filterByCultura(cultura);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading:
            () => Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: const Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, _) => Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              child: const SearchField(focusNode: null, onChanged: null),
            ),
      ),
    );
  }
}

/// Campo de busca personalizado
class SearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const SearchField({super.key, required this.onChanged, required this.focusNode});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        onChanged: widget.onChanged,
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
        value: value,
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
        items: [
          DropdownMenuItem<String>(
            value: 'Todas',
            child: Text(
              'Todas',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...cultures
              .where((culture) => culture != 'Todas')
              .map<DropdownMenuItem<String>>((String culture) {
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
              }),
        ],
      ),
    );
  }
}
