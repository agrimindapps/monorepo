// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/in_app_purchase_service.dart';
import '../../../../../core/services/revenuecat_service.dart';
import '../../../../../core/services/subscription_config_service.dart';
import '../../../../../core/themes/manager.dart';

class AgriHurbiPremiumPage extends StatefulWidget {
  const AgriHurbiPremiumPage({super.key});

  @override
  State<AgriHurbiPremiumPage> createState() => _AgriHurbiPremiumPageState();
}

class _AgriHurbiPremiumPageState extends State<AgriHurbiPremiumPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _advantages = [];

  // Cores do tema AgriHurbi
  final Color _primaryGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF388E3C);
  final Color _lightGreen = const Color(0xFF8BC34A);

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o agrihurbi
      SubscriptionConfigService.initializeForApp('agrihurbi');

      // Carregar produtos e vantagens da configuração centralizada
      _products = SubscriptionConfigService.getCurrentProducts();
      _advantages = SubscriptionConfigService.getCurrentAdvantages();

      setState(() {});
    } catch (e) {
      _showError('Erro ao carregar configuração: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header com gradiente verde
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_primaryGreen, _accentGreen],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${SubscriptionConfigService.getCurrentAppName()} Premium',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Funcionalidades avançadas para sua agricultura',
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

          // Conteúdo principal
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  )
                else ...[
                  _buildAdvantagesCard(),
                  const SizedBox(height: 16),
                  _buildSubscriptionPlansCard(),
                  const SizedBox(height: 16),
                  _buildRestoreButton(),
                  const SizedBox(height: 16),
                  _buildConfigInfo(),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantagesCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_border, color: _primaryGreen, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Vantagens do Premium',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._advantages.map(
              (advantage) => _buildAdvantageItem(
                advantage['img'] as String,
                advantage['desc'] as String,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(String iconName, String description, bool isDark) {
    // Mapear nomes de imagens para ícones específicos do AgriHurbi
    IconData icon = _getIconFromImageName(iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: _primaryGreen, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Planos Disponíveis',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._products.map(
              (product) => _buildSubscriptionPlan(product, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlan(Map<String, dynamic> product, bool isDark) {
    final isPopular = product['productId'] == 'agrihurbi_trimestral';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? _primaryGreen : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        gradient: isPopular
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryGreen.withValues(alpha: 0.1),
                  _lightGreen.withValues(alpha: 0.05),
                ],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _purchaseProduct(product),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone do plano
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPopular ? Icons.star : Icons.agriculture,
                    color: _primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Informações do plano
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product['desc'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${product['productId']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Seta
                Icon(
                  Icons.arrow_forward_ios,
                  color: _primaryGreen,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _restorePurchases,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restore, color: _primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Restaurar Compras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigInfo() {
    final isDark = ThemeManager().isDark.value;
    final hasValidKeys = SubscriptionConfigService.hasValidApiKeys();
    final errors = SubscriptionConfigService.getCurrentConfigErrors();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasValidKeys ? Icons.check_circle : Icons.warning,
                  color: hasValidKeys ? _primaryGreen : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status da Configuração',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasValidKeys
                  ? 'Configuração válida - RevenueCat pronto para uso'
                  : 'API keys não configuradas - Funcionalidade limitada',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...errors.map((error) => Text(
                    '• $error',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconFromImageName(String imageName) {
    switch (imageName) {
      case 'manutencao_billing.png':
        return Icons.build_circle;
      case 'newfeatures.png':
        return Icons.new_releases;
      case 'sem_anuncio.png':
        return Icons.block;
      case 'premium_billing.png':
        return Icons.workspace_premium;
      default:
        return Icons.agriculture;
    }
  }

  Future<void> _purchaseProduct(Map<String, dynamic> product) async {
    if (!SubscriptionConfigService.hasValidApiKeys()) {
      _showError(
          'API keys do RevenueCat não configuradas. Configure as chaves no arquivo subscription_constants.dart');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buscar offerings do RevenueCat
      final revenueCatService = RevenuecatService.instance;
      final offering = await revenueCatService.getOfferings();

      if (offering == null || offering.availablePackages.isEmpty) {
        _showError('Nenhum produto disponível. Verifique sua conexão.');
        return;
      }

      // Encontrar o pacote correspondente ao productId
      final package = offering.availablePackages.firstWhere(
        (pkg) => pkg.storeProduct.identifier == product['productId'],
        orElse: () => offering.availablePackages.first,
      );

      // Realizar a compra
      final success = await revenueCatService.purchasePackage(package);

      if (success) {
        _showSuccess(
            'Compra realizada com sucesso!\nProduto: ${product['desc']}');
        // Atualizar status de assinatura
        await _updateSubscriptionStatus();
      } else {
        _showError('Falha na compra. Tente novamente.');
      }
    } catch (e) {
      _showError('Erro na compra: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final revenueCatService = RevenuecatService.instance;
      final success = await revenueCatService.restorePurchases();

      if (success) {
        _showSuccess('Compras restauradas com sucesso!');
        await _updateSubscriptionStatus();
      } else {
        _showError('Nenhuma compra encontrada para restaurar.');
      }
    } catch (e) {
      _showError('Erro ao restaurar compras: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSubscriptionStatus() async {
    try {
      await InAppPurchaseService().inAppLoadDataSignature();
    } catch (e) {
      debugPrint('Erro ao atualizar status de assinatura: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
