// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/in_app_purchase_service.dart';
import '../../../../../core/services/revenuecat_service.dart';
import '../../../../../core/services/subscription_config_service.dart';
import '../../../../../core/themes/manager.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _advantages = [];

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o gasometer
      SubscriptionConfigService.initializeForApp('gasometer');

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
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Text('${SubscriptionConfigService.getCurrentAppName()} Premium'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 40),
                  _buildAdvantages(isDark),
                  const SizedBox(height: 40),
                  _buildSubscriptionPlans(isDark),
                  const SizedBox(height: 24),
                  _buildRestoreButton(isDark),
                  const SizedBox(height: 16),
                  _buildConfigInfo(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Ícone Premium
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade400,
                Colors.amber.shade600,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 60,
          ),
        ),
        const SizedBox(height: 32),

        // Título
        Text(
          '${SubscriptionConfigService.getCurrentAppName()} Premium',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Descrição
        Text(
          'Desbloqueie recursos avançados e tenha a melhor experiência com o ${SubscriptionConfigService.getCurrentAppName()}',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdvantages(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vantagens Premium',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
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
    );
  }

  Widget _buildAdvantageItem(String iconName, String description, bool isDark) {
    // Mapear nomes de imagens para ícones
    IconData icon = _getIconFromImageName(iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade400.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.amber.shade600,
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

  Widget _buildSubscriptionPlans(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planos Disponíveis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._products.map(
          (product) => _buildSubscriptionPlan(product, isDark),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlan(Map<String, dynamic> product, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => _purchaseProduct(product),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['desc'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: ${product['productId']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _restorePurchases,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.amber.shade600,
          side: BorderSide(color: Colors.amber.shade600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.restore, size: 20),
        label: const Text(
          'Restaurar Compras',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildConfigInfo(bool isDark) {
    final hasValidKeys = SubscriptionConfigService.hasValidApiKeys();
    final errors = SubscriptionConfigService.getCurrentConfigErrors();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasValidKeys ? Icons.check_circle : Icons.warning,
                color: hasValidKeys ? Colors.green : Colors.orange,
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
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...errors.map((error) => Text(
                  '• $error',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  IconData _getIconFromImageName(String imageName) {
    switch (imageName) {
      case 'manutencao_billing.png':
        return Icons.build;
      case 'newfeatures.png':
        return Icons.new_releases;
      case 'sem_anuncio.png':
        return Icons.block;
      case 'premium_billing.png':
        return Icons.star;
      default:
        return Icons.info;
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
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
