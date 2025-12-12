import 'package:flutter/material.dart';

class PrivacyInfoCollectionSection extends StatelessWidget {
  const PrivacyInfoCollectionSection({super.key});

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
                'Coleta e Uso de Informações',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Para uma melhor experiência, ao usar nosso Serviço, podemos exigir que você nos forneça determinadas informações de identificação pessoal, incluindo, entre outras, dados de abastecimento, quilometragem, despesas relacionadas ao veículo, informações sobre manutenções e odômetro. As informações que solicitamos serão retidas no seu dispositivo e podem ser sincronizadas com nossos servidores para backup e sincronização entre dispositivos.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'O aplicativo usa serviços de terceiros que podem coletar informações usadas para identificá-lo.'),
              const SizedBox(height: 20),
              const Text(
                'Link para a política de privacidade de provedores de serviços terceirizados usados pelo aplicativo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceLink('Serviços do Google Play',
                  'https://policies.google.com/privacy'),
              _buildServiceLink(
                  'AdMob', 'https://support.google.com/admob/answer/6128543'),
              _buildServiceLink('Google Analytics para Firebase',
                  'https://firebase.google.com/policies/analytics'),
              _buildServiceLink('Firebase Crashlytics',
                  'https://firebase.google.com/support/privacy'),
              _buildServiceLink('Firebase Cloud Storage',
                  'https://firebase.google.com/support/privacy'),
              _buildServiceLink('RevenueCat', 
                  'https://www.revenuecat.com/privacy'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildServiceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
