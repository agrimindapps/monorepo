import 'package:flutter/material.dart';

/// Seção que lista consequências da exclusão
class DeletionConsequencesSection extends StatelessWidget {
  const DeletionConsequencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consequências da Exclusão',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              Text(
                'É importante entender as consequências permanentes da exclusão da sua conta:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              _buildConsequenceCard(
                'Perda Completa de Dados',
                Icons.data_usage,
                'Todos os dados de pets, vacinas, medicamentos, consultas e registros serão perdidos permanentemente.',
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Cancelamento de Assinatura Premium',
                Icons.star,
                'Sua assinatura premium será automaticamente cancelada sem direito a reembolso proporcional.',
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Impossibilidade de Recuperação',
                Icons.restore,
                'Não será possível recuperar os dados após a confirmação da exclusão, mesmo contatando o suporte.',
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildConsequenceCard(
                'Interrupção da Sincronização',
                Icons.sync_disabled,
                'A sincronização entre dispositivos será interrompida e dados locais podem permanecer no dispositivo.',
                Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsequenceCard(
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
