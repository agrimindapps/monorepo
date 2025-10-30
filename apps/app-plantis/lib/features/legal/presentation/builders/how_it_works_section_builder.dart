import 'package:flutter/material.dart';

/// Builder estático para seção "Como Funciona"
/// SRP: Isolates "How It Works" section UI construction
class HowItWorksSectionBuilder {
  static Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    final steps = [
      {
        'number': '1',
        'title': 'Cadastre suas Plantas',
        'description': 'Adicione suas plantas com fotos e informações básicas',
        'icon': Icons.add_photo_alternate,
      },
      {
        'number': '2',
        'title': 'Configure os Cuidados',
        'description':
            'Defina a frequência de rega, adubação e outras necessidades',
        'icon': Icons.settings,
      },
      {
        'number': '3',
        'title': 'Receba Lembretes',
        'description':
            'Seja notificado automaticamente quando suas plantas precisarem de cuidados',
        'icon': Icons.notifications_active,
      },
      {
        'number': '4',
        'title': 'Acompanhe o Crescimento',
        'description': 'Registre o progresso e veja suas plantas prosperarem',
        'icon': Icons.trending_up,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Como Funciona',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'É simples começar a cuidar melhor das suas plantas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 48,
                alignment: WrapAlignment.center,
                children: steps.map((step) {
                  return SizedBox(
                    width: isMobile ? screenSize.width - 48 : 250,
                    child: _buildStepCard(
                      step['number'] as String,
                      step['title'] as String,
                      step['description'] as String,
                      step['icon'] as IconData,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStepCard(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
