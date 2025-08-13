// Flutter imports:
import 'package:flutter/material.dart';

/// Widget de termos de uso e política de privacidade específico do ReceitaAgro
class ReceituagroTermsWidget extends StatelessWidget {
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  const ReceituagroTermsWidget({
    super.key,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações Legais',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoItem(
            context,
            Icons.description,
            'Termos de Uso',
            'Condições e responsabilidades do uso do ReceitaAgro',
            onTermsPressed,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            context,
            Icons.privacy_tip,
            'Política de Privacidade',
            'Como protegemos e utilizamos seus dados',
            onPrivacyPressed,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Informações da Assinatura',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('• Avaliação gratuita de 3 dias, sem cobrança'),
                _buildBulletPoint('• Após o período gratuito, renovação automática'),
                _buildBulletPoint('• Cancele até 24h antes do fim da avaliação'),
                _buildBulletPoint('• Gerencie via App Store (iOS) ou Google Play (Android)'),
                _buildBulletPoint('• Cobrança processada pela sua loja de aplicativos'),
                _buildBulletPoint('• Preços podem variar por região'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Informações específicas do ReceitaAgro
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sobre o ReceitaAgro',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('• Desenvolvido por especialistas em agricultura'),
                _buildBulletPoint('• Base de dados atualizada constantemente'),
                _buildBulletPoint('• Suporte técnico especializado'),
                _buildBulletPoint('• Mais de 10 anos de experiência no setor'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Widget de FAQ específico para assinaturas
class SubscriptionFaqWidget extends StatelessWidget {
  const SubscriptionFaqWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final faqItems = [
      {
        'question': 'Como funciona a avaliação gratuita?',
        'answer': 'Você tem 3 dias para experimentar todos os recursos premium gratuitamente. Não há cobrança durante este período. Para evitar cobrança, cancele até 24h antes do fim da avaliação. Se não cancelar, a assinatura será iniciada automaticamente.',
      },
      {
        'question': 'Como cancelo minha assinatura?',
        'answer': 'iOS: Configurações > [seu nome] > Assinaturas > ReceitaAgro > Cancelar Assinatura.\n\nAndroid: Google Play Store > Menu > Assinaturas > ReceitaAgro > Cancelar.\n\nO cancelamento será efetivo no final do período atual. Durante a avaliação gratuita, cancele até 24h antes do término para evitar cobrança.',
      },
      {
        'question': 'Posso usar em vários dispositivos?',
        'answer': 'Sim! Sua assinatura premium funciona em todos os dispositivos conectados à mesma conta. Os dados são sincronizados automaticamente entre eles.',
      },
      {
        'question': 'Os dados funcionam offline?',
        'answer': 'Muitas funcionalidades do ReceitaAgro funcionam offline após o download inicial. Para diagnósticos e atualizações, é necessária conexão com a internet.',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perguntas Frequentes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...faqItems.map((item) => _buildFaqItem(
            context,
            item['question']!,
            item['answer']!,
          )),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
