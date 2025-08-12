// Flutter imports:
import 'package:flutter/material.dart';

class TodoistCallToActionSection extends StatelessWidget {
  const TodoistCallToActionSection({super.key});

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
            Color(0xFFE44332),
            Color(0xFFFF6B47),
            Color(0xFFFF8A65),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Formas decorativas
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: screenSize.width * 0.2,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 40,
                  vertical: 100,
                ),
                child: Column(
                  children: [
                    // Elementos de destaque
                    isMobile ? _buildMobileContent() : _buildDesktopContent(),

                    // Informações de segurança e confiança
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTrustBadge(
                            Icons.verified_user, 'Gratuito para começar'),
                        Container(
                          height: 24,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildTrustBadge(Icons.lock, 'Dados protegidos'),
                        Container(
                          height: 24,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildTrustBadge(Icons.sync, 'Sincronização em nuvem'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Coluna da esquerda: texto e botões
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título com destaque
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pronto para ser mais ',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Produtivo?',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFE0B2),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Subtítulo
              const Text(
                'Baixe agora o Todoist e tenha controle total sobre suas tarefas e projetos com o aplicativo mais completo para produtividade.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Botões de download com badge
              Row(
                children: [
                  _buildStoreButton(
                    'Google Play',
                    Icons.android,
                    Colors.green[700]!,
                  ),
                  const SizedBox(width: 20),
                  _buildStoreButton(
                    'App Store',
                    Icons.apple,
                    Colors.grey[800]!,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 60),

        // Coluna da direita: dispositivos
        Expanded(
          flex: 4,
          child: _buildDevicesShowcase(),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        // Título principal
        const Text(
          'Pronto para ser mais Produtivo?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFE0B2),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Subtítulo
        const Text(
          'Baixe agora o Todoist e tenha controle total sobre suas tarefas e projetos.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),

        // Showcase de dispositivos
        SizedBox(
          height: 300,
          child: _buildDevicesShowcase(),
        ),
        const SizedBox(height: 30),

        // Botões de download
        Column(
          children: [
            _buildStoreButton(
              'Google Play',
              Icons.android,
              Colors.green[700]!,
              isFullWidth: true,
            ),
            const SizedBox(height: 16),
            _buildStoreButton(
              'App Store',
              Icons.apple,
              Colors.grey[800]!,
              isFullWidth: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreButton(String store, IconData icon, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Ação do botão
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponível na',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      store,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevicesShowcase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Smartphone em destaque
        Container(
          width: 220,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Tela do app
                Container(
                  color: const Color(0xFF2D1B1E),
                  width: double.infinity,
                  height: double.infinity,
                ),

                // Interface simplificada
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Color(0xFFFFE0B2),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Todoist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'ORGANIZE TUDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Elementos de destaque ao redor
        Positioned(
          top: 50,
          left: 30,
          child: _buildFeatureBubble(
              'Lembretes inteligentes', const Color(0xFFFF6B47)),
        ),
        Positioned(
          bottom: 70,
          right: 20,
          child: _buildFeatureBubble(
              'Sincronização automática', const Color(0xFFFF8A65)),
        ),
        Positioned(
          top: 150,
          right: 40,
          child: _buildFeatureBubble(
              'Colaboração em equipe', const Color(0xFFFFAB91)),
        ),
      ],
    );
  }

  Widget _buildFeatureBubble(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
