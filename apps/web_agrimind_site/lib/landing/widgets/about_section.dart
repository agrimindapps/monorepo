import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF181818), // Slightly lighter dark
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOBRE NÓS',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3ECF8E), // Green accent
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transformando Desafios em Soluções Digitais',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'A Agrimind é uma software house dedicada a criar soluções tecnológicas que simplificam a vida e otimizam negócios. Com expertise em desenvolvimento mobile e web, atuamos em diversos setores, do agronegócio à saúde, entregando produtos robustos e intuitivos.',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey.shade400,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureRow(Icons.check_circle, 'Desenvolvimento Multiplataforma'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.check_circle, 'Foco na Experiência do Usuário'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.check_circle, 'Inovação Contínua'),
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width > 900) ...[
                const SizedBox(width: 60),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=2070&auto=format&fit=crop', // Team working
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3ECF8E), size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
