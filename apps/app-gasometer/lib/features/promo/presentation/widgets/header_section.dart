import 'package:flutter/material.dart';

import 'notification_form_dialog.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.indigo[900]!],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 40,
              vertical: 80,
            ),
            child: isMobile
                ? _buildMobileContent(context)
                : _buildDesktopContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Textos e botões à esquerda
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderText(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 24),
              _buildDownloadBadges(context),
            ],
          ),
        ),

        // Imagem à direita
        Expanded(
          flex: 5,
          child: _buildAppShowcase(),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderText(),
        const SizedBox(height: 24),
        _buildActionButtons(context),
        const SizedBox(height: 20),
        _buildDownloadBadges(context),
        const SizedBox(height: 48),
        _buildAppShowcase(),
      ],
    );
  }

  Widget _buildHeaderText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal
        Text(
          'Controle Total\npara seu Veículo',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 24),

        // Descrição
        Text(
          'Gerencie abastecimentos, manutenções e despesas do seu veículo com o aplicativo mais completo do mercado.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const NotificationFormDialog(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[400],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quero ser Notificado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.notifications, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadBadges(BuildContext context) {
    return Row(
      children: [
        // Google Play badge
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const NotificationFormDialog(),
            );
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.android, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EM BREVE NA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Google Play',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // App Store badge
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const NotificationFormDialog(),
            );
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.apple, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EM BREVE NA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'App Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppShowcase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Círculo decorativo
        Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),

        // Imagem do mockup do app
        Container(
          width: 280,
          height: 520,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Placeholder para a screenshot do app
                Container(
                  color: Colors.blue[900],
                  width: double.infinity,
                  height: double.infinity,
                ),

                // Notch da tela
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 120,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Interface do app (mockup)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Icon(
                        Icons.local_gas_station,
                        size: 60,
                        color: Colors.amber[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'GasOMeter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Gráfico simplificado
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              5,
                              (index) => Container(
                                width: 30,
                                height: 70 + (index * 10),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.amber[400]!.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Menu simulado
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.amber[400]),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meu Veículo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Honda Civic 2022',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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

        // Elementos flutuantes decorativos
        Positioned(
          top: 50,
          right: 40,
          child: _buildFloatingElement(Icons.local_gas_station, Colors.amber),
        ),
        Positioned(
          bottom: 80,
          left: 40,
          child: _buildFloatingElement(Icons.bar_chart, Colors.green),
        ),
        Positioned(
          bottom: 180,
          right: 30,
          child: _buildFloatingElement(Icons.speed, Colors.red),
        ),
      ],
    );
  }

  Widget _buildFloatingElement(IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}