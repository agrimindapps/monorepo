// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../politicas/gasometer_pp_page.dart';
import '../politicas/gasometer_tc_page.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        children: [
          // Links de políticas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPolicyLink(
                'Políticas de Privacidade',
                () => Get.to(() => const GasOMeterPoliticaPage()),
              ),
              const SizedBox(width: 20),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 20),
              _buildPolicyLink(
                'Termos de Uso',
                () => Get.to(() => const GasOMeterTermosPage()),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Direitos autorais e redes sociais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '© ${DateTime.now().year} GasOMeter. Todos os direitos reservados.',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildSocialButton(Icons.facebook),
                  _buildSocialButton(Icons.message), // Substitui Twitter
                  _buildSocialButton(Icons.photo_camera), // Substitui Instagram
                  _buildSocialButton(Icons.video_library), // Substitui YouTube
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyLink(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {
          // Ação do botão
        },
      ),
    );
  }
}
