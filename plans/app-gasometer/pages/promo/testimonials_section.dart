// Flutter imports:
import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  final List<Map<String, dynamic>> testimonials;

  const TestimonialsSection({
    super.key,
    required this.testimonials,
  });

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  int _selectedIndex = 0;

  // Cores para os cartões de depoimentos
  final _avatarColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.amber[100]!,
  ];

  final _avatarIconColors = [
    Colors.blue[800]!,
    Colors.green[700]!,
    Colors.amber[700]!,
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          // Título da seção com estrela decorativa
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Título da seção
              Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'O Que Nossos ',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: 'Usuários',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: ' Vão Dizer',
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: const Text(
                      'Veja como o GasOMeter tem ajudado motoristas a ter maior controle em todo o Brasil',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              // Estrela decorativa
              Positioned(
                top: -15,
                right: isMobile ? 20 : screenSize.width * 0.25,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[400],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Avaliação 4.8/5',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Layout responsivo para depoimentos
          isMobile ? _buildMobileTestimonials() : _buildDesktopTestimonials(),

          // Estatísticas de satisfação abaixo dos depoimentos
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[700]!,
                  Colors.blue[900]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Wrap(
              spacing: isMobile ? 30 : 60,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem('50K+', 'Usuários Satisfeitos'),
                _buildStatItem('95%', 'Taxa de Retenção'),
                _buildStatItem('4.8', 'Avaliação na Play Store'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTestimonials() {
    return SizedBox(
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lista de avatares com seleção à esquerda
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.testimonials.length,
                (index) => _buildAvatarSelector(index),
              ),
            ),
          ),

          // Card do depoimento selecionado à direita
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildLargeTestimonialCard(
                widget.testimonials[_selectedIndex],
                key: ValueKey<int>(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTestimonials() {
    return Column(
      children: [
        // Depoimento principal
        _buildLargeTestimonialCard(widget.testimonials[_selectedIndex]),

        // Seletores de depoimentos
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.testimonials.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _selectedIndex == index ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _selectedIndex == index
                        ? Colors.blue[800]
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSelector(int index) {
    final isSelected = _selectedIndex == index;
    final testimonial = widget.testimonials[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _avatarColors[index % _avatarColors.length],
                border: Border.all(
                  color: isSelected ? Colors.blue[800]! : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  testimonial['avatar'] as IconData,
                  color: _avatarIconColors[index % _avatarIconColors.length],
                  size: isSelected ? 24 : 20,
                ),
              ),
            ),

            // Nome
            if (isSelected) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        testimonial['rating'] as int,
                        (index) => const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLargeTestimonialCard(Map<String, dynamic> testimonial,
      {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Aspas decorativas
          Icon(
            Icons.format_quote,
            size: 50,
            color: Colors.blue[100],
          ),
          const SizedBox(height: 20),

          // Depoimento
          Expanded(
            child: Center(
              child: Text(
                testimonial['comment'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Informações do usuário
          Column(
            children: [
              // Avaliação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 20,
                    color: index < (testimonial['rating'] as int)
                        ? Colors.amber
                        : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Avatar e nome
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    _avatarColors[_selectedIndex % _avatarColors.length],
                child: Icon(
                  testimonial['avatar'] as IconData,
                  color: _avatarIconColors[
                      _selectedIndex % _avatarIconColors.length],
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                testimonial['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
