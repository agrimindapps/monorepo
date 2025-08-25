// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/praga_unica_model.dart';
import '../../constants/detalhes_pragas_design_tokens.dart';
import '../../controller/detalhes_pragas_controller.dart';
import '../../widgets/praga_card_info.dart';

/// Tab de informações da praga
class InformacoesTab extends GetView<DetalhesPragasController> {
  const InformacoesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetalhesPragasController>(
      id: 'praga_data',
      builder: (controller) {
        // Se está carregando, mostra loading
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Se não carregou dados, mostra mensagem de erro
        if (!controller.isPragaLoaded) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Dados não carregados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Verifique a conexão e tente novamente',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        final pragaDetails = controller.pragaDetails;
        // Se pragaDetails for null, mostra erro
        if (pragaDetails == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Erro ao processar dados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        final isDark = controller.isDark;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DetalhesPragasDesignTokens.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Praga Image Section
              _buildPragaImageSection(pragaDetails, isDark),

              // Type-specific Information Section
              _buildTypeSpecificInfo(context, pragaDetails, isDark),

              // Basic Information Section
              if (pragaDetails.temDescricao)
                _buildInfoCard(
                  title: 'Descrição',
                  icon: Icons.description,
                  content: pragaDetails.descricaoFormatada,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.descricaoFormatada),
                ),

              if (pragaDetails.temBiologia)
                _buildInfoCard(
                  title: 'Biologia',
                  icon: Icons.science,
                  content: pragaDetails.biologiaFormatada,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.biologiaFormatada),
                ),

              if (pragaDetails.temSintomas)
                _buildInfoCard(
                  title: 'Sintomas',
                  icon: Icons.medical_services,
                  content: pragaDetails.sintomasFormatados,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.sintomasFormatados),
                ),

