import 'package:flutter/material.dart';

class DeletionProcessSection extends StatelessWidget {
  const DeletionProcessSection({super.key});

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
                'Como Funciona o Processo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(width: 60, height: 4, color: Colors.red.shade700),
              const SizedBox(height: 30),
              Text(
                'O processo de exclusão da conta seguirá os seguintes passos:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              _buildProcessStep(
                '1',
                'Confirmação',
                'Você deve marcar a caixa de confirmação e clicar no botão "Excluir Conta" nesta página.',
              ),
              _buildProcessStep(
                '2',
                'Verificação de Identidade',
                'Para sua segurança, será solicitada a confirmação da sua senha atual antes de prosseguir.',
              ),
              _buildProcessStep(
                '3',
                'Processamento Imediato',
                'Sua conta será imediatamente desativada e você será desconectado de todos os dispositivos.',
              ),
              _buildProcessStep(
                '4',
                'Período de Retenção',
                'Os dados serão mantidos por até 30 dias em sistemas de backup para cumprimento de obrigações legais.',
              ),
              _buildProcessStep(
                '5',
                'Exclusão Definitiva',
                'Após 30 dias, todos os dados serão permanentemente removidos de todos os sistemas e backups.',
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prazo Legal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'De acordo com a LGPD, temos até 30 dias para processar completamente sua solicitação de exclusão.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
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

  Widget _buildProcessStep(String step, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
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
