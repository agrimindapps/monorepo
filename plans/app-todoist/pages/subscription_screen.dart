// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../core/services/in_app_purchase_service.dart';
import '../../core/services/revenuecat_service.dart';
import '../../core/services/subscription_config_service.dart';
import '../../intermediate.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
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
      // Inicializar configuração para o todoist
      SubscriptionConfigService.initializeForApp('todoist');
    } catch (e) {}
  }

  Future<void> _initializeServices() async {
    try {
      final environment = Get.find<GlobalEnvironment>();
      _revenuecatService = RevenuecatService(
        store: Store.appStore,
        apiKey: environment.iAppleApiKey,
      );

      await _revenuecatService!.configureSDK();
      await _loadOfferings();
      await _purchaseService.inAppLoadDataSignature();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final offering = await _revenuecatService?.getOfferings();
      setState(() {
        _currentOffering = offering;
      });
    } catch (e) {}
  }

  Future<void> _purchasePackage(Package package) async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _revenuecatService?.purchasePackage(package);

      if (success == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assinatura realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _purchaseService.init();
        await _purchaseService.inAppLoadDataSignature();

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

        await _purchaseService.init();
        await _purchaseService.inAppLoadDataSignature();

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
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.8),
                      theme.primaryColor.withValues(alpha: 0.6),
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
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TodoList Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Maximize sua produtividade com recursos premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
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
                  Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
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
    final benefits = _purchaseService.getVantagens();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursos Premium',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (benefits.isNotEmpty) ...[
              ...benefits.map((benefit) => _buildBenefitItem(
                    benefit['titulo'] ?? '',
                    benefit['descricao'] ?? '',
                    benefit['icone'] ?? 'star',
                  )),
            ] else ...[
              _buildBenefitItem(
                'Sincronização Ilimitada',
                'Sincronize suas tarefas em todos os dispositivos sem limites',
                'sync',
              ),
              _buildBenefitItem(
                'Temas Personalizados',
                'Acesso completo a todos os temas e personalizações',
                'palette',
              ),
              _buildBenefitItem(
                'Backup Automático',
                'Backup seguro e automático de todas as suas tarefas',
                'backup',
              ),
              _buildBenefitItem(
                'Listas Ilimitadas',
                'Crie quantas listas de tarefas precisar',
                'list',
              ),
              _buildBenefitItem(
                'Notificações Avançadas',
                'Lembretes inteligentes e personalizáveis',
                'notifications',
              ),
              _buildBenefitItem(
                'Sem Anúncios',
                'Experiência premium sem interrupções',
                'block',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, String iconName) {
    final theme = Theme.of(context);

    IconData icon;
    switch (iconName) {
      case 'sync':
        icon = Icons.sync;
        break;
      case 'palette':
        icon = Icons.palette;
        break;
      case 'backup':
        icon = Icons.backup;
        break;
      case 'list':
        icon = Icons.list;
        break;
      case 'notifications':
        icon = Icons.notifications;
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
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
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
                color: theme.primaryColor,
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
    final theme = Theme.of(context);
    final isRecommended = package.packageType == PackageType.monthly;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? theme.primaryColor : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        color: isRecommended
            ? theme.primaryColor.withValues(alpha: 0.05)
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
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
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
                      backgroundColor: theme.primaryColor,
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
                            'Assinar Premium',
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
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restore,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Já é Premium?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Se você já possui uma assinatura ativa, restaure suas compras para continuar aproveitando todos os recursos premium.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _restorePurchases,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Restaurar Compras'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
    final theme = Theme.of(context);
    final termsData = _purchaseService.getTermosUso();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gavel,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Termos e Condições',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
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
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (termsData.isNotEmpty && termsData['texto'] != null)
              Text(
                termsData['texto'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              )
            else
              const Text(
                'A assinatura será renovada automaticamente ao final de cada período. Cancele a qualquer momento nas configurações da sua conta. O TodoList Premium oferece recursos avançados para otimizar sua produtividade.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
