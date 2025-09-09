import 'package:flutter/material.dart';

import 'diagnostico_mockup_tokens.dart';

/// Widget que replica EXATAMENTE o design dos filtros do mockup IMG_3186.PNG
/// 
/// Layout do mockup analisado:
/// - Row com 2 campos flexíveis
/// - Campo esquerdo: "Localizar" com ícone lupa verde
/// - Campo direito: "Todas" com ícone calendário verde
/// - Background branco, bordas sutis
/// - Border radius específico
/// 
/// Responsabilidade única: renderizar filtros superiores pixel-perfect
class FiltersMockupWidget extends StatelessWidget {
  final String searchText;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final List<String> filterOptions;

  const FiltersMockupWidget({
    super.key,
    required this.searchText,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.filterOptions,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Campo de busca "Localizar"
            Expanded(
              flex: 1,
              child: _SearchFieldMockup(
                text: searchText,
                onChanged: onSearchChanged,
              ),
            ),
            
            const SizedBox(width: 12), // Espaçamento entre campos
            
            // Dropdown "Todas" 
            Expanded(
              flex: 1,
              child: _FilterDropdownMockup(
                value: selectedFilter,
                options: filterOptions,
                onChanged: onFilterChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de busca "Localizar" exatamente como no mockup
class _SearchFieldMockup extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;

  const _SearchFieldMockup({
    required this.text,
    required this.onChanged,
  });

  @override
  State<_SearchFieldMockup> createState() => _SearchFieldMockupState();
}

class _SearchFieldMockupState extends State<_SearchFieldMockup> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(_SearchFieldMockup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DiagnosticoMockupTokens.filterHeight,
      decoration: BoxDecoration(
        color: DiagnosticoMockupTokens.cardBackground,
        borderRadius: BorderRadius.circular(
          DiagnosticoMockupTokens.cardBorderRadius,
        ),
        border: Border.all(
          color: DiagnosticoMockupTokens.filterBorderColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: DiagnosticoMockupTokens.filterHintStyle.copyWith(
          color: DiagnosticoMockupTokens.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: DiagnosticoMockupTokens.searchPlaceholder,
          hintStyle: DiagnosticoMockupTokens.filterHintStyle,
          prefixIcon: Icon(
            DiagnosticoMockupTokens.searchIcon,
            color: DiagnosticoMockupTokens.primaryGreen,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: DiagnosticoMockupTokens.filterPadding,
        ),
      ),
    );
  }
}

/// Dropdown "Todas" exatamente como no mockup  
class _FilterDropdownMockup extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdownMockup({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DiagnosticoMockupTokens.filterHeight,
      decoration: BoxDecoration(
        color: DiagnosticoMockupTokens.cardBackground,
        borderRadius: BorderRadius.circular(
          DiagnosticoMockupTokens.cardBorderRadius,
        ),
        border: Border.all(
          color: DiagnosticoMockupTokens.filterBorderColor,
          width: 1,
        ),
      ),
      padding: DiagnosticoMockupTokens.filterPadding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          isExpanded: true,
          icon: Icon(
            DiagnosticoMockupTokens.dropdownIcon,
            color: DiagnosticoMockupTokens.primaryGreen,
            size: 18,
          ),
          style: DiagnosticoMockupTokens.filterHintStyle.copyWith(
            color: DiagnosticoMockupTokens.textPrimary,
          ),
          items: options.map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: DiagnosticoMockupTokens.filterHintStyle.copyWith(
                  color: DiagnosticoMockupTokens.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Widget wrapper para integração com provider existente
class FiltersMockupProviderWrapper extends StatelessWidget {
  final Widget Function(
    String searchText,
    String selectedFilter, 
    ValueChanged<String> onSearchChanged,
    ValueChanged<String> onFilterChanged,
    List<String> filterOptions,
  ) builder;

  const FiltersMockupProviderWrapper({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar com provider real
    // Por enquanto, dados mockados para demonstração
    return builder(
      '', // searchText
      'Todas', // selectedFilter  
      (value) {}, // onSearchChanged
      (value) {}, // onFilterChanged
      ['Todas', 'Arroz', 'Braquiária', 'Cana-de-açúcar'], // filterOptions
    );
  }
}

/// Factory para criar diferentes configurações de filtros
class FiltersMockupFactory {
  /// Cria filtros básicos como no mockup
  static Widget basic({
    required String searchText,
    required String selectedFilter,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String> onFilterChanged,
    required List<String> filterOptions,
  }) {
    return FiltersMockupWidget(
      searchText: searchText,
      selectedFilter: selectedFilter,
      onSearchChanged: onSearchChanged,
      onFilterChanged: onFilterChanged,
      filterOptions: filterOptions,
    );
  }

  /// Cria filtros com provider wrapper
  static Widget withProvider() {
    return FiltersMockupProviderWrapper(
      builder: (searchText, selectedFilter, onSearchChanged, onFilterChanged, filterOptions) {
        return FiltersMockupWidget(
          searchText: searchText,
          selectedFilter: selectedFilter,
          onSearchChanged: onSearchChanged,
          onFilterChanged: onFilterChanged,
          filterOptions: filterOptions,
        );
      },
    );
  }

  /// Cria filtros com opções customizadas
  static Widget withCustomOptions({
    required List<String> customOptions,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String> onFilterChanged,
  }) {
    return FiltersMockupWidget(
      searchText: '',
      selectedFilter: customOptions.isNotEmpty ? customOptions.first : 'Todas',
      onSearchChanged: onSearchChanged,
      onFilterChanged: onFilterChanged,
      filterOptions: customOptions,
    );
  }
}