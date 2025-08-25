// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../controller/premium_controller.dart';

class PremiumFooterWidget extends GetView<PremiumController> {
  const PremiumFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);

    return Column(
      children: [
        // Botão restaurar compras
        Obx(() => TextButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.restorePurchases,
              icon: Icon(
                Icons.restore,
                size: 20,
                color: plantasCores['primaria'],
              ),
              label: Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: plantasCores['primaria'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),

        const SizedBox(height: 16),

        // Link para termos e política
        GestureDetector(
          onTap: controller.openTermsAndPrivacy,
          child: Text(
            'Termos de Uso e Política de Privacidade',
            style: TextStyle(
              color: plantasCores['textoSecundario'],
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Informações sobre renovação automática
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: plantasCores['textoSecundario'],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informações da Assinatura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: plantasCores['texto'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                'Renovação automática 24h antes do vencimento',
                context,
              ),
              _buildInfoItem(
                'Cancele a qualquer momento nas configurações da conta',
                context,
              ),
              _buildInfoItem(
                'Gerencie sua assinatura através da loja de aplicativos',
                context,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Informações de contato/suporte
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 16,
              color: plantasCores['textoSecundario'],
            ),
            const SizedBox(width: 6),
            Text(
              'Precisa de ajuda? Entre em contato conosco',
              style: TextStyle(
                fontSize: 12,
                color: plantasCores['textoSecundario'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text, BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: plantasCores['primaria'],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: plantasCores['textoSecundario'],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
