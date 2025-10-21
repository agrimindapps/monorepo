// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/in_app_purchase_service.dart';
import '../../../../../core/services/revenuecat_service.dart';
import '../../../../../core/services/subscription_config_service.dart';
import '../../../../../core/themes/manager.dart';

class NutriTutiPremiumPage extends StatefulWidget {
  const NutriTutiPremiumPage({super.key});

  @override
  State<NutriTutiPremiumPage> createState() => _NutriTutiPremiumPageState();
}

class _NutriTutiPremiumPageState extends State<NutriTutiPremiumPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _advantages = [];

  // Cores do tema NutriTuti (Nutrição)
  final Color _primaryGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF66BB6A);
  final Color _lightGreen = const Color(0xFF81C784);
  final Color _darkGreen = const Color(0xFF2E7D32);
  final Color _nutritionOrange = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o nutrituti
      SubscriptionConfigService.initializeForApp('nutrituti');
      
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
      backgroundColor: isDark ? const Color(0xFF1B5E20) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header nutricional com gradiente verde
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryGreen, _darkGreen],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone nutricional com animação
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        SubscriptionConfigService.getCurrentAppName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nutrição inteligente e personalizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
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
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  )
                else ...[
                  _buildNutritionalBenefitsCard(),
                  const SizedBox(height: 24),
                  _buildSubscriptionPlansCard(),
                  const SizedBox(height: 24),
                  _buildNutritionStatsCard(),
                  const SizedBox(height: 24),
                  _buildDietaryGuideCard(),
                  const SizedBox(height: 24),
                  _buildRestoreButton(),
                  const SizedBox(height: 20),
                  _buildConfigInfo(),
                  const SizedBox(height: 40),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalBenefitsCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? const Color(0xFF2E7D32) : Colors.white,
              isDark ? const Color(0xFF388E3C) : Colors.green[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryGreen, _accentGreen],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_dining,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrição Premium',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sua saúde em primeiro lugar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ..._advantages.map((advantage) => 
                _buildNutritionalBenefit(
                  advantage['img'] as String,
                  advantage['desc'] as String,
                  isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalBenefit(String iconName, String description, bool isDark) {
    IconData icon = _getNutritionalIconFromName(iconName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark 
            ? _primaryGreen.withValues(alpha: 0.1) 
            : _lightGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreen, _accentGreen],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 17,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.6,
                fontWeight: FontWeight.w500,
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
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentGreen, _lightGreen],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  'Planos Nutricionais',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ..._products.map((product) => 
              _buildNutritionalPlan(product, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalPlan(Map<String, dynamic> product, bool isDark) {
    final isRecommended = product['productId'] == 'nutrituti_trimestral';
    final isTrimestral = product['productId'] == 'nutrituti_trimestral';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isRecommended 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryGreen.withValues(alpha: 0.2),
                _accentGreen.withValues(alpha: 0.15),
              ],
            )
          : null,
        border: Border.all(
          color: isRecommended ? _primaryGreen : Colors.grey[300]!,
          width: isRecommended ? 3 : 1.5,
        ),
        boxShadow: isRecommended ? [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _purchaseProduct(product),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone do plano
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecommended 
                            ? [_primaryGreen, _darkGreen]
                            : [_accentGreen, _lightGreen],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isTrimestral ? Icons.star : Icons.restaurant_menu,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 24),
                    
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_nutritionOrange, _primaryGreen],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Text(
                                    'RECOMENDADO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isTrimestral 
                              ? 'Acompanhamento completo • Melhor custo-benefício'
                              : 'Flexibilidade mensal • Ideal para testes',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Seta nutricional
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _primaryGreen,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                
                if (isTrimestral) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _nutritionOrange.withValues(alpha: 0.15),
                          _primaryGreen.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _nutritionOrange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.savings, color: _nutritionOrange, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Economia de R\$ 78,60 por trimestre',
                                style: TextStyle(
                                  color: _nutritionOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                '+ Plano alimentar personalizado incluso',
                                style: TextStyle(
                                  color: _nutritionOrange,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionStatsCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: _nutritionOrange, size: 32),
                const SizedBox(width: 20),
                const Text(
                  'Suas Métricas Nutricionais',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildNutritionStatItem(
                    'Calorias\nConsumidas',
                    '1,847',
                    Icons.local_fire_department,
                    Colors.red,
                    isDark,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildNutritionStatItem(
                    'Proteínas\n(g)',
                    '127g',
                    Icons.fitness_center,
                    _primaryGreen,
                    isDark,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildNutritionStatItem(
                    'Hidratação\n(L)',
                    '2.1L',
                    Icons.water_drop,
                    Colors.blue,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryGuideCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              _nutritionOrange.withValues(alpha: 0.1),
              _primaryGreen.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_nutritionOrange, _primaryGreen],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guia Nutricional',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Acesso completo ao guia nutricional personalizado e receitas exclusivas',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _nutritionOrange,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _restorePurchases,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restore, color: _primaryGreen, size: 24),
              const SizedBox(width: 16),
              Text(
                'Restaurar Compras',
                style: TextStyle(
                  fontSize: 18,
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2E7D32) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasValidKeys ? Icons.check_circle : Icons.warning,
                  color: hasValidKeys ? _primaryGreen : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Status da Configuração',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasValidKeys 
                  ? 'Configuração válida - RevenueCat pronto para uso'
                  : 'API keys não configuradas - Funcionalidade limitada',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...errors.map((error) => Text(
                '• $error',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getNutritionalIconFromName(String imageName) {
    switch (imageName) {
      case 'manutencao_billing.png':
        return Icons.build_circle;
      case 'newfeatures.png':
        return Icons.new_releases;
      case 'sem_anuncio.png':
        return Icons.block;
      case 'premium_billing.png':
        return Icons.restaurant_menu;
      default:
        return Icons.local_dining;
    }
  }

  Future<void> _purchaseProduct(Map<String, dynamic> product) async {
    if (!SubscriptionConfigService.hasValidApiKeys()) {
      _showError('API keys do RevenueCat não configuradas. Configure as chaves no arquivo subscription_constants.dart');
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
        _showSuccess('Assinatura ativada com sucesso!\nBem-vindo ao NutriTuti Premium!');
        // Atualizar status de assinatura
        await _updateSubscriptionStatus();
      } else {
        _showError('Falha na ativação. Tente novamente.');
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
        _showSuccess('Assinatura restaurada com sucesso!');
        await _updateSubscriptionStatus();
      } else {
        _showError('Nenhuma assinatura encontrada para restaurar.');
      }
    } catch (e) {
      _showError('Erro ao restaurar assinatura: $e');
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
