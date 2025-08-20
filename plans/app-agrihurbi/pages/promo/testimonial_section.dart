// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TestimonialSection extends StatefulWidget {
  const TestimonialSection({super.key});

  @override
  State<TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends State<TestimonialSection> {
  int _currentCarouselIndex = 0;

  // Lista de depoimentos
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Paulo Souza',
      'role': 'Engenheiro Agrônomo',
      'app': 'ReceituAgro',
      'comment':
          'O ReceituAgro revolucionou meu trabalho em campo. Consigo acessar todas as informações de defensivos rapidamente, sem precisar carregar manuais volumosos. A interface é intuitiva e facilita muito a elaboração de receituários.',
      'avatar':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/avatar_1.jpg',
      'color': Colors.green,
      'rating': 5
    },
    {
      'name': 'Mariana Lima',
      'role': 'Nutricionista',
      'app': 'NutriTuti',
      'comment':
          'Recomendo o NutriTuti para todos os meus pacientes. As informações nutricionais são precisas e de fácil acesso. O aplicativo tem ajudado meus pacientes a desenvolverem hábitos alimentares mais saudáveis com um acompanhamento detalhado.',
      'avatar':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/avatar_2.jpg',
      'color': Colors.red,
      'rating': 5
    },
    {
      'name': 'Rafael Torres',
      'role': 'Produtor Rural',
      'app': 'AgriHurb',
      'comment':
          'O AgriHurb me ajuda a tomar decisões importantes na fazenda com base em dados precisos e atualizados. As previsões climáticas e cotações de mercado em tempo real são ferramentas valiosas que utilizo diariamente para planejar as atividades.',
      'avatar':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/avatar_3.jpg',
      'color': Colors.amber,
      'rating': 4
    },
    {
      'name': 'Carla Mendes',
      'role': 'Veterinária',
      'app': 'VetiPeti',
      'comment':
          'O VetiPeti é uma ferramenta indispensável no meu consultório para orientar os tutores sobre cuidados com seus pets. A biblioteca de medicamentos e o sistema de lembretes ajudam muito no acompanhamento dos tratamentos prescritos.',
      'avatar':
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/avatar_4.jpg',
      'color': Colors.purple,
      'rating': 5
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Column(
      children: [
        // Subtítulo introdutório aos depoimentos
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.only(bottom: 40),
          child: Text(
            'Nossos usuários compartilham suas experiências sobre como nossas soluções transformam seus trabalhos e vidas diariamente.',
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Carrossel de depoimentos
        Center(
          child: SizedBox(
            width: 1200,
            child: CarouselSlider(
              items: _testimonials.map((testimonial) {
                return Builder(
                  builder: (BuildContext context) {
                    return _buildTestimonialCard(testimonial, isSmallScreen);
                  },
                );
              }).toList(),
              options: CarouselOptions(
                height: isSmallScreen ? 420 : 320,
                viewportFraction: isSmallScreen ? 0.9 : 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 7),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
            ),
          ),
        ),

        // Indicadores do carrossel e controles
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicadores
            AnimatedSmoothIndicator(
              activeIndex: _currentCarouselIndex,
              count: _testimonials.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.green.shade700,
                dotColor: Colors.grey.shade300,
                spacing: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(
      Map<String, dynamic> testimonial, bool isSmallScreen) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: testimonial['color'].withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Avatar do usuário
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: testimonial['color'].withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: testimonial['avatar'] is String
                        ? Image.network(
                            testimonial['avatar'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor:
                                    testimonial['color'].withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.person,
                                  color: testimonial['color'],
                                  size: 32,
                                ),
                              );
                            },
                          )
                        : CircleAvatar(
                            backgroundColor:
                                testimonial['color'].withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              color: testimonial['color'],
                              size: 32,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Informações do usuário
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testimonial['role'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // Avaliação em estrelas
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < testimonial['rating']
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),

          // Conteúdo do depoimento
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aspas
                  Icon(
                    Icons.format_quote,
                    size: 28,
                    color: testimonial['color'].withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),

                  // Comentário
                  Expanded(
                    child: Text(
                      testimonial['comment'],
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: isSmallScreen ? 8 : 5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rodapé com app usado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Aplicativo:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: testimonial['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    testimonial['app'],
                    style: TextStyle(
                      color: testimonial['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
