import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Speed Dial Floating Action Button
/// Opens a menu above the FAB with quick actions
class SpeedDialFAB extends StatefulWidget {
  const SpeedDialFAB({
    super.key,
    this.backgroundColor = const Color(0xFFFF6B35), // Orange from header
  });

  final Color backgroundColor;

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 turn)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  void _navigateAndClose(BuildContext context, String route) {
    _close();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

        // Speed dial items
        if (_isOpen)
          Positioned(
            bottom: 80,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SpeedDialItem(
                    icon: Icons.local_gas_station,
                    label: 'Abastecimentos',
                    color: widget.backgroundColor,
                    onTap: () => _navigateAndClose(context, '/fuel/add'),
                  ),
                  const SizedBox(height: 12),
                  _SpeedDialItem(
                    icon: Icons.build,
                    label: 'Manutenções',
                    color: widget.backgroundColor,
                    onTap: () => _navigateAndClose(context, '/maintenance/add'),
                  ),
                  const SizedBox(height: 12),
                  _SpeedDialItem(
                    icon: Icons.attach_money,
                    label: 'Despesas',
                    color: widget.backgroundColor,
                    onTap: () => _navigateAndClose(context, '/expenses/add'),
                  ),
                  const SizedBox(height: 12),
                  _SpeedDialItem(
                    icon: Icons.speed,
                    label: 'Odômetro',
                    color: widget.backgroundColor,
                    onTap: () => _navigateAndClose(context, '/odometer/add'),
                  ),
                ],
              ),
            ),
          ),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Icon(
              _isOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual Speed Dial Item
class _SpeedDialItem extends StatelessWidget {
  const _SpeedDialItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Icon button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
