import 'package:flutter/material.dart';

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Como ',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Funciona',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Comece a controlar seus gastos em apenas 4 passos simples',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 0 : screenSize.width * 0.1),
            child: isMobile ? _buildMobileSteps(context) : _buildDesktopSteps(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildStep(
            '1',
            'Cadastre seu Veículo',
            'Adicione informações básicas como modelo, ano e quilometragem inicial.',
            Icons.directions_car,
            Colors.blue[700]!,
          ),
        ),
        Expanded(
          child: _buildStep(
            '2',
            'Registre Abastecimentos',
            'Insira dados de cada abastecimento como preço, quantidade e quilometragem.',
            Icons.local_gas_station,
            Colors.green[700]!,
          ),
        ),
        Expanded(
          child: _buildStep(
            '3',
            'Acompanhe Manutenções',
            'Registre manutenções e configure lembretes para não perder prazos.',
            Icons.build,
            Colors.amber[700]!,
          ),
        ),
        Expanded(
          child: _buildStep(
            '4',
            'Visualize Relatórios',
            'Analise gráficos de consumo, gastos e performance do seu veículo.',
            Icons.analytics,
            Colors.purple[700]!,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSteps(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          '1',
          'Cadastre seu Veículo',
          'Adicione informações básicas como modelo, ano e quilometragem inicial.',
          Icons.directions_car,
          Colors.blue[700]!,
        ),
        const SizedBox(height: 40),
        _buildStep(
          '2',
          'Registre Abastecimentos',
          'Insira dados de cada abastecimento como preço, quantidade e quilometragem.',
          Icons.local_gas_station,
          Colors.green[700]!,
        ),
        const SizedBox(height: 40),
        _buildStep(
          '3',
          'Acompanhe Manutenções',
          'Registre manutenções e configure lembretes para não perder prazos.',
          Icons.build,
          Colors.amber[700]!,
        ),
        const SizedBox(height: 40),
        _buildStep(
          '4',
          'Visualize Relatórios',
          'Analise gráficos de consumo, gastos e performance do seu veículo.',
          Icons.analytics,
          Colors.purple[700]!,
        ),
      ],
    );
  }

  Widget _buildStep(
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 2),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}