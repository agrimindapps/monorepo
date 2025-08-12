// Flutter imports:
import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity, // Garante que ocupe toda a largura
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 0, // Remove padding horizontal em desktop
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título da seção com gradiente
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

          // Container de largura total para os passos
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
            'Registre manutenções realizadas e receba alertas para as próximas.',
            Icons.build,
            Colors.amber[700]!,
          ),
        ),
        Expanded(
          child: _buildStep(
            '4',
            'Visualize Estatísticas',
            'Analise gráficos de consumo, gastos e desempenho do seu veículo.',
            Icons.bar_chart,
            Colors.purple[700]!,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSteps(BuildContext context) {
    // Para mobile, mantém o Wrap com cards de largura total
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildStep(
          '1',
          'Cadastre seu Veículo',
          'Adicione informações básicas como modelo, ano e quilometragem inicial.',
          Icons.directions_car,
          Colors.blue[700]!,
          isFullWidth: true,
        ),
        _buildStep(
          '2',
          'Registre Abastecimentos',
          'Insira dados de cada abastecimento como preço, quantidade e quilometragem.',
          Icons.local_gas_station,
          Colors.green[700]!,
          isFullWidth: true,
        ),
        _buildStep(
          '3',
          'Acompanhe Manutenções',
          'Registre manutenções realizadas e receba alertas para as próximas.',
          Icons.build,
          Colors.amber[700]!,
          isFullWidth: true,
        ),
        _buildStep(
          '4',
          'Visualize Estatísticas',
          'Analise gráficos de consumo, gastos e desempenho do seu veículo.',
          Icons.bar_chart,
          Colors.purple[700]!,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String description,
      IconData icon, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone com círculo numerado
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculo decorativo atrás do ícone
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
              ),

              // Número do passo
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Título
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

          // Descrição
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
