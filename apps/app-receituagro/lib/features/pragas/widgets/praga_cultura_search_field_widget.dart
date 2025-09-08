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
  final bool isSearching;

  const PragaCulturaSearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    required this.onChanged,
    required this.selectedViewMode,
    required this.onToggleViewMode,
    this.hintText = 'Buscar pragas...',
    this.isSearching = false,
  });

  @override
  State<PragaCulturaSearchFieldWidget> createState() => _PragaCulturaSearchFieldWidgetState();
}

class _PragaCulturaSearchFieldWidgetState extends State<PragaCulturaSearchFieldWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _focusController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 5.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChange);
    _animationController.forward();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: AnimatedBuilder(
              animation: _focusController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E1E22) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.green.shade100.withValues(alpha: 0.5),
                        blurRadius: _elevationAnimation.value,
                        offset: Offset(0, _elevationAnimation.value / 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return RotationTransition(
                              turns: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: widget.isSearching
                              ? SizedBox(
                                  key: const ValueKey('loading'),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.isDark
                                          ? Colors.green.shade300
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                )
                              : AnimatedContainer(
                                  key: const ValueKey('search'),
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.search,
                                    color: _isFocused
                                        ? (widget.isDark
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : (widget.isDark
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade400),
                                    size: 20,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            onChanged: widget.onChanged,
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              hintStyle: TextStyle(
                                color: widget.isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              suffixIcon: widget.controller.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: widget.onClear,
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: widget.isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade500,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildViewToggleButtons(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggleButtons() {
    return Container(
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.isDark
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade100.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(PragaViewMode.grid, Icons.grid_view_rounded),
          _buildToggleButton(PragaViewMode.list, Icons.view_list_rounded),
        ],
      ),
    );
  }

  Widget _buildToggleButton(PragaViewMode mode, IconData icon) {
    final bool isSelected = widget.selectedViewMode == mode;
    final bool isFirstButton = mode == PragaViewMode.grid;

    return InkWell(
      onTap: () => widget.onToggleViewMode(mode),
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(isFirstButton ? 20 : 0),
        right: Radius.circular(!isFirstButton ? 20 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isDark
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.green.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirstButton ? 20 : 0),
            right: Radius.circular(!isFirstButton ? 20 : 0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (widget.isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }
}