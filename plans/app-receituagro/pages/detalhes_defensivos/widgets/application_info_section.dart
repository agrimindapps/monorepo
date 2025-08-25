// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/detalhes_defensivos_design_tokens.dart';
import '../controller/detalhes_defensivos_controller.dart';

class ApplicationInfoSection extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final DetalhesDefensivosController controller;

  const ApplicationInfoSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.controller,
  });

  @override
  State<ApplicationInfoSection> createState() => _ApplicationInfoSectionState();
}

class _ApplicationInfoSectionState extends State<ApplicationInfoSection> {
  late final String formattedContent;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // Formatamos o conteúdo no initState para evitar formatação durante o build
    formattedContent = widget.controller.formatText(widget.content);
    
    // Delay para evitar conflitos de build com widgets reativos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (!_isReady) {
      return Container(
        height: 120,
        margin: const EdgeInsets.only(
            bottom: DetalhesDefensivosDesignTokens.mediumSpacing),
        decoration: DetalhesDefensivosDesignTokens.cardDecorationFlat(context),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final accentColor =
        DetalhesDefensivosDesignTokens.getContentTypeColor('aplicacao');

    return Container(
      margin: const EdgeInsets.only(
          bottom: DetalhesDefensivosDesignTokens.mediumSpacing),
      decoration: DetalhesDefensivosDesignTokens.sectionDecoration(context,
          accentColor: accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Container(
            padding: DetalhesDefensivosDesignTokens.contentPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.8),
                  accentColor.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                    DetalhesDefensivosDesignTokens.defaultBorderRadius),
                topRight: Radius.circular(
                    DetalhesDefensivosDesignTokens.defaultBorderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                      DetalhesDefensivosDesignTokens.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                        DetalhesDefensivosDesignTokens.smallBorderRadius),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: DetalhesDefensivosDesignTokens.defaultIconSize,
                  ),
                ),
                const SizedBox(
                    width: DetalhesDefensivosDesignTokens.mediumSpacing),
                Expanded(
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style:
                        DetalhesDefensivosDesignTokens.cardTitleStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildTtsButton(context, accentColor),
              ],
            ),
          ),

          // Conteúdo da seção
          Container(
            padding: DetalhesDefensivosDesignTokens.cardPadding,
            child: SelectableText(
              formattedContent,
              key: ValueKey('text_${widget.title}'),
              style:
                  DetalhesDefensivosDesignTokens.cardSubtitleStyle.copyWith(
                fontSize: widget.controller.fontSize.value,
                color: DetalhesDefensivosDesignTokens.getTextColor(context),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtsButton(BuildContext context, Color accentColor) {
    return _TtsButton(
      controller: widget.controller,
      content: widget.content,
      accentColor: accentColor,
    );
  }
}

// Widget separado para isolar a reatividade do TTS
class _TtsButton extends StatelessWidget {
  final DetalhesDefensivosController controller;
  final String content;
  final Color accentColor;

  const _TtsButton({
    required this.controller,
    required this.content,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
              DetalhesDefensivosDesignTokens.smallBorderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            FontAwesome.volume_high_solid,
            color: Colors.white,
            size: DetalhesDefensivosDesignTokens.defaultIconSize - 4,
          ),
          onPressed: () {
            controller.toggleTts(content);
          },
          tooltip: 'Ouvir texto',
        ),
      ),
    );
  }
}
