import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../../../../core/widgets/praga_image_widget.dart';
import '../../../../core/widgets/tts_button.dart';
import '../providers/detalhe_praga_notifier.dart';

/// Widget responsável por exibir informações da praga
/// Responsabilidade única: renderizar seção de informações básicas
class PragaInfoWidget extends ConsumerWidget {
  final String pragaName;
  final String pragaScientificName;
  final bool showDividers;

  const PragaInfoWidget({
    super.key,
    required this.pragaName,
    required this.pragaScientificName,
    this.showDividers = false, // Por padrão não mostra dividers
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detalhePragaNotifierProvider);

    return state.when(
      data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 0,      // Remove top padding para economizar espaço
            bottom: SpacingTokens.bottomNavSpace, // Espaço para bottom nav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPragaImage(),
              SpacingTokens.gapSM,
              ..._buildInfoSections(data),
            ],
          ),
        ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  /// Constrói seções de informação baseado no tipo da praga
  List<Widget> _buildInfoSections(dynamic data) {
    final pragaData = data.pragaData;
    
    if (pragaData == null) {
      return [_buildLoadingWidget()];
    }
    if (pragaData.tipoPraga == '1' || pragaData.tipoPraga == '2') {
      return _buildInsectoInfoSections(data);
    }
    if (pragaData.tipoPraga == '3') {
      return _buildPlantaInfoSections(data);
    }

    return [_buildNoInfoWidget()];
  }

  /// Seções de informação para insetos/doenças (usa PragasInfo)
  List<Widget> _buildInsectoInfoSections(dynamic data) {
    final pragaInfo = data.pragaInfo;

    final descricao = (pragaInfo?.descrisao ?? 'Informação não disponível') as String;
    final sintomas = (pragaInfo?.sintomas ?? 'Informação não disponível') as String;
    final bioecologia = (pragaInfo?.bioecologia ?? 'Informação não disponível') as String;
    final controle = (pragaInfo?.controle ?? 'Informação não disponível') as String;

    return [
      _buildInfoSection(
        'Descrição',
        Icons.bug_report,
        [
          _buildInfoItem('Informações Gerais', descricao),
        ],
        sectionContent: 'Descrição: $descricao',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Sintomas',
        Icons.warning,
        [
          _buildInfoItem('Danos Causados', sintomas),
        ],
        sectionContent: 'Sintomas: $sintomas',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Bioecologia',
        Icons.science,
        [
          _buildInfoItem('Características Biológicas', bioecologia),
        ],
        sectionContent: 'Bioecologia: $bioecologia',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Controle',
        Icons.shield,
        [
          _buildInfoItem('Métodos de Controle', controle),
        ],
        sectionContent: 'Controle: $controle',
      ),
    ];
  }

  /// Seções de informação para plantas (usa PlantasInfo)
  List<Widget> _buildPlantaInfoSections(dynamic data) {
    final plantaInfo = data.plantaInfo;

    final ciclo = (plantaInfo?.ciclo ?? '-') as String;
    final reproducao = (plantaInfo?.reproducao ?? '-') as String;
    final habitat = (plantaInfo?.habitat ?? '-') as String;
    final adaptacoes = (plantaInfo?.adaptacoes ?? '-') as String;
    final altura = (plantaInfo?.altura ?? '-') as String;
    final inflorescencia = (plantaInfo?.inflorescencia ?? '-') as String;
    final filotaxia = (plantaInfo?.filotaxia ?? '-') as String;
    final formaLimbo = (plantaInfo?.formaLimbo ?? '-') as String;
    final superficie = (plantaInfo?.superficie ?? '-') as String;
    final consistencia = (plantaInfo?.consistencia ?? '-') as String;
    final nervacao = (plantaInfo?.nervacao ?? '-') as String;
    final nervacaoComprimento = (plantaInfo?.nervacaoComprimento ?? '-') as String;
    final tipologiaFruto = (plantaInfo?.tipologiaFruto ?? '-') as String;

    return [
      _buildInfoSection(
        'Informações da Planta',
        Icons.eco,
        [
          _buildInfoItem('Ciclo', ciclo),
          _buildInfoItem('Reprodução', reproducao),
          _buildInfoItem('Habitat', habitat),
          _buildInfoItem('Adaptações', adaptacoes),
          _buildInfoItem('Altura', altura),
        ],
        sectionContent: 'Informações da Planta: Ciclo: $ciclo. Reprodução: $reproducao. Habitat: $habitat. Adaptações: $adaptacoes. Altura: $altura',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Informações das Flores',
        Icons.local_florist,
        [
          _buildInfoItem('Inflorescência', inflorescencia),
        ],
        sectionContent: 'Informações das Flores: Inflorescência: $inflorescencia',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Informações das Folhas',
        Icons.park,
        [
          _buildInfoItem('Filotaxia', filotaxia),
          _buildInfoItem('Forma do Limbo', formaLimbo),
          _buildInfoItem('Superfície', superficie),
          _buildInfoItem('Consistência', consistencia),
          _buildInfoItem('Nervação', nervacao),
          _buildInfoItem('Comprimento da Nervação', nervacaoComprimento),
        ],
        sectionContent: 'Informações das Folhas: Filotaxia: $filotaxia. Forma do Limbo: $formaLimbo. Superfície: $superficie. Consistência: $consistencia. Nervação: $nervacao. Comprimento da Nervação: $nervacaoComprimento',
      ),
      SpacingTokens.gapMD,
      _buildInfoSection(
        'Fruto',
        null,
        [
          _buildInfoItem('Fruto', tipologiaFruto),
        ],
        sectionContent: 'Fruto: $tipologiaFruto',
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
  Widget _buildInfoSection(String title, IconData? icon, List<Widget> items, {String? sectionContent}) {
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
                  if (sectionContent != null)
                    TTSButton(
                      text: sectionContent,
                      title: title,
                      iconSize: 20,
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
              // Divider condicional
              if (showDividers)
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
