// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../../services/premium_service.dart';
import '../../../widgets/diagnostic_application_dialog.dart';
import '../constants/detalhes_pragas_design_tokens.dart';
import '../controller/detalhes_pragas_controller.dart';

/// Widget especializado para exibir itens de diagnóstico de pragas
/// Baseado no padrão visual superior de detalhes_defensivos
class PragaDiagnosticItemWidget extends StatelessWidget {
  final Map<dynamic, dynamic> diagnostico;
  final DetalhesPragasController controller;
  final VoidCallback? onTap;
  final bool? isDark;

  const PragaDiagnosticItemWidget({
    super.key,
    required this.diagnostico,
    required this.controller,
    this.onTap,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Use the passed isDark parameter or fallback to ThemeController
    if (isDark != null) {
      return _buildWidget(context, isDark!);
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) =>
          _buildWidget(context, themeController.isDark.value),
    );
  }

  Widget _buildWidget(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onTap ?? () => _showDiagnosticDialog(context),
      child: Container(
        padding: DetalhesPragasDesignTokens.contentPadding,
        child: Row(
          children: [
            _buildDefensivoImage(context, isDark),
            const SizedBox(width: DetalhesPragasDesignTokens.mediumSpacing),
            Expanded(child: _buildContentColumn(context, isDark)),
            _buildTrailingIcon(context, isDark),
          ],
        ),
      ),
    );
  }

  /// Constrói o container da imagem do defensivo
  Widget _buildDefensivoImage(BuildContext context, bool isDark) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(
            DetalhesPragasDesignTokens.defaultBorderRadius),
        border: Border.all(
          color: DetalhesPragasDesignTokens.getBorderColor(context),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            DetalhesPragasDesignTokens.defaultBorderRadius),
        child: _buildDefensivoImageContent(isDark),
      ),
    );
  }

  /// Constrói o conteúdo da imagem (ícone como fallback)
  Widget _buildDefensivoImageContent(bool isDark) {
    // Por enquanto, usando ícone como placeholder
    // Futuramente pode ser implementado carregamento de imagem real
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DetalhesPragasDesignTokens.primaryColor.withValues(alpha: 0.8),
            DetalhesPragasDesignTokens.accentColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: const Icon(
        FontAwesome.spray_can_sparkles_solid,
        color: Colors.white,
        size: DetalhesPragasDesignTokens.defaultIconSize,
      ),
    );
  }

  /// Constrói a coluna de conteúdo principal
  Widget _buildContentColumn(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDefensivoName(context, isDark),
        const SizedBox(height: 2),
        _buildIngredienteAtivoInfo(context, isDark),
        const SizedBox(height: 2),
        _buildDosagemInfo(context, isDark),
      ],
    );
  }

  /// Constrói o nome do defensivo
  Widget _buildDefensivoName(BuildContext context, bool isDark) {
    final nomeDefensivo = diagnostico['nomeDefensivo'] ??
        diagnostico['defensivo'] ??
        diagnostico['produto'] ??
        'Defensivo não especificado';

    return Text(
      nomeDefensivo,
      style: DetalhesPragasDesignTokens.cardTitleStyle.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói as informações do ingrediente ativo
  Widget _buildIngredienteAtivoInfo(BuildContext context, bool isDark) {
    final ingredienteAtivo = diagnostico['ingredienteAtivo'] ??
        diagnostico['principioAtivo'] ??
        diagnostico['nomeIngredienteAtivo'] ??
        diagnostico['ingrediente'] ??
        '';

    final quantidade = diagnostico['quantProduto'] ??
        diagnostico['quantidadeIngredienteAtivo'] ??
        diagnostico['concentracao'] ??
        diagnostico['teor'] ??
        diagnostico['percentual'] ??
        diagnostico['quantidade'] ??
        '';

    List<String> detalhes = [];
    if (ingredienteAtivo.isNotEmpty) {
      if (quantidade.toString().isNotEmpty) {
        detalhes.add('$ingredienteAtivo ($quantidade)');
      } else {
        detalhes.add(ingredienteAtivo);
      }
    }

    return Text(
      detalhes.isNotEmpty
          ? detalhes.join(' • ')
          : 'Ingrediente ativo não especificado',
      style: DetalhesPragasDesignTokens.bodySmallStyle.copyWith(
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói as informações de dosagem
  Widget _buildDosagemInfo(BuildContext context, bool isDark) {
    final premiumService = Get.find<PremiumService>();
    final isPremium = premiumService.isPremium;
    final dosagem = _getDosagemRecomendada();

    return Row(
      children: [
        Expanded(
          child: Text(
            isPremium ? dosagem : 'Dosagem: ••• mg/L',
            style: DetalhesPragasDesignTokens.bodySmallStyle.copyWith(
              color: isPremium 
                  ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                  : Colors.grey.shade400,
              fontWeight: isPremium ? FontWeight.normal : FontWeight.w300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.diamond,
            size: 10,
            color: Colors.amber.shade600,
          ),
        ],
      ],
    );
  }

  /// Extrai a dosagem recomendada de forma inteligente
  String _getDosagemRecomendada() {
    final dosagem = diagnostico['dosagem'] ??
        diagnostico['dosagemRecomendada'] ??
        diagnostico['dose'] ??
        diagnostico['aplicacao'] ??
        diagnostico['concentracao'];

    if (dosagem != null && dosagem.toString().isNotEmpty) {
      return 'Dosagem: ${dosagem.toString()}';
    }

    // Tentar extrair dosagens específicas
    final dosagemMinima =
        diagnostico['dosagemMinima'] ?? diagnostico['doseMin'];
    final dosagemMaxima =
        diagnostico['dosagemMaxima'] ?? diagnostico['doseMax'];

    if (dosagemMinima != null && dosagemMaxima != null) {
      return 'Dosagem: $dosagemMinima - $dosagemMaxima';
    }

    final vazaoTerrestre =
        diagnostico['vazaoTerrestre'] ?? diagnostico['vazaoTerra'];
    if (vazaoTerrestre != null && vazaoTerrestre.toString().isNotEmpty) {
      return 'Terrestre: ${vazaoTerrestre.toString()}';
    }

    final vazaoAerea = diagnostico['vazaoAerea'] ?? diagnostico['vazaoAero'];
    if (vazaoAerea != null && vazaoAerea.toString().isNotEmpty) {
      return 'Aérea: ${vazaoAerea.toString()}';
    }

    return 'Dosagem não especificada';
  }

  /// Constrói o ícone trailing
  Widget _buildTrailingIcon(BuildContext context, bool isDark) {
    return Icon(
      Icons.arrow_forward_ios,
      size: DetalhesPragasDesignTokens.smallIconSize,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    );
  }

  /// Mostra o dialog de detalhes do diagnóstico
  void _showDiagnosticDialog(BuildContext context) {
    final premiumService = Get.find<PremiumService>();
    
    DiagnosticApplicationDialog.show(
      context: context,
      data: diagnostico,
      isPremium: premiumService.isPremium,
      actions: [
        DialogAction(
          label: 'Defensivo',
          onPressed: () {
            Navigator.of(context).pop();
            final defensivoId = diagnostico['fkIdDefensivo'] ??
                diagnostico['idDefensivo'] ??
                '';
            if (defensivoId.isNotEmpty) {
              controller.navigateToDefensivo(defensivoId);
            }
          },
        ),
        DialogAction(
          label: 'Diagnóstico',
          onPressed: () {
            Navigator.of(context).pop();
            
            // Tentar múltiplas chaves possíveis para o ID
            final diagnosticoId = diagnostico['idReg'] ?? 
                diagnostico['id'] ?? 
                diagnostico['idDiagnostico'] ??
                diagnostico['diagnosticoId'] ??
                diagnostico['fkIdDiagnostico'] ??
                '';
            
            if (diagnosticoId.toString().isNotEmpty) {
              controller.navigateToDiagnostico(diagnosticoId.toString());
            } else {
              debugPrint('Nenhum ID válido encontrado para o diagnóstico');
            }
          },
        ),
      ],
    );
  }
}
