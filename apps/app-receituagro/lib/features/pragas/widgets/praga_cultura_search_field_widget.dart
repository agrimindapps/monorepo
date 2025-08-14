import 'package:flutter/material.dart';
import '../models/praga_view_mode.dart';

class PragaCulturaSearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final PragaViewMode selectedViewMode;
  final ValueChanged<PragaViewMode> onToggleViewMode;
  final String hintText;

  const PragaCulturaSearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    required this.onChanged,
    required this.selectedViewMode,
    required this.onToggleViewMode,
    this.hintText = 'Buscar pragas...',
  });

  @override
  State<PragaCulturaSearchFieldWidget> createState() => _PragaCulturaSearchFieldWidgetState();
}

class _PragaCulturaSearchFieldWidgetState extends State<PragaCulturaSearchFieldWidget>
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
      begin: const Offset(0, -0.3),
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
        child: _buildSearchCard(),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: widget.isDark ? const Color(0xFF222228) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSearchField(),
            ),
            const SizedBox(width: 12),
            _buildViewToggleButtons(),
          ],
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
          hintText: widget.hintText,
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

  Widget _buildViewToggleButtons() {
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
    final isSelected = widget.selectedViewMode == mode;
    final color = widget.isDark 
        ? Colors.green.shade300 
        : Colors.green.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => widget.onToggleViewMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
}