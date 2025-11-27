import 'package:flutter/material.dart';

class DeletionThirdPartySection extends StatelessWidget {
  const DeletionThirdPartySection({super.key});

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
                'Serviços de Terceiros',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              Text(
                'O GasOMeter utiliza serviços de terceiros que também processam seus dados. A exclusão afetará os seguintes serviços:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              _buildThirdPartyCard(
                'Firebase Authentication',
                'Dados de autenticação e perfil serão completamente removidos dos servidores do Google Firebase.',
                Icons.security,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'Firebase Cloud Firestore',
                'Todos os documentos e coleções associados à sua conta serão deletados permanentemente.',
                Icons.cloud_off,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'RevenueCat (Assinaturas)',
                'Sua assinatura será cancelada e os dados de cobrança serão removidos conforme as políticas da RevenueCat.',
                Icons.payment,
              ),
              const SizedBox(height: 16),
              _buildThirdPartyCard(
                'Google Analytics',
                'Dados analíticos associados ao seu ID serão removidos ou anonimizados conforme as políticas do Google.',
                Icons.analytics,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPartyCard(
    String service,
    String description,
    IconData icon,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
