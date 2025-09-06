import 'package:flutter/material.dart';
import '../models/praga_view_mode.dart';

class PragaSearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String pragaType;
  final bool isDark;
  final PragaViewMode viewMode;
  final ValueChanged<PragaViewMode> onViewModeChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const PragaSearchFieldWidget({
    super.key,
    required this.controller,
    required this.pragaType,
    required this.isDark,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onClear,
    required this.onChanged,
  });

  @override
  State<PragaSearchFieldWidget> createState() => _PragaSearchFieldWidgetState();
}

class _PragaSearchFieldWidgetState extends State<PragaSearchFieldWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
          child: _buildSearchField(),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.grey.shade800.withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: widget.isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: _getSearchHint(),
          hintStyle: TextStyle(
            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.green.shade600,
            size: 24,
          ),
          suffixIcon: _buildViewToggleCompact(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleCompact() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactToggleButton(PragaViewMode.grid, isFirst: true),
          Container(
            width: 1,
            height: 32,
            color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          _buildCompactToggleButton(PragaViewMode.list, isLast: true),
        ],
      ),
    );
  }

  Widget _buildCompactToggleButton(PragaViewMode mode,
      {bool isFirst = false, bool isLast = false}) {
    final isSelected = widget.viewMode == mode;
    final activeColor = Colors.green.shade600;
    final inactiveColor =
        widget.isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    BorderRadius borderRadius;
    if (isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(7),
        bottomLeft: Radius.circular(7),
      );
    } else if (isLast) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(7),
        bottomRight: Radius.circular(7),
      );
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => widget.onViewModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Icon(
            mode.icon,
            size: 18,
            color: isSelected ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (widget.pragaType) {
      case '1':
        return 'Buscar insetos...';
      case '2':
        return 'Buscar doenças...';
      case '3':
        return 'Buscar plantas daninhas...';
      default:
        return 'Buscar pragas...';
    }
  }
}
