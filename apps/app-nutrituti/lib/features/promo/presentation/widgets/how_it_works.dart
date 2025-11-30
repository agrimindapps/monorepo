import 'package:flutter/material.dart';

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildSectionHeader(isMobile),
          const SizedBox(height: 60),
          isMobile ? _buildMobileSteps() : _buildDesktopSteps(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isMobile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Text(
            'COMO FUNCIONA',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Comece em minutos',
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Configurar seu plano nutricional é fácil e rápido. Em poucos passos, você terá tudo pronto para começar sua jornada.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSteps() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStep(1, 'Crie sua Conta', 'Cadastre-se gratuitamente em segundos usando seu email ou Google.', Icons.person_add)),
        _buildConnector(),
        Expanded(child: _buildStep(2, 'Defina seus Objetivos', 'Informe seu peso, altura e metas para um plano personalizado.', Icons.flag)),
        _buildConnector(),
        Expanded(child: _buildStep(3, 'Planeje suas Refeições', 'Registre suas refeições e acompanhe seus macros em tempo real.', Icons.restaurant_menu)),
        _buildConnector(),
        Expanded(child: _buildStep(4, 'Acompanhe seu Progresso', 'Visualize gráficos e insights sobre sua evolução nutricional.', Icons.trending_up)),
      ],
    );
  }

  Widget _buildMobileSteps() {
    return Column(
      children: [
        _buildStep(1, 'Crie sua Conta', 'Cadastre-se gratuitamente em segundos usando seu email ou Google.', Icons.person_add),
        _buildMobileConnector(),
        _buildStep(2, 'Defina seus Objetivos', 'Informe seu peso, altura e metas para um plano personalizado.', Icons.flag),
        _buildMobileConnector(),
        _buildStep(3, 'Planeje suas Refeições', 'Registre suas refeições e acompanhe seus macros em tempo real.', Icons.restaurant_menu),
        _buildMobileConnector(),
        _buildStep(4, 'Acompanhe seu Progresso', 'Visualize gráficos e insights sobre sua evolução nutricional.', Icons.trending_up),
      ],
    );
  }

  Widget _buildStep(int number, String title, String description, IconData icon) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.teal[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 24),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            width: 8,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            width: 2,
            height: 8,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