              if (pragaDetails.temOcorrencia)
                _buildInfoCard(
                  title: 'Ocorrência',
                  icon: Icons.search,
                  content: pragaDetails.ocorrenciaFormatada,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.ocorrenciaFormatada),
                ),

              if (pragaDetails.temSinonimias)
                _buildInfoCard(
                  title: 'Sinonímias',
                  icon: Icons.label,
                  content: pragaDetails.sinonomiasFormatadas,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.sinonomiasFormatadas),
                ),

              if (pragaDetails.temNomesVulgares)
                _buildInfoCard(
                  title: 'Nomes Vulgares',
                  icon: Icons.translate,
                  content: pragaDetails.nomesVulgaresFormatados,
                  isDark: isDark,
                  onTtsPressed: () => controller
                      .handleTtsAction(pragaDetails.nomesVulgaresFormatados),
                ),

              // Bottom spacing
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPragaImageSection(dynamic pragaDetails, bool isDark) {
    final praga = pragaDetails.praga;
    final imagePath = praga.imagem;

    if (imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DetalhesPragasDesignTokens.mediumSpacing),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32).withValues(alpha: 0.8),
                    const Color(0xFF2E7D32).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Imagem da ${_getPragaTypeDisplayName(praga.tipoPraga)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Image Content
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Imagem não disponível',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2E7D32)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificInfo(BuildContext context, dynamic pragaDetails, bool isDark) {
    final praga = pragaDetails.praga;
    final tipoPraga = praga.tipoPraga;

    // Insetos e Doenças - mostram infoPraga
    if (tipoPraga == '1' || tipoPraga == '2') {
      return _buildInfoPragaSection(context, praga.infoPraga, tipoPraga, isDark);
    }

    // Plantas - mostram informações específicas da planta
    if (tipoPraga == '3') {
      return _buildInfoPlantaSection(context, praga, isDark);
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoPragaSection(
      BuildContext context, List<dynamic> infoPraga, String tipoPraga, bool isDark) {
    if (infoPraga.isEmpty) {
      return const SizedBox.shrink();
    }

    final title =
        tipoPraga == '1' ? 'Informações do Inseto' : 'Informações da Doença';
    final icon = tipoPraga == '1' ? Icons.bug_report : Icons.medical_services;

    return Container(
      margin: const EdgeInsets.only(bottom: DetalhesPragasDesignTokens.mediumSpacing),
      child: _buildFormattedInfoCard(
        context: context,
        title: title,
        icon: icon,
        infoList: infoPraga,
        isDark: isDark,
        onTtsPressed: () =>
            controller.handleTtsAction(_formatInfoItemList(infoPraga)),
      ),
    );
  }

  Widget _buildInfoPlantaSection(BuildContext context, dynamic praga, bool isDark) {
    final widgets = <Widget>[];

    if (praga.infoPlanta.isNotEmpty) {
      widgets.add(_buildFormattedInfoCard(
        context: context,
        title: 'Informações da Planta',
        icon: Icons.grass,
        infoList: praga.infoPlanta,
        isDark: isDark,
        onTtsPressed: () =>
            controller.handleTtsAction(_formatInfoItemList(praga.infoPlanta)),
      ));
    }

    if (praga.infoFlores.isNotEmpty) {
      widgets.add(_buildFormattedInfoCard(
        context: context,
        title: 'Informações das Flores',
        icon: Icons.local_florist,
        infoList: praga.infoFlores,
        isDark: isDark,
        onTtsPressed: () =>
            controller.handleTtsAction(_formatInfoItemList(praga.infoFlores)),
      ));
    }

    if (praga.infoFrutos.isNotEmpty) {
      widgets.add(_buildFormattedInfoCard(
        context: context,
        title: 'Informações dos Frutos',
        icon: Icons.eco,
        infoList: praga.infoFrutos,
        isDark: isDark,
        onTtsPressed: () =>
            controller.handleTtsAction(_formatInfoItemList(praga.infoFrutos)),
      ));
    }

    if (praga.infoFolhas.isNotEmpty) {
      widgets.add(_buildFormattedInfoCard(
        context: context,
        title: 'Informações das Folhas',
        icon: Icons.park,
        infoList: praga.infoFolhas,
        isDark: isDark,
        onTtsPressed: () =>
            controller.handleTtsAction(_formatInfoItemList(praga.infoFolhas)),
      ));
    }

    return Column(children: widgets);
  }

  Widget _buildFormattedInfoContent(
      List<dynamic> infoList, bool isDark, double fontSize) {
    if (infoList.isEmpty) return const SizedBox.shrink();

    final spans = <TextSpan>[];
    bool isFirstItem = true;

    for (final item in infoList) {
      String titulo = '';
      String descricao = '';

      // Handle InfoItem objects correctly
      if (item is InfoItem) {
        titulo = item.titulo;
        descricao = item.descricao;
      }
      // Handle Map objects for backward compatibility
      else if (item is Map<String, dynamic>) {
        titulo = item['titulo'] ?? '';
        descricao = item['descricao'] ?? '';
      } else {
        descricao = item.toString();
      }

      if (titulo.isEmpty && descricao.isEmpty) continue;

      // Add spacing between items (except for the first item)
      if (!isFirstItem) {
        spans.add(const TextSpan(text: '\n\n'));
      }

      // Add title in bold
      if (titulo.isNotEmpty) {
        spans.add(TextSpan(
          text: titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ));

        // Add line break between title and description
        if (descricao.isNotEmpty) {
          spans.add(const TextSpan(text: '\n'));
        }
      }

      // Add description
      if (descricao.isNotEmpty) {
        spans.add(TextSpan(
          text: descricao,
          style: TextStyle(
            fontSize: fontSize,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            height: 1.4,
          ),
        ));
      }

      isFirstItem = false;
    }

    if (spans.isEmpty) return const SizedBox.shrink();

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  String _formatInfoItemList(List<dynamic> infoList) {
    if (infoList.isEmpty) return '';

    return infoList
        .map((item) {
          // Handle InfoItem objects correctly
          if (item is InfoItem) {
            final String titulo = item.titulo;
            final String descricao = item.descricao;
            return titulo.isNotEmpty && descricao.isNotEmpty
                ? '$titulo\n$descricao'
                : (titulo.isNotEmpty ? titulo : descricao);
          }
          // Handle Map objects for backward compatibility
          if (item is Map<String, dynamic>) {
            final titulo = item['titulo'] ?? '';
            final descricao = item['descricao'] ?? '';
            return titulo.isNotEmpty && descricao.isNotEmpty
                ? '$titulo\n$descricao'
                : (titulo.isNotEmpty ? titulo : descricao);
          }
          return item.toString();
        })
        .where((text) => text.trim().isNotEmpty)
        .join('\n\n');
  }

  String _getPragaTypeDisplayName(String tipoPraga) {
    switch (tipoPraga) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta';
      default:
        return 'Praga';
    }
  }

  Widget _buildFormattedInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<dynamic> infoList,
    required bool isDark,
    required VoidCallback onTtsPressed,
  }) {
    if (infoList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DetalhesPragasDesignTokens.mediumSpacing),
      child: Obx(() {
        return DecoratedBox(
          decoration: DetalhesPragasDesignTokens.cardDecorationFlat(context,
            backgroundColor: isDark ? const Color(0xFF222228) : Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(DetalhesPragasDesignTokens.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF2E7D32),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        controller.isTtsSpeaking ? Icons.stop : Icons.volume_up,
                        color: const Color(0xFF2E7D32),
                      ),
                      onPressed: onTtsPressed,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Content with formatted InfoItems
                _buildFormattedInfoContent(
                    infoList, isDark, controller.fontSize.value),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
    required VoidCallback onTtsPressed,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DetalhesPragasDesignTokens.mediumSpacing),
      child: Obx(() => PragaCardInfo(
            title: title,
            icon: icon,
            content: content,
            fontSize: controller.fontSize.value,
            isDark: isDark,
            isTtsPlaying: controller.isTtsSpeaking,
            onTtsPressed: onTtsPressed,
          )),
    );
  }
}
