// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

class FAQSection extends StatefulWidget {
  final List<Map<String, dynamic>> faqs;

  const FAQSection({super.key, required this.faqs});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  List<bool> _expandedStates = [];
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Inicializar todos os itens como fechados
    _expandedStates = List.generate(widget.faqs.length, (index) => false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Elementos decorativos
          ..._buildDecorativeElements(context),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone decorativo
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              // Título com estilo destacado
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'Perguntas '),
                    TextSpan(
                      text: 'Frequentes',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subtítulo
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                margin: const EdgeInsets.only(bottom: 50),
                child: Text(
                  'Tire suas dúvidas sobre o aplicativo Calculei e descubra como ele pode ajudar você no dia a dia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ),

              // Itens de FAQ em Container limitado para melhor legibilidade
              Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: List.generate(
                    widget.faqs.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredIndex = index),
                        onExit: (_) => setState(() => _hoveredIndex = -1),
                        child: _buildFaqItem(
                          question: widget.faqs[index]['question'],
                          answer: widget.faqs[index]['answer'],
                          context: context,
                          index: index,
                          isHovered: _hoveredIndex == index,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Botão para acessar central de ajuda
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent),
                label: const Text('Central de Ajuda Completa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),

              const SizedBox(height: 16),

              // Informações de contato
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ainda tem dúvidas?',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          'Fale Conosco',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Elementos decorativos
  List<Widget> _buildDecorativeElements(BuildContext context) {
    return [
      // Padrão de fundo
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: _BackgroundPatternPainter(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.03),
                progress: _animationController.value,
              ),
            );
          },
        ),
      ),

      // Elementos flutuantes
      Positioned(
        top: -40,
        left: -40,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
          ),
        ),
      ),

      Positioned(
        bottom: -30,
        right: 100,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * math.pi * 2,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ),

      Positioned(
        top: 100,
        right: 40,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_animationController.value * math.pi * 2) * 15,
                math.cos(_animationController.value * math.pi * 2) * 15,
              ),
              child: Icon(
                Icons.question_answer,
                size: 30,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.2),
              ),
            );
          },
        ),
      ),
    ];
  }

  // Item de FAQ
  Widget _buildFaqItem({
    required String question,
    required String answer,
    required BuildContext context,
    required int index,
    required bool isHovered,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _expandedStates[index] || isHovered
                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: _expandedStates[index] || isHovered ? 15 : 8,
            spreadRadius: _expandedStates[index] || isHovered ? 2 : 0,
            offset: _expandedStates[index] || isHovered
                ? const Offset(0, 5)
                : const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _expandedStates[index] || isHovered
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _expandedStates[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedStates[index] = expanded;
            });
          },
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          title: Row(
            children: [
              // Numeração do item
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: _expandedStates[index] || isHovered
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _expandedStates[index] || isHovered
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontWeight: _expandedStates[index]
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 16,
                    color: _expandedStates[index]
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _expandedStates[index] || isHovered
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _expandedStates[index] ? Icons.remove : Icons.add,
                color: _expandedStates[index] || isHovered
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 18,
              ),
            ),
          ),
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.03),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(70, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      answer,
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botão para mais informações
                    if (_expandedStates[index])
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Saiba mais',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter para o padrão de fundo
class _BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  _BackgroundPatternPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 40;
    const double dotSize = 2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Adiciona movimento sutil aos pontos
        final offset = math.sin((x + y) / 200 + progress * math.pi * 2) * 5;

        canvas.drawCircle(
          Offset(x + offset, y - offset / 2),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BackgroundPatternPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
