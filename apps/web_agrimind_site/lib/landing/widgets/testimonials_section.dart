import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: const Color(0xFF181818), // Slightly lighter dark for contrast
      child: Column(
        children: [
          Text(
            'DEPOIMENTOS',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3ECF8E),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O que nossos usuários dizem',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          const Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _TestimonialCard(
                name: 'João Silva',
                role: 'Engenheiro Agrônomo',
                text: 'O ReceituAgro revolucionou a forma como faço minhas prescrições. Ganhei muito tempo e segurança nas recomendações.',
                rating: 5,
              ),
              _TestimonialCard(
                name: 'Maria Oliveira',
                role: 'Veterinária',
                text: 'O Petiveti me ajuda a manter o histórico dos meus pacientes organizado. É uma ferramenta indispensável.',
                rating: 5,
              ),
              _TestimonialCard(
                name: 'Carlos Santos',
                role: 'Produtor Rural',
                text: 'Com o Gasometer, consegui reduzir em 15% os custos com combustível da minha frota. Recomendo!',
                rating: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String text;
  final int rating;

  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.text,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 20,
                color: index < rating ? const Color(0xFF3ECF8E) : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"$text"',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade300,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF3ECF8E).withOpacity(0.2),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Color(0xFF3ECF8E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
}
