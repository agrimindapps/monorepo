// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/detalhes_pragas_design_tokens.dart';

/// Widget de card de informação da praga com suporte a TTS
class PragaCardInfo extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final double fontSize;
  final bool isDark;
  final VoidCallback? onTtsPressed;
  final bool isTtsPlaying;

  const PragaCardInfo({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.fontSize,
    required this.isDark,
    this.onTtsPressed,
    this.isTtsPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty || content.trim() == '-') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DetalhesPragasDesignTokens.mediumSpacing),
      child: DecoratedBox(
        decoration: DetalhesPragasDesignTokens.cardDecorationFlat(context,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(DetalhesPragasDesignTokens.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
          size: 20,
        ),
        const SizedBox(width: 8),
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
        if (onTtsPressed != null) _buildTtsButton(),
      ],
    );
  }

  Widget _buildTtsButton() {
    return IconButton(
      icon: Icon(
        isTtsPlaying ? Icons.volume_off : Icons.volume_up,
        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
      ),
      onPressed: onTtsPressed,
      tooltip: isTtsPlaying ? 'Parar leitura' : 'Ouvir texto',
    );
  }

  Widget _buildContent() {
    return Text(
      content,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.5,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
      ),
    );
  }
}
