import 'package:flutter/material.dart';

/// ✅ UX ENHANCEMENT: Enhanced dropdown with better UX and validation
class EnhancedDropdown<T> extends StatefulWidget {

  const EnhancedDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.hint,
    this.value,
    this.required = false,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.helperText,
    this.maxHeight = 300,
    this.searchable = false,
    this.searchFilter,
  });
  final String label;
  final String? hint;
  final T? value;
  final List<EnhancedDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool required;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;
  final String? helperText;
  final double? maxHeight;
  final bool searchable;
  final String Function(T)? searchFilter;

  @override
  State<EnhancedDropdown<T>> createState() => _EnhancedDropdownState<T>();
}

class _EnhancedDropdownState<T> extends State<EnhancedDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<EnhancedDropdownItem<T>> _filteredItems = [];
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(EnhancedDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: _buildDropdownField(),
        ),
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: 4),
          _buildHelperText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.required)
          Text(
            ' *',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField() {
    final bool hasError = widget.errorText != null;
    final T? currentValue = widget.value;
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == currentValue,
      orElse: () => EnhancedDropdownItem<T>(value: currentValue, child: const Text('Valor inválido')),
    );

    return InkWell(
      onTap: widget.enabled ? _toggleDropdown : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: widget.enabled
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.surface)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? Theme.of(context).colorScheme.error
                : _isExpanded
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            width: hasError ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              widget.prefixIcon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: currentValue != null
                  ? DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: widget.enabled
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      child: selectedItem.child,
                    )
                  : Text(
                      widget.hint ?? 'Selecione uma opção',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
            ),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: widget.enabled
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    final bool hasError = widget.errorText != null;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        hasError ? widget.errorText! : widget.helperText!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: hasError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled) return;
    
    setState(() {
      _isExpanded = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isExpanded) return;
    
    setState(() {
      _isExpanded = false;
    });

    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredItems = widget.items;
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
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight!,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.searchable) _buildSearchField(),
                  Flexible(
                    child: _buildItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildItemsList() {
    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 32,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum item encontrado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = item.value == widget.value;

        return InkWell(
          onTap: () {
            widget.onChanged?.call(item.value);
            _closeDropdown();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    child: item.child,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {});
    
    if (query.isEmpty) {
      _filteredItems = widget.items;
    } else {
      _filteredItems = widget.items.where((item) {
        if (widget.searchFilter != null) {
          return widget.searchFilter!(item.value as T)
              .toLowerCase()
              .contains(query.toLowerCase());
        }
        final childText = _extractTextFromWidget(item.child);
        return childText.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    _overlayEntry?.markNeedsBuild();
  }

  String _extractTextFromWidget(Widget widget) {
    if (widget is Text) {
      return widget.data ?? '';
    } else if (widget is RichText) {
      return widget.text.toPlainText();
    }
    return '';
  }
}

/// Data class for dropdown items
class EnhancedDropdownItem<T> {

  const EnhancedDropdownItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });
  final T? value;
  final Widget child;
  final bool enabled;
}

/// Pre-built vehicle dropdown for common use case
class VehicleDropdown extends StatelessWidget {

  const VehicleDropdown({
    super.key,
    required this.vehicles,
    required this.onChanged,
    this.selectedVehicleId,
    this.required = false,
    this.errorText,
  });
  final String? selectedVehicleId;
  final ValueChanged<String?> onChanged;
  final List<VehicleDropdownData> vehicles;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return EnhancedDropdown<String>(
      label: 'Veículo',
      hint: 'Selecione o veículo',
      value: selectedVehicleId,
      required: required,
      errorText: errorText,
      searchable: vehicles.length > 5,
      prefixIcon: Icon(
        Icons.directions_car,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      items: vehicles.map((vehicle) => EnhancedDropdownItem<String>(
        value: vehicle.id,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (vehicle.year != null || vehicle.licensePlate != null)
              Text(
                '${vehicle.year ?? ''} ${vehicle.licensePlate != null ? '• ${vehicle.licensePlate}' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      )).toList(),
      searchFilter: (vehicleId) {
        final vehicle = vehicles.firstWhere((v) => v.id == vehicleId);
        return '${vehicle.brand} ${vehicle.model} ${vehicle.year ?? ''} ${vehicle.licensePlate ?? ''}';
      },
      onChanged: onChanged,
    );
  }
}

/// Data class for vehicle dropdown
class VehicleDropdownData {

  const VehicleDropdownData({
    required this.id,
    required this.brand,
    required this.model,
    this.year,
    this.licensePlate,
  });
  final String id;
  final String brand;
  final String model;
  final int? year;
  final String? licensePlate;
}
