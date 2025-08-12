// Flutter imports:
import 'package:flutter/material.dart';

class TodoistHowItWorksSection extends StatelessWidget {
  const TodoistHowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    final steps = [
      {
        'number': '1',
        'title': 'Capture suas tarefas',
        'description':
            'Adicione rapidamente todas as suas tarefas, ideias e projetos em um lugar seguro.',
        'icon': Icons.add_circle_outline,
      },
      {
        'number': '2',
        'title': 'Organize e priorize',
        'description':
            'Use projetos, etiquetas e filtros para organizar tudo de acordo com suas necessidades.',
        'icon': Icons.sort,
      },
      {
        'number': '3',
        'title': 'Execute com foco',
        'description':
            'Trabalhe com foco nas tarefas certas no momento certo e acompanhe seu progresso.',
        'icon': Icons.trending_up,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          // Título da seção
          Text(
            'Como Funciona?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Três passos simples para transformar sua produtividade e organizar sua vida',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Steps
          isMobile ? _buildMobileSteps(steps) : _buildDesktopSteps(steps),
        ],
      ),
    );
  }

  Widget _buildDesktopSteps(List<Map<String, dynamic>> steps) {
    return Row(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> step = entry.value;

        return Expanded(
          child: Row(
            children: [
              Expanded(child: _buildStepCard(step)),
              if (index < steps.length - 1)
                const SizedBox(
                  width: 60,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFE44332),
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileSteps(List<Map<String, dynamic>> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> step = entry.value;

        return Column(
          children: [
            _buildStepCard(step),
            if (index < steps.length - 1) ...[
              const SizedBox(height: 20),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFE44332),
                size: 32,
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Número do passo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE44332),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                step['number'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ícone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE44332).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              step['icon'],
              size: 28,
              color: const Color(0xFFE44332),
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Text(
            step['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Descrição
          Text(
            step['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
