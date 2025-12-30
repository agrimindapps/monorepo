import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/privacy_policy_page.dart';
import '../pages/terms_of_use_page.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A), // Darker than background
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 20, right: 20),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.code, color: Color(0xFF3ECF8E), size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'Agrimind',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tecnologia Inteligente para Transformar o Futuro.',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: const [
                          _SocialIcon(icon: Icons.facebook),
                          SizedBox(width: 16),
                          _SocialIcon(icon: Icons.camera_alt), // Instagram placeholder
                          SizedBox(width: 16),
                          _SocialIcon(icon: Icons.link), // LinkedIn placeholder
                        ],
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width > 800) ...[
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produtos',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FooterLink(text: 'ReceituAgro'),
                        const _FooterLink(text: 'Petiveti'),
                        const _FooterLink(text: 'Plantis'),
                        const _FooterLink(text: 'Gasometer'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Empresa',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _FooterLink(text: 'Sobre Nós'),
                        const _FooterLink(text: 'Carreiras'),
                        const _FooterLink(text: 'Blog'),
                        const _FooterLink(text: 'Contato'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _FooterLink(
                          text: 'Termos de Uso',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TermsOfUsePage(),
                              ),
                            );
                          },
                        ),
                        _FooterLink(
                          text: 'Privacidade',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                        const _FooterLink(text: 'Cookies'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80),
          Divider(color: Colors.grey.shade800),
          const SizedBox(height: 32),
          Text(
            '© ${2025} Agrimind Soluções Tecnológicas. Todos os direitos reservados.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _FooterLink({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: MouseRegion(
          cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
              decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
              decorationColor: Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
