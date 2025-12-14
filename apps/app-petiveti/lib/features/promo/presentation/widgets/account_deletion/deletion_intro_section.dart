import 'package:flutter/material.dart';

/// Seção introdutória sobre direito à exclusão de dados
/// Adaptado para Petiveti
class DeletionIntroSection extends StatelessWidget {
  const DeletionIntroSection({super.key});

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
                'Direito à Exclusão de Dados',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              _buildParagraph(
                'De acordo com a Lei Geral de Proteção de Dados (LGPD) brasileira e o Regulamento Geral sobre Proteção de Dados (GDPR) europeu, você tem o direito fundamental ao esquecimento, também conhecido como direito ao apagamento.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'Este direito permite que você solicite a exclusão completa e permanente de todos os seus dados pessoais coletados e processados pelo Petiveti.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'Esta página foi criada para facilitar o exercício deste direito de forma transparente, segura e em conformidade com todas as regulamentações aplicáveis.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: const Border(
                    left: BorderSide(width: 4, color: Colors.orange),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ATENÇÃO: Esta ação é irreversível e todos os seus dados serão permanentemente deletados.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
      textAlign: TextAlign.justify,
    );
  }
}
