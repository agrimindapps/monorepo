import 'package:flutter/material.dart';

import '../../../../core/widgets/praga_image_widget.dart';

/// Widget responsável por exibir informações da praga
/// Responsabilidade única: renderizar seção de informações básicas
class PragaInfoWidget extends StatelessWidget {
  final String pragaName;
  final String pragaScientificName;

  const PragaInfoWidget({
    super.key,
    required this.pragaName,
    required this.pragaScientificName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPragaImage(),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações da Planta',
            Icons.eco,
            [
              _buildInfoItem('Ciclo', '-'),
              _buildInfoItem('Reprodução', '-'),
              _buildInfoItem('Habitat', '-'),
              _buildInfoItem('Adaptações', '-'),
              _buildInfoItem('Altura', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações das Flores',
            Icons.local_florist,
            [
              _buildInfoItem('Inflorescência', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações das Folhas',
            Icons.park,
            [
              _buildInfoItem('Filotaxia', '-'),
              _buildInfoItem('Forma do Limbo', '-'),
              _buildInfoItem('Superfície', '-'),
              _buildInfoItem('Consistência', '-'),
              _buildInfoItem('Nervação', '-'),
              _buildInfoItem('Comprimento da Nervação', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Fruto',
            null,
            [
              _buildInfoItem('Fruto', '-'),
            ],
          ),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  /// Constrói widget de imagem da praga
  Widget _buildPragaImage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calcula altura baseada na largura disponível (proporção 16:9)
          final imageHeight = constraints.maxWidth * 0.56;

          return PragaImageWidget(
            nomeCientifico: pragaScientificName,
            width: double.infinity,
            height: imageHeight,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(16),
            errorWidget: Container(
              width: double.infinity,
              height: imageHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bug_report,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagem não disponível',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Constrói seção de informações
  Widget _buildInfoSection(String title, IconData? icon, List<Widget> items) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      // Funcionalidade de áudio
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items,
            ],
          ),
        );
      },
    );
  }

  /// Constrói item de informação
  Widget _buildInfoItem(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Divider(
                height: 16,
                color: theme.dividerColor,
              ),
            ],
          ),
        );
      },
    );
  }
}