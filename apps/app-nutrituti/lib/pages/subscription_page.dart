// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../core/services/in_app_purchase_service.dart';
import '../../core/services/revenuecat_service.dart';
import '../../core/services/subscription_config_service.dart';
import '../widgets/app_colors.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService.instance;
  RevenuecatService? _revenuecatService;
  bool _isLoading = true;
  bool _isPurchasing = false;
  Offering? _currentOffering;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
    _initializeServices();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o nutrituti
      SubscriptionConfigService.instance.initializeForApp('nutrituti');
    } catch (e) {
      debugPrint('Erro ao inicializar configuração: $e');
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Use RevenuecatService singleton instance
      _revenuecatService = RevenuecatService.instance;

      await _revenuecatService!.configureSDK();
      await _loadOfferings();
      await _purchaseService.inAppLoadDataSignature();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final offering = await _revenuecatService?.getOfferings() as Offering?;
      setState(() {
        _currentOffering = offering;
      });
    } catch (e) {
      debugPrint('Error loading offerings: $e');
    }
  }

  Future<void> _purchasePackage(Package package) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _revenuecatService?.purchasePackage(package.identifier);

      if (success == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assinatura realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Atualizar status premium
        await _purchaseService.init();
        await _purchaseService.inAppLoadDataSignature();

        // Voltar para a página anterior
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Falha ao processar a compra. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro durante a compra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final success = await _revenuecatService?.restorePurchases();

      if (success == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compras restauradas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Atualizar status premium
        await _purchaseService.init();
        await _purchaseService.inAppLoadDataSignature();

        // Voltar para a página anterior
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma compra encontrada para restaurar.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao restaurar compras: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6B73FF),
                      Color(0xFF9B59B6),
                      Color(0xFFE74C3C),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'NutriTuti Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Desbloqueie todo o potencial do app',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading) ...[
                  const SizedBox(height: 100),
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.contentColorCyan),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Carregando ofertas...'),
                  ),
                ] else ...[
                  _buildBenefitsSection(),
                  const SizedBox(height: 24),
                  _buildPricingSection(),
                  const SizedBox(height: 24),
                  _buildRestoreSection(),
                  const SizedBox(height: 24),
                  _buildTermsSection(),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefícios Premium',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.contentColorCyan,
              ),
            ),
            const SizedBox(height: 16),
            // Using FutureBuilder for async benefits
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _purchaseService.getVantagens(),
              builder: (context, snapshot) {
                final benefits = snapshot.data ?? [];
                if (benefits.isNotEmpty) {
                  return Column(
                    children: benefits.map((benefit) => _buildBenefitItem(
                      benefit['titulo'] as String? ?? '',
                      benefit['descricao'] as String? ?? '',
                      benefit['icone'] as String? ?? 'star',
                    )).toList(),
                  );
                }

                // Default benefits
                return Column(
                  children: [
                    _buildBenefitItem(
                      'Planos Alimentares Personalizados',
                      'Receba planos de refeições customizados para seus objetivos',
                      'restaurant_menu',
                    ),
                    _buildBenefitItem(
                      'Análises Nutricionais Detalhadas',
                      'Acompanhe macros e micros com precisão profissional',
                      'analytics',
                    ),
                    _buildBenefitItem(
                      'Receitas Exclusivas',
                      'Acesso a mais de 1000 receitas saudáveis e saborosas',
                      'book',
                    ),
                    _buildBenefitItem(
                      'Sincronização Ilimitada',
                      'Seus dados sempre seguros e sincronizados',
                      'sync',
                    ),
                    _buildBenefitItem(
                      'Sem Anúncios',
                      'Experiência premium sem interrupções',
                      'block',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, String iconName) {
    IconData icon;
    switch (iconName) {
      case 'restaurant_menu':
        icon = Icons.restaurant_menu;
        break;
      case 'analytics':
        icon = Icons.analytics;
        break;
      case 'book':
        icon = Icons.book;
        break;
      case 'sync':
        icon = Icons.sync;
        break;
      case 'block':
        icon = Icons.block;
        break;
      default:
        icon = Icons.star;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.contentColorCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.contentColorCyan,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha seu Plano',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.contentColorCyan,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentOffering?.availablePackages.isNotEmpty == true) ...[
              ..._currentOffering!.availablePackages
                  .map((package) => _buildPackageCard(package)),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Nenhuma oferta disponível no momento.\nTente novamente mais tarde.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isRecommended = package.packageType == PackageType.monthly;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? AppColors.contentColorCyan : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        color: isRecommended
            ? AppColors.contentColorCyan.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Stack(
        children: [
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.contentColorCyan,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Recomendado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package.storeProduct.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      package.storeProduct.priceString,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.contentColorCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  package.storeProduct.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isPurchasing ? null : () => _purchasePackage(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contentColorCyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isPurchasing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Assinar Agora',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Já é Premium?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se você já possui uma assinatura ativa, restaure suas compras para continuar aproveitando os benefícios premium.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restorePurchases,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.contentColorCyan,
                  side: const BorderSide(color: AppColors.contentColorCyan),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Restaurar Compras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Termos e Condições',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _purchaseService.launchTermoUso(),
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Termos de Uso'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.contentColorCyan,
                      side: const BorderSide(color: AppColors.contentColorCyan),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _purchaseService.launchPoliticaPrivacidade(),
                    icon: const Icon(Icons.privacy_tip, size: 18),
                    label: const Text('Privacidade'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.contentColorCyan,
                      side: const BorderSide(color: AppColors.contentColorCyan),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _purchaseService.getTermosUso(),
              builder: (context, snapshot) {
                final termsText = snapshot.data ?? '';
                if (termsText.isNotEmpty) {
                  return Text(
                    termsText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return const Text(
                  'A assinatura será renovada automaticamente ao final de cada período. Cancele a qualquer momento nas configurações da sua conta. Os pagamentos serão processados através da loja de aplicativos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
