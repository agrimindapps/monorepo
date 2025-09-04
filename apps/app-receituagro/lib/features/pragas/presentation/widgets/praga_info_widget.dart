import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/spacing_tokens.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../providers/detalhe_praga_provider.dart';

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
    return Consumer<DetalhePragaProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 0,      // Remove top padding para economizar espaço
            bottom: SpacingTokens.bottomNavSpace, // Espaço para bottom nav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPragaImage(),
              SpacingTokens.gapSM,
              ..._buildInfoSections(provider),
              // Espaço já incluído no scrollPadding
            ],
          ),
        );
      },
    );
  }

  /// Constrói seções de informação baseado no tipo da praga
  List<Widget> _buildInfoSections(DetalhePragaProvider provider) {
    final pragaData = provider.pragaData;
    
    if (pragaData == null) {
      return [_buildLoadingWidget()];
    }

    // Para pragas do tipo "inseto" (tipoPraga = "1") ou "doença" (tipoPraga = "2")
    if (pragaData.tipoPraga == '1' || pragaData.tipoPraga == '2') {
      return _buildInsectoInfoSections(provider);
    }
    
    // Para pragas do tipo "planta" (tipoPraga = "3")
    if (pragaData.tipoPraga == '3') {
      return _buildPlantaInfoSections(provider);
    }
    
    return [_buildNoInfoWidget()];
  }

  /// Seções de informação para insetos/doenças (usa PragasInfo)
  List<Widget> _buildInsectoInfoSections(DetalhePragaProvider provider) {
    final pragaInfo = provider.pragaInfo;
    
    return [
      _buildInfoSection(
        'Descrição',
        Icons.bug_report,
        [
          _buildInfoItem(
            'Informações Gerais',
            pragaInfo?.descrisao ?? 'Informação não disponível',
          ),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Sintomas',
        Icons.warning,
        [
          _buildInfoItem(
            'Danos Causados',
            pragaInfo?.sintomas ?? 'Informação não disponível',
          ),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Bioecologia',
        Icons.science,
        [
          _buildInfoItem(
            'Características Biológicas',
            pragaInfo?.bioecologia ?? 'Informação não disponível',
          ),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Controle',
        Icons.shield,
        [
          _buildInfoItem(
            'Métodos de Controle',
            pragaInfo?.controle ?? 'Informação não disponível',
          ),
        ],
      ),
    ];
  }

  /// Seções de informação para plantas (usa PlantasInfo)
  List<Widget> _buildPlantaInfoSections(DetalhePragaProvider provider) {
    final plantaInfo = provider.plantaInfo;
    
    return [
      _buildInfoSection(
        'Informações da Planta',
        Icons.eco,
        [
          _buildInfoItem('Ciclo', plantaInfo?.ciclo ?? '-'),
          _buildInfoItem('Reprodução', plantaInfo?.reproducao ?? '-'),
          _buildInfoItem('Habitat', plantaInfo?.habitat ?? '-'),
          _buildInfoItem('Adaptações', plantaInfo?.adaptacoes ?? '-'),
          _buildInfoItem('Altura', plantaInfo?.altura ?? '-'),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Informações das Flores',
        Icons.local_florist,
        [
          _buildInfoItem('Inflorescência', plantaInfo?.inflorescencia ?? '-'),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Informações das Folhas',
        Icons.park,
        [
          _buildInfoItem('Filotaxia', plantaInfo?.filotaxia ?? '-'),
          _buildInfoItem('Forma do Limbo', plantaInfo?.formaLimbo ?? '-'),
          _buildInfoItem('Superfície', plantaInfo?.superficie ?? '-'),
          _buildInfoItem('Consistência', plantaInfo?.consistencia ?? '-'),
          _buildInfoItem('Nervação', plantaInfo?.nervacao ?? '-'),
          _buildInfoItem('Comprimento da Nervação', plantaInfo?.nervacaoComprimento ?? '-'),
        ],
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Fruto',
        null,
        [
          _buildInfoItem('Fruto', plantaInfo?.tipologiaFruto ?? '-'),
        ],
      ),
    ];
  }

  /// Widget de loading
  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Widget para quando não há informações disponíveis
  Widget _buildNoInfoWidget() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Informações não disponíveis',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói widget de imagem da praga
  Widget _buildPragaImage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
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
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
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
              const SizedBox(height: 10),
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
          padding: const EdgeInsets.symmetric(vertical: 6.0),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Divider(
                height: 12,
                color: theme.dividerColor,
              ),
            ],
          ),
        );
      },
    );
  }
}