import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoCTASection extends StatelessWidget {
  final VoidCallback onPreRegisterPressed;

  const PromoCTASection({
    super.key,
    required this.onPreRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: SplashColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildCTAHeader(context, isMobile),
          
          const SizedBox(height: 40),
          _buildCTAButtons(context, isMobile),
          
          const SizedBox(height: 40),
          _buildStoreButtons(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildCTAHeader(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text(
          'Pronto para Cuidar do seu Pet?',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Seja um dos primeiros a usar o PetiVeti e transforme a forma como você cuida do seu melhor amigo.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Lançamento: ${SplashConstants.launchDateFormatted}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButtons(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onPreRegisterPressed,
          icon: const Icon(Icons.notifications_active, size: 20),
          label: const Text('Quero ser Notificado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: SplashColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.info_outline, size: 20),
          label: const Text('Saiba Mais'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text(
          'Baixe quando disponível:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildStoreButton(
              'EM BREVE NA',
              'GOOGLE PLAY',
              Icons.android,
              Colors.black87,
            ),
            _buildStoreButton(
              'EM BREVE NA',
              'APP STORE',
              Icons.apple,
              Colors.black87,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreButton(String topText, String bottomText, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              Text(
                bottomText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}