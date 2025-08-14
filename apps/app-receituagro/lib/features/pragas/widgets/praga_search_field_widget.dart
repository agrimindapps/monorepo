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
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF222228) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark 
                  ? Colors.grey.shade800 
                  : Colors.green.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSearchField(),
                  ),
                  const SizedBox(width: 12),
                  _buildViewToggle(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark 
            ? Colors.grey.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark 
              ? Colors.grey.shade700 
              : Colors.grey.shade300,
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
            color: widget.isDark 
                ? Colors.grey.shade400 
                : Colors.grey.shade600,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: widget.isDark 
                ? Colors.green.shade300 
                : Colors.green.shade700,
            size: 22,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  onPressed: widget.onClear,
                  icon: Icon(
                    Icons.clear_rounded,
                    color: widget.isDark 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark 
            ? Colors.grey.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark 
              ? Colors.grey.shade700 
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(PragaViewMode.list),
          Container(
            width: 1,
            height: 24,
            color: widget.isDark 
                ? Colors.grey.shade700 
                : Colors.grey.shade300,
          ),
          _buildToggleButton(PragaViewMode.grid),
        ],
      ),
    );
  }

  Widget _buildToggleButton(PragaViewMode mode) {
    final isSelected = widget.viewMode == mode;
    final color = widget.isDark 
        ? Colors.green.shade300 
        : Colors.green.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => widget.onViewModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            mode.icon,
            size: 20,
            color: isSelected 
                ? color 
                : (widget.isDark 
                    ? Colors.grey.shade400 
                    : Colors.grey.shade600),
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