// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/in_app_purchase_service.dart';
import '../../../../../core/services/revenuecat_service.dart';
import '../../../../../core/services/subscription_config_service.dart';
import '../../../../../core/themes/manager.dart';

class TodoistPremiumPage extends StatefulWidget {
  const TodoistPremiumPage({super.key});

  @override
  State<TodoistPremiumPage> createState() => _TodoistPremiumPageState();
}

class _TodoistPremiumPageState extends State<TodoistPremiumPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _advantages = [];

  // Cores do tema Todoist
  final Color _primaryBlue = const Color(0xFF1976D2);
  final Color _accentBlue = const Color(0xFF42A5F5);
  final Color _lightBlue = const Color(0xFF90CAF9);
  final Color _deepBlue = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o todoist
      SubscriptionConfigService.initializeForApp('todoist');

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
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header com gradiente azul do Todoist
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryBlue, _deepBlue],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone animado do Todoist
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        SubscriptionConfigService.getCurrentAppName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Produtividade ilimitada para suas tarefas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                else ...[
                  _buildPremiumFeaturesCard(),
                  const SizedBox(height: 16),
                  _buildSubscriptionPlansCard(),
                  const SizedBox(height: 16),
                  _buildProductivityStatsCard(),
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

  Widget _buildPremiumFeaturesCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? const Color(0xFF1E1E1E) : Colors.white,
              isDark ? const Color(0xFF2A2A2A) : Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryBlue, _accentBlue],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Recursos Premium',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ..._advantages.map(
                (advantage) => _buildFeatureItem(
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

  Widget _buildFeatureItem(String iconName, String description, bool isDark) {
    IconData icon = _getIconFromImageName(iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? _primaryBlue.withValues(alpha: 0.1)
            : _lightBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryBlue, _accentBlue],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.4,
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
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentBlue, _lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Escolha seu Plano',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._products.map(
              (product) => _buildSubscriptionPlan(product, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlan(Map<String, dynamic> product, bool isDark) {
    final isRecommended = product['isRecommended'] == true;
    final isAnnual = product['productId'] == 'todoist_anual';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isRecommended
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryBlue.withValues(alpha: 0.15),
                  _accentBlue.withValues(alpha: 0.1),
                ],
              )
            : null,
        border: Border.all(
          color: isRecommended ? _primaryBlue : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _purchaseProduct(product),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone do plano
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecommended
                              ? [_primaryBlue, _deepBlue]
                              : [_accentBlue, _lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAnnual ? Icons.star : Icons.task_alt,
                        color: Colors.white,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_primaryBlue, _deepBlue],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    'RECOMENDADO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAnnual
                                ? 'Melhor custo-benefício • Economize 30%'
                                : 'Flexibilidade mensal • Cancele quando quiser',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Seta
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _primaryBlue,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                if (isAnnual) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.savings, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Economia de R\$ 59,80 por ano',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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

  Widget _buildProductivityStatsCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: _primaryBlue, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Estatísticas Exclusivas',
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
                  child: _buildStatItem(
                    'Tarefas\nConcluídas',
                    '500+',
                    Icons.check_circle,
                    Colors.green,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Produtividade\nMédia',
                    '85%',
                    Icons.trending_up,
                    Colors.orange,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Tempo\nEconomizado',
                    '2h/dia',
                    Icons.access_time,
                    _primaryBlue,
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _restorePurchases,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restore, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Restaurar Compras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
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
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      case 'sync.png':
        return Icons.sync;
      case 'themes.png':
        return Icons.palette;
      case 'backup.png':
        return Icons.backup;
      case 'lists.png':
        return Icons.list_alt;
      case 'notifications.png':
        return Icons.notifications_active;
      case 'sem_anuncio.png':
        return Icons.block;
      default:
        return Icons.task_alt;
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
            'Compra realizada com sucesso!\nBem-vindo ao TodoList Premium!');
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
    } catch (e) {}
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
