import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import 'diagnostico_mockup_tokens.dart';

/// Widget que replica EXATAMENTE o design do card do mockup IMG_3186.PNG
///
/// Layout do mockup analisado:
/// - Container branco com shadow sutil
/// - Ícone verde quadrado com símbolo químico
/// - Nome do produto em negrito
/// - Ingrediente ativo em cinza
/// - Dosagem oculta com "••• mg/L" se premium
/// - Ícone premium amarelo (⚠️)
/// - Chevron (>) para navegação
///
/// Responsabilidade única: renderizar card de diagnóstico pixel-perfect
class DiagnosticoMockupCard extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final VoidCallback onTap;
  final bool isPremium;

  const DiagnosticoMockupCard({
    super.key,
    required this.diagnostico,
    required this.onTap,
    this.isPremium = true, // Por padrão considera premium para mostrar "•••"
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: DiagnosticoMockupTokens.cardMargin,
        child: Material(
          color: DiagnosticoMockupTokens.cardBackground,
          borderRadius: BorderRadius.circular(
            DiagnosticoMockupTokens.cardBorderRadius,
          ),
          elevation: 0, // Usaremos box shadow customizado
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              DiagnosticoMockupTokens.cardBorderRadius,
            ),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: DiagnosticoMockupTokens.cardHeight,
              ),
              padding: DiagnosticoMockupTokens.cardPadding,
              decoration: BoxDecoration(
                color: DiagnosticoMockupTokens.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(
                  DiagnosticoMockupTokens.cardBorderRadius,
                ),
                boxShadow: DiagnosticoMockupTokens.getCardShadow(context),
              ),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(
                      width: DiagnosticoMockupTokens.cardInternalSpacing),
                  Expanded(child: _buildContent(context)),
                  const SizedBox(
                      width: DiagnosticoMockupTokens.cardInternalSpacing),
                  _buildTrailing(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ícone verde quadrado com símbolo químico exatamente como no mockup
  Widget _buildIcon() {
    return Container(
      width: DiagnosticoMockupTokens.cardIconSize,
      height: DiagnosticoMockupTokens.cardIconSize,
      decoration: BoxDecoration(
        color: DiagnosticoMockupTokens.primaryGreen,
        borderRadius: BorderRadius.circular(8), // Cantos levemente arredondados
      ),
      child: const Icon(
        DiagnosticoMockupTokens.cardIcon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Conteúdo principal: nome, ingrediente ativo e dosagem
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          diagnostico.nome,
          style: DiagnosticoMockupTokens.cardProductNameStyle.copyWith(
            color: DiagnosticoMockupTokens.getTextColor(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          diagnostico.ingredienteAtivo,
          style: DiagnosticoMockupTokens.cardIngredientStyle.copyWith(
            color: DiagnosticoMockupTokens.getTextColor(context, isSecondary: true),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          _getDosageText(),
          style: DiagnosticoMockupTokens.cardDosageStyle.copyWith(
            color: DiagnosticoMockupTokens.getTextColor(context, isSecondary: true),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Área direita com ícone premium e chevron
  Widget _buildTrailing() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          DiagnosticoMockupTokens.premiumIcon,
          color: DiagnosticoMockupTokens.premiumWarning,
          size: DiagnosticoMockupTokens.premiumIconSize,
        ),
        SizedBox(width: 8),
        Icon(
          DiagnosticoMockupTokens.chevronIcon,
          color: DiagnosticoMockupTokens.chevronColor,
          size: DiagnosticoMockupTokens.chevronSize,
        ),
      ],
    );
  }

  /// Retorna texto da dosagem - oculto se premium
  String _getDosageText() {
    if (isPremium) {
      return DiagnosticoMockupTokens.dosagePrefix +
          DiagnosticoMockupTokens.hiddenDosage;
    }
    return DiagnosticoMockupTokens.dosagePrefix + diagnostico.dosagem;
  }
}

/// Widget premium-aware que verifica automaticamente o status premium
/// do usuário e aplica as regras de ocultação de dosagem
class DiagnosticoMockupCardPremium extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final VoidCallback onTap;

  const DiagnosticoMockupCardPremium({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPremiumStatus(),
      builder: (context, snapshot) {
        final isUserPremium = snapshot.data ?? false;

        return DiagnosticoMockupCard(
          diagnostico: diagnostico,
          onTap: onTap,
          isPremium: !isUserPremium, // Se não é premium, oculta dosagem
        );
      },
    );
  }

  /// Verifica status premium usando o service registrado
  Future<bool> _checkPremiumStatus() async {
    try {
      final premiumService = sl<IPremiumService>();
      return await premiumService.isPremiumUser();
    } catch (e) {
      return false;
    }
  }
}

/// Factory para criar cards com diferentes estados
mixin DiagnosticoMockupCardFactory {
  /// Cria card padrão com estado premium automático
  static Widget create({
    required DiagnosticoModel diagnostico,
    required VoidCallback onTap,
  }) {
    return DiagnosticoMockupCardPremium(
      diagnostico: diagnostico,
      onTap: onTap,
    );
  }

  /// Cria card com estado premium explícito
  static Widget createWithPremiumState({
    required DiagnosticoModel diagnostico,
    required VoidCallback onTap,
    required bool isPremium,
  }) {
    return DiagnosticoMockupCard(
      diagnostico: diagnostico,
      onTap: onTap,
      isPremium: isPremium,
    );
  }

  /// Cria card para preview (sempre mostra dosagem)
  static Widget createPreview({
    required DiagnosticoModel diagnostico,
    required VoidCallback onTap,
  }) {
    return DiagnosticoMockupCard(
      diagnostico: diagnostico,
      onTap: onTap,
      isPremium: false, // Sempre mostra dosagem no preview
    );
  }
}
