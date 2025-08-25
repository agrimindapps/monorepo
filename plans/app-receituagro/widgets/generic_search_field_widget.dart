// Flutter imports:
import 'package:flutter/material.dart';

enum SearchViewMode { grid, list }

class GenericSearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;
  final String hintText;
  final SearchViewMode? selectedViewMode;
  final Function(SearchViewMode)? onToggleViewMode;
  final Widget? Function(SearchViewMode selectedMode, bool isDark,
      Function(SearchViewMode) onModeChanged)? viewToggleBuilder;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final double? iconSize;
  final bool showViewToggle;
  final Function(String)? onChanged;
  final bool isSearching;
  final FocusNode? focusNode;

  const GenericSearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    this.hintText = 'Pesquisar...',
    this.selectedViewMode,
    this.onToggleViewMode,
    this.viewToggleBuilder,
    this.padding,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.hintColor,
    this.iconSize = 20.0,
    this.showViewToggle = true,
    this.onChanged,
    this.isSearching = false,
    this.focusNode,
  });

  @override
  State<GenericSearchFieldWidget> createState() => _GenericSearchFieldWidgetState();
}

class _GenericSearchFieldWidgetState extends State<GenericSearchFieldWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: DecoratedBox(
        decoration: _buildContainerDecoration(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              _buildSearchIcon(),
              const SizedBox(width: 12),
              _buildTextField(),
              _buildSuffixIcon(),
              if (widget.showViewToggle &&
                  widget.selectedViewMode != null &&
                  widget.onToggleViewMode != null) ...[
                _buildDivider(),
                _buildViewToggle(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    final bgColor = widget.backgroundColor ?? (widget.isDark ? const Color(0xFF1E1E22) : Colors.white);
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(widget.borderRadius!),
      border: null,
    );
  }

  Widget _buildSearchIcon() {
    final color = widget.iconColor ?? (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    return Icon(
      Icons.search,
      size: widget.iconSize,
      color: color,
    );
  }

  Widget _buildTextField() {
    final tColor = widget.textColor ?? (widget.isDark ? Colors.white : Colors.black87);
    final hColor = widget.hintColor ?? (widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600);

    try {
      final _ = widget.controller.text;
    } catch (e) {
      debugPrint('⚠️ GenericSearchField: Controller disposed detectado: $e');
      return Expanded(
        child: TextField(
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: TextStyle(color: hColor),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: TextStyle(color: tColor, fontSize: 16),
          enabled: false,
        ),
      );
    }

    return Expanded(
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: hColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(color: tColor),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.isSearching) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return widget.controller.text.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                widget.onClear();
                _focusNode.requestFocus();
              },
              child: Icon(
                Icons.close,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                size: widget.iconSize,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 24,
      width: 1,
      color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300,
    );
  }

  Widget _buildViewToggle() {
    if (widget.viewToggleBuilder != null) {
      return widget.viewToggleBuilder!(
          widget.selectedViewMode!, widget.isDark, widget.onToggleViewMode!) ?? const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () {
          if (widget.selectedViewMode == SearchViewMode.grid) {
            widget.onToggleViewMode!(SearchViewMode.list);
          } else {
            widget.onToggleViewMode!(SearchViewMode.grid);
          }
        },
        icon: Icon(
          widget.selectedViewMode == SearchViewMode.grid ? Icons.list : Icons.grid_view,
          color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          size: widget.iconSize,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
