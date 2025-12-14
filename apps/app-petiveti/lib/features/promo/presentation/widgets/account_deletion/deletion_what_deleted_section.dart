import 'package:flutter/material.dart';

/// Seção que lista o que será deletado
/// Adaptado para Petiveti (dados de pets)
class DeletionWhatDeletedSection extends StatelessWidget {
  const DeletionWhatDeletedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que será Deletado',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              Text(
                'Ao solicitar a exclusão da sua conta, os seguintes dados serão permanentemente removidos de nossos sistemas:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              _buildDataCategoryCard('Dados da Conta', Icons.person, [
                'Informações de perfil (nome, email)',
                'Dados de autenticação',
                'Preferências e configurações',
                'Histórico de login e sessões',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados dos Pets', Icons.pets, [
                'Informações dos pets cadastrados',
                'Fotos e imagens dos pets',
                'Histórico de vacinas',
                'Registros de medicamentos',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados de Saúde', Icons.medical_services, [
                'Registros de peso',
                'Histórico de consultas',
                'Agendamentos e lembretes',
                'Despesas veterinárias',
              ]),
              const SizedBox(height: 16),
              _buildDataCategoryCard('Dados Técnicos', Icons.analytics, [
                'Logs de uso da aplicação',
                'Dados de analytics anonimizados',
                'Informações de crash reports',
                'Dados de sincronização',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCategoryCard(
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
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
