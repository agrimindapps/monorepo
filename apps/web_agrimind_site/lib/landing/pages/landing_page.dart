import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildProductsSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade900,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.agriculture, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Agrimind',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tecnologia Inteligente para o Campo e para a Vida',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Scroll to products
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Conheça Nossos Produtos'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Nossas Soluções',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _ProductCard(
                title: 'ReceituAgro',
                description: 'Diagnóstico e prescrição agrícola completa.',
                icon: Icons.assignment,
                color: Colors.green,
                url: 'https://receituagro.agrimind.com.br',
              ),
              _ProductCard(
                title: 'Petiveti',
                description: 'Gestão completa para saúde do seu pet.',
                icon: Icons.pets,
                color: Colors.orange,
                url: 'https://petiveti.agrimind.com.br', // Placeholder
              ),
              _ProductCard(
                title: 'Plantis',
                description: 'Cuidado inteligente para suas plantas.',
                icon: Icons.local_florist,
                color: Colors.teal,
                url: 'https://plantis.agrimind.com.br', // Placeholder
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} Agrimind. Todos os direitos reservados.',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Privacidade'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Termos de Uso'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String url;

  const _ProductCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                ),
                child: const Text('Acessar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
