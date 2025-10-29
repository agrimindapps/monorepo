import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home page with calculator grid and animated background
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculei - Calculadoras'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  -1.0 + (_gradientAnimation.value * 0.5),
                  -1.0 + (_gradientAnimation.value * 0.3),
                ),
                end: Alignment(
                  1.0 - (_gradientAnimation.value * 0.5),
                  1.0 - (_gradientAnimation.value * 0.3),
                ),
                colors: [
                  Colors.blue.shade50,
                  Colors.indigo.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: child,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600
                ? 2 // Mobile
                : constraints.maxWidth < 900
                    ? 3 // Tablet
                    : 4; // Desktop

            return GridView.count(
              crossAxisCount: crossAxisCount,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // ========== FINANCIAL CALCULATORS ==========
                _CalculatorCard(
                  index: 0,
                  title: '13º Salário',
                  icon: Icons.card_giftcard,
                  color: Colors.green,
                  onTap: () => context.go('/financial/thirteenth-salary'),
                ),
                _CalculatorCard(
                  index: 1,
                  title: 'Férias',
                  icon: Icons.beach_access,
                  color: Colors.blue,
                  onTap: () => context.go('/financial/vacation'),
                ),
                _CalculatorCard(
                  index: 2,
                  title: 'Salário Líquido',
                  icon: Icons.monetization_on,
                  color: Colors.orange,
                  onTap: () => context.go('/financial/net-salary'),
                ),
                _CalculatorCard(
                  index: 3,
                  title: 'Horas Extras',
                  icon: Icons.access_time,
                  color: Colors.purple,
                  onTap: () => context.go('/financial/overtime'),
                ),
                _CalculatorCard(
                  index: 4,
                  title: 'Reserva de Emergência',
                  icon: Icons.savings,
                  color: Colors.teal,
                  onTap: () => context.go('/financial/emergency-reserve'),
                ),
                _CalculatorCard(
                  index: 5,
                  title: 'À vista ou Parcelado',
                  icon: Icons.payment,
                  color: Colors.indigo,
                  onTap: () => context.go('/financial/cash-vs-installment'),
                ),
                _CalculatorCard(
                  index: 6,
                  title: 'Seguro Desemprego',
                  icon: Icons.work_off,
                  color: Colors.red,
                  onTap: () => context.go('/financial/unemployment-insurance'),
                ),

                // ========== CONSTRUCTION CALCULATORS ==========
                _CalculatorCard(
                  index: 7,
                  title: 'Cálculos de Construção',
                  icon: Icons.construction,
                  color: Colors.deepOrange,
                  onTap: () => context.go('/construction/selection'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatefulWidget {
  const _CalculatorCard({
    required this.index,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final int index;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_CalculatorCard> createState() => _CalculatorCardState();
}

class _CalculatorCardState extends State<_CalculatorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.1,
          0.4 + (widget.index * 0.1),
          curve: Curves.easeOut,
        ),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.1,
          0.4 + (widget.index * 0.1),
          curve: Curves.elasticOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(
                      _isHovering ? 0.4 : 0.15,
                    ),
                    blurRadius: _isHovering ? 24 : 12,
                    offset: Offset(0, _isHovering ? 12 : 6),
                    spreadRadius: _isHovering ? 2 : 0,
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isHovering
                          ? [
                              widget.color.withOpacity(0.1),
                              widget.color.withOpacity(0.05),
                            ]
                          : [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                    ),
                    border: Border.all(
                      color: widget.color.withOpacity(_isHovering ? 0.3 : 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Transform.scale(
                    scale: _isHovering ? 1.05 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: _isHovering ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            widget.icon,
                            size: 52,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isHovering
                                      ? widget.color
                                      : Colors.grey[800],
                                  fontSize: _isHovering ? 16 : 14,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
