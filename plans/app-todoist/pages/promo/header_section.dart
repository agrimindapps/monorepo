// Flutter imports:
import 'package:flutter/material.dart';

class TodoistHeaderSection extends StatelessWidget {
  const TodoistHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE44332), // Vermelho característico do Todoist
            Color(0xFFFF6B47), // Tom mais claro
            Color(0xFFFF8A65), // Tom ainda mais claro
          ],
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 100,
          horizontal: isMobile ? 20 : 40,
        ),
        child: Column(
          children: [
            // Logo e título principal
            Column(
              children: [
                // Logo/Ícone
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Título principal
                Text(
                  'Todoist',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 48 : 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtítulo
                Text(
                  'Organize tudo. Alcance mais.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // Descrição
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(
                    'A ferramenta de produtividade que ajuda você a organizar suas tarefas, projetos e vida de forma simples e eficiente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Botões de ação
                isMobile ? _buildMobileButtons() : _buildDesktopButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrimaryButton('Começar Gratuitamente', Icons.rocket_launch),
        const SizedBox(width: 20),
        _buildSecondaryButton('Ver Demonstração', Icons.play_circle_outline),
      ],
    );
  }

  Widget _buildMobileButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child:
              _buildPrimaryButton('Começar Gratuitamente', Icons.rocket_launch),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildSecondaryButton(
              'Ver Demonstração', Icons.play_circle_outline),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implementar navegação para o app
      },
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE44332),
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implementar demonstração
      },
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
