// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../services/premium_service.dart';
import '../../../widgets/diagnostic_application_dialog.dart';
import '../controller/detalhes_defensivos_controller.dart';

class DiagnosticItemWidget extends StatelessWidget {
  final Map<dynamic, dynamic> diagnostico;
  final DetalhesDefensivosController controller;

  const DiagnosticItemWidget({
    super.key,
    required this.diagnostico,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = controller.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            (diagnostico['indicacoes'] as List?)?.length ?? 0,
            (index) => _buildIndicacaoItem(
                diagnostico['indicacoes'][index], isDark, context),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicacaoItem(
      Map<dynamic, dynamic> indicacao, bool isDark, BuildContext context) {
    final premiumService = Get.find<PremiumService>();
    
    return InkWell(
      onTap: () => DiagnosticApplicationDialog.show(
        context: context,
        data: indicacao,
        isPremium: premiumService.isPremium,
        actions: [
          DialogAction(
            label: 'Ver Praga',
            onPressed: () {
              Navigator.of(context).pop();
              controller.navigateToPests(indicacao);
            },
          ),
          DialogAction(
            label: 'Diagnóstico',
            isElevated: true,
            onPressed: () {
              Navigator.of(context).pop();
              controller.navigateToDiagnostic(indicacao);
            },
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPragaImage(indicacao['nomeCientifico']),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título: Nome da praga
                  Text(
                    indicacao['nomePraga'] ?? 'Nome da praga não disponível',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  // Subtítulo: Nome científico
                  Text(
                    indicacao['nomeCientifico'] ??
                        'Nome científico não disponível',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  // Terceira informação: Dosagem recomendada
                  _buildDosagemWithPremium(indicacao, isDark),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  /// Constrói a imagem da praga baseada no nome científico
  Widget _buildPragaImage(String? nomeCientifico) {
    if (nomeCientifico == null || nomeCientifico.isEmpty) {
      return const Icon(
        Icons.bug_report,
        size: 30,
        color: Colors.grey,
      );
    }

    final imagePath = 'assets/imagens/bigsize/$nomeCientifico.jpg';

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.bug_report,
          size: 30,
          color: Colors.grey,
        );
      },
    );
  }

  /// Constrói a dosagem com comportamento premium
  Widget _buildDosagemWithPremium(Map<dynamic, dynamic> indicacao, bool isDark) {
    final premiumService = Get.find<PremiumService>();
    final isPremium = premiumService.isPremium;
    final dosagem = _getDosagemRecomendada(indicacao);

    return Row(
      children: [
        Expanded(
          child: Text(
            isPremium ? dosagem : 'Dosagem: ••• mg/L',
            style: TextStyle(
              fontSize: 12,
              color: isPremium
                  ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                  : Colors.grey.shade400,
              fontWeight: isPremium ? FontWeight.w500 : FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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

  /// Extrai a dosagem recomendada dos dados da indicação
  String _getDosagemRecomendada(Map<dynamic, dynamic> indicacao) {
    // Verifica diferentes possíveis campos para dosagem
    final dosagem = indicacao['dosagem'] ??
        indicacao['dosagemRecomendada'] ??
        indicacao['dose'] ??
        indicacao['aplicacao'] ??
        indicacao['concentracao'];

    if (dosagem != null && dosagem.toString().isNotEmpty) {
      return 'Dosagem: ${dosagem.toString()}';
    }

    // Se não encontrar dosagem específica, procura por informações de aplicação
    final aplicacao = indicacao['formaAplicacao'] ??
        indicacao['modoAplicacao'] ??
        indicacao['tipoAplicacao'];

    if (aplicacao != null && aplicacao.toString().isNotEmpty) {
      return 'Aplicação: ${aplicacao.toString()}';
    }

    return 'Dosagem não especificada';
  }
}
