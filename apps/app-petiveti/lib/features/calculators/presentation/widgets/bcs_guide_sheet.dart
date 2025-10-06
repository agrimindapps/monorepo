import 'package:flutter/material.dart';

/// BCS Guide Sheet widget
/// 
/// Responsibilities:
/// - Display comprehensive BCS guide
/// - Educational content for users
/// - Separate from main page logic
class BcsGuideSheet extends StatelessWidget {
  const BcsGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuideSection(
                    'O que é BCS?',
                    'Body Condition Score (BCS) é um sistema de avaliação nutricional que analisa a condição corporal do animal através de palpação e observação visual, utilizando uma escala de 1 a 9.',
                    Icons.info,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Como palpar as costelas?',
                    '1. Coloque as mãos nas laterais do tórax\n2. Pressione suavemente com as pontas dos dedos\n3. Avalie a facilidade para sentir as costelas\n4. Considere a cobertura de gordura',
                    Icons.touch_app,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Avaliação da cintura',
                    'Observe o animal de cima:\n• Deve haver uma "cintura" visível atrás das costelas\n• A cintura deve ser mais estreita que o tórax\n• Em animais obesos, a cintura desaparece',
                    Icons.visibility,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Perfil abdominal',
                    'Observe o animal de lado:\n• Abdome deve estar "retraído" (tucked up)\n• Em animais magros, a retração é muito evidente\n• Em obesos, o abdome fica pendular',
                    Icons.straighten,
                  ),
                  const SizedBox(height: 20),
                  _buildBcsScale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the header section
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.blue,
      ),
      child: Row(
        children: [
          const Icon(Icons.help, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Guia de Condição Corporal (BCS)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Build a guide section
  Widget _buildGuideSection(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the BCS scale reference
  Widget _buildBcsScale() {
    const bcsData = [
      {'score': '1-2', 'condition': 'Extremamente Magro', 'color': Colors.red},
      {'score': '3', 'condition': 'Magro', 'color': Colors.orange},
      {'score': '4', 'condition': 'Abaixo do Ideal', 'color': Colors.amber},
      {'score': '5', 'condition': 'Ideal', 'color': Colors.green},
      {'score': '6', 'condition': 'Acima do Ideal', 'color': Colors.amber},
      {'score': '7', 'condition': 'Sobrepeso', 'color': Colors.orange},
      {'score': '8-9', 'condition': 'Obeso', 'color': Colors.red},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.scale, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Escala BCS (1-9)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...bcsData.map((data) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: (data['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: data['color'] as Color),
                    ),
                    child: Center(
                      child: Text(
                        data['score'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(data['condition'] as String),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
