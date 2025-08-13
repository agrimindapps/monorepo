// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../models/subscription_model.dart';
import '../controller/premium_controller.dart';

class PremiumPage extends GetView<PremiumController> {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlantasColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildBenefitsSection(),
                  const SizedBox(height: 32),
                  _buildPlansSection(),
                  const SizedBox(height: 24),
                  _buildFooterSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: PlantasColors.textColor,
            ),
            onPressed: () => Get.back(),
            style: IconButton.styleFrom(
              backgroundColor: PlantasColors.cardColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Plantas Premium',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PlantasColors.textColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.restore,
              color: PlantasColors.textColor,
            ),
            onPressed: controller.restorePurchases,
            style: IconButton.styleFrom(
              backgroundColor: PlantasColors.cardColor,
            ),
            tooltip: 'Restaurar compras',
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolha seu plano',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: PlantasColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desbloqueie todos os recursos premium e transforme sua experiência com plantas',
            style: TextStyle(
              fontSize: 16,
              color: PlantasColors.subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildPlanCards(),
          const SizedBox(height: 32),
          _buildPurchaseButton(),
        ],
      ),
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: [
        _buildPlanCard(
          plan: SubscriptionPlan.yearly,
          title: 'Plano Anual',
          price: 'R\$ 79,99/ano',
          savings: 'Economize 33%',
          description: 'Melhor oferta - Apenas R\$ 6,67/mês',
          isPopular: true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          plan: SubscriptionPlan.monthly,
          title: 'Plano Mensal',
          price: 'R\$ 9,99/mês',
          description: 'Flexibilidade total para cancelar quando quiser',
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required String description,
    String? savings,
    bool isPopular = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == plan.name;

      return GestureDetector(
        onTap: () => controller.selectPlan(plan.name),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PlantasColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? PlantasColors.primaryColor
                  : PlantasColors.borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PlantasColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: PlantasColors.textColor,
                              ),
                            ),
                            if (isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: PlantasColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: PlantasColors.primaryColor,
                          ),
                        ),
                        if (savings != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            savings,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? PlantasColors.primaryColor
                            : PlantasColors.borderColor,
                        width: 2,
                      ),
                      color: isSelected
                          ? PlantasColors.primaryColor
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: PlantasColors.subtitleColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPurchaseButton() {
    return Obx(() {
      final isProcessing = controller.isProcessingPurchase.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isProcessing
              ? null
              : () => controller.purchasePlan(controller.selectedPlan.value),
          style: ElevatedButton.styleFrom(
            backgroundColor: PlantasColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Assinar Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantasColors.primaryColor,
            PlantasColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.star,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Plantas Premium',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Transforme sua experiência com plantas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.eco,
        'title': 'Plantas Ilimitadas',
        'description': 'Cadastre quantas plantas quiser'
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Inteligentes',
        'description': 'Notificações personalizadas para cada planta'
      },
      {
        'icon': Icons.analytics,
        'title': 'Relatórios Detalhados',
        'description': 'Acompanhe o progresso das suas plantas'
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Sincronização',
        'description': 'Seus dados seguros na nuvem'
      },
      {
        'icon': Icons.camera_alt,
        'title': 'Galeria Ilimitada',
        'description': 'Salve todas as fotos das suas plantas'
      },
      {
        'icon': Icons.support_agent,
        'title': 'Suporte Premium',
        'description': 'Atendimento prioritário'
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos Premium',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: PlantasColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) => _buildBenefitItem(
                icon: benefit['icon'] as IconData,
                title: benefit['title'] as String,
                description: benefit['description'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PlantasColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PlantasColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlantasColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: PlantasColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PlantasColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: PlantasColors.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PlantasColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '✓ Teste grátis por 7 dias',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PlantasColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancele a qualquer momento. Sem compromisso.',
            style: TextStyle(
              fontSize: 14,
              color: PlantasColors.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade',
            style: TextStyle(
              fontSize: 12,
              color: PlantasColors.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
