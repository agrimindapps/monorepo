import 'package:flutter/material.dart';

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Como ',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const TextSpan(
                  text: 'Funciona',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF673AB7),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Comece a organizar suas tarefas em apenas 3 passos simples',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 0 : screenSize.width * 0.1),
            child: isMobile ? _buildMobileSteps(context) : _buildDesktopSteps(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildStep(
            '1',
            'Crie suas Listas',
            'Organize tarefas em listas personalizadas com tags, cores e prioridades.',
            Icons.checklist,
            const Color(0xFF673AB7),
          ),
        ),
        Expanded(
          child: _buildStep(
            '2',
            'Defina Prioridades',
            'Marque tarefas importantes e urgentes para focar no que realmente importa.',
            Icons.priority_high,
            const Color(0xFF00BCD4),
          ),
        ),
        Expanded(
          child: _buildStep(
            '3',
            'Acompanhe Progresso',
            'Visualize seu progresso com gráficos e estatísticas detalhadas.',
            Icons.analytics,
            const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSteps(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          '1',
          'Crie suas Listas',
          'Organize tarefas em listas personalizadas com tags, cores e prioridades.',
          Icons.checklist,
          const Color(0xFF673AB7),
        ),
        const SizedBox(height: 40),
        _buildStep(
          '2',
          'Defina Prioridades',
          'Marque tarefas importantes e urgentes para focar no que realmente importa.',
          Icons.priority_high,
          const Color(0xFF00BCD4),
        ),
        const SizedBox(height: 40),
        _buildStep(
          '3',
          'Acompanhe Progresso',
          'Visualize seu progresso com gráficos e estatísticas detalhadas.',
          Icons.analytics,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildStep(
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 2),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
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
