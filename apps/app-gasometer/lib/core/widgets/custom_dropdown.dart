import 'package:flutter/material.dart';

/// Dropdown customizado com validação e formatação
class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.isExpanded = true,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = true,
    this.dropdownMaxHeight,
    this.disabledHint,
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;
  final double? dropdownMaxHeight;
  final Widget? disabledHint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      hint: hint != null ? Text(hint!) : null,
      disabledHint: disabledHint,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border ?? _defaultBorder(context),
        enabledBorder: enabledBorder ?? _defaultEnabledBorder(context),
        focusedBorder: focusedBorder ?? _defaultFocusedBorder(context),
        errorBorder: errorBorder ?? _defaultErrorBorder(context),
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        filled: filled,
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      menuMaxHeight: dropdownMaxHeight ?? 300,
      icon: const Icon(Icons.keyboard_arrow_down),
      iconSize: 24,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  InputBorder _defaultBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1,
      ),
    );
  }

  InputBorder _defaultEnabledBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }

  InputBorder _defaultFocusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    );
  }

  InputBorder _defaultErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    );
  }

  /// Factory constructor para dropdown simples com lista de strings
  static CustomDropdown<String> simple({
    Key? key,
    String? value,
    required List<String> options,
    void Function(String?)? onChanged,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return CustomDropdown<String>(
      key: key,
      value: value,
      items: options.map((String option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      prefixIcon: prefixIcon,
      validator: validator,
    );
  }

  /// Factory constructor para dropdown com objetos customizados
  static CustomDropdown<K> custom<K>({
    Key? key,
    K? value,
    required List<K> options,
    required String Function(K) getLabel,
    void Function(K?)? onChanged,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    Widget? prefixIcon,
    String? Function(K?)? validator,
    Widget Function(K)? buildItem,
  }) {
    return CustomDropdown<K>(
      key: key,
      value: value,
      items: options.map((K option) {
        return DropdownMenuItem<K>(
          value: option,
          child: buildItem?.call(option) ?? Text(getLabel(option)),
        );
      }).toList(),
      onChanged: onChanged,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      prefixIcon: prefixIcon,
      validator: validator,
    );
  }

  /// Factory constructor para dropdown com ícones
  static CustomDropdown<String> withIcons({
    Key? key,
    String? value,
    required Map<String, IconData> optionsWithIcons,
    void Function(String?)? onChanged,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return CustomDropdown<String>(
      key: key,
      value: value,
      items: optionsWithIcons.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(entry.value, size: 20),
              const SizedBox(width: 12),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      validator: validator,
    );
  }

  /// Factory constructor para dropdown de seleção múltipla simulada
  static CustomDropdown<String> multiSelect({
    Key? key,
    List<String>? selectedValues,
    required List<String> options,
    void Function(List<String>)? onChanged,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    Widget? prefixIcon,
  }) {
    final displayText = selectedValues?.isEmpty ?? true
        ? hint ?? 'Selecione opções'
        : '${selectedValues!.length} selecionados';

    return CustomDropdown<String>(
      key: key,
      value: displayText,
      items: [
        DropdownMenuItem<String>(value: displayText, child: Text(displayText)),
      ],
      onChanged: null, // Disable dropdown, use onTap instead
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      prefixIcon: prefixIcon,
    );
  }
}

/// Widget auxiliar para dropdown com busca
class SearchableDropdown<T> extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    this.value,
    required this.items,
    required this.getLabel,
    this.onChanged,
    this.label,
    this.hint,
    this.searchHint,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  });
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?)? onChanged;
  final String? label;
  final String? hint;
  final String? searchHint;
  final bool enabled;
  final Widget? prefixIcon;
  final String? Function(T?)? validator;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  List<T> filteredItems = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items.where((item) {
          return widget
              .getLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _showSearchDialog : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: widget.value != null
                ? widget.getLabel(widget.value as T)
                : '',
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Selecione uma opção',
            prefixIcon: widget.prefixIcon,
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
          ),
          enabled: widget.enabled,
          readOnly: true,
          validator: widget.validator != null
              ? (value) => widget.validator!(widget.value)
              : null,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    filteredItems = widget.items;
    searchController.clear();

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(widget.label ?? 'Selecionar'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setDialogState(() => _filterItems(value));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = widget.value == item;

                      return ListTile(
                        title: Text(widget.getLabel(item)),
                        selected: isSelected,
                        onTap: () {
                          widget.onChanged?.call(item);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
