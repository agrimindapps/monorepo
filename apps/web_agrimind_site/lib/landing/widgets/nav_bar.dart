import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onAppsTap;
  final VoidCallback onContactTap;

  const NavBar({
    super.key,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onAppsTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: const Color(0xFF121212), // Dark background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Color(0xFF3ECF8E), size: 32), // Green icon
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
          if (MediaQuery.of(context).size.width > 800)
            Row(
              children: [
                _NavItem(title: 'Início', onTap: onHomeTap),
                _NavItem(title: 'Sobre Nós', onTap: onAboutTap),
                _NavItem(title: 'Aplicativos', onTap: onAppsTap),
                _NavItem(title: 'Contato', onTap: onContactTap),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: onAppsTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3ECF8E), // Supabase Green
                    foregroundColor: Colors.black, // Black text on green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Sharper corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Começar Agora'),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // TODO: Implement mobile drawer
              },
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300, // Light grey text
          ),
        ),
      ),
    );
  }
}
