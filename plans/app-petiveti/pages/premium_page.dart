// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/in_app_purchase_service.dart';
import '../../../../../core/services/revenuecat_service.dart';
import '../../../../../core/services/subscription_config_service.dart';
import '../../../../../core/themes/manager.dart';

class PetiVetiPremiumPage extends StatefulWidget {
  const PetiVetiPremiumPage({super.key});

  @override
  State<PetiVetiPremiumPage> createState() => _PetiVetiPremiumPageState();
}

class _PetiVetiPremiumPageState extends State<PetiVetiPremiumPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _advantages = [];

  // Cores do tema PetiVeti (Veterinária)
  final Color _primaryTeal = const Color(0xFF00ACC1);
  final Color _accentTeal = const Color(0xFF26C6DA);
  final Color _lightTeal = const Color(0xFF80DEEA);
  final Color _deepTeal = const Color(0xFF00838F);
  final Color _veterinaryGreen = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o petiveti
      SubscriptionConfigService.initializeForApp('petiveti');
      
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
      backgroundColor: isDark ? const Color(0xFF0A1929) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header veterinário com gradiente teal
          SliverAppBar(
            expandedHeight: 240.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryTeal, _deepTeal],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone veterinário com animação
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Text(
                        SubscriptionConfigService.getCurrentAppName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cuidado veterinário premium para seu pet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(color: _primaryTeal),
                  )
                else ...[
                  _buildVeterinaryBenefitsCard(),
                  const SizedBox(height: 20),
                  _buildSubscriptionPlansCard(),
                  const SizedBox(height: 20),
                  _buildHealthStatsCard(),
                  const SizedBox(height: 20),
                  _buildEmergencyContactCard(),
                  const SizedBox(height: 20),
                  _buildRestoreButton(),
                  const SizedBox(height: 16),
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

  Widget _buildVeterinaryBenefitsCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? const Color(0xFF1A2332) : Colors.white,
              isDark ? const Color(0xFF243447) : Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryTeal, _accentTeal],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.medical_services,
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
                          'Serviços Veterinários',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ..._advantages.map((advantage) => 
                _buildVeterinaryBenefit(
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

  Widget _buildVeterinaryBenefit(String iconName, String description, bool isDark) {
    IconData icon = _getVeterinaryIconFromName(iconName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? _primaryTeal.withValues(alpha: 0.08) 
            : _lightTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _primaryTeal.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryTeal, _accentTeal],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryTeal.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
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
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentTeal, _lightTeal],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.card_membership,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Planos de Assinatura',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ..._products.map((product) => 
              _buildVeterinaryPlan(product, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinaryPlan(Map<String, dynamic> product, bool isDark) {
    final isRecommended = product['isRecommended'] == true;
    final isAnnual = product['productId'] == 'petiveti_anual';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isRecommended 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryTeal.withValues(alpha: 0.15),
                _accentTeal.withValues(alpha: 0.1),
              ],
            )
          : null,
        border: Border.all(
          color: isRecommended ? _primaryTeal : Colors.grey[300]!,
          width: isRecommended ? 2.5 : 1,
        ),
        boxShadow: isRecommended ? [
          BoxShadow(
            color: _primaryTeal.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _purchaseProduct(product),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone do plano
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecommended 
                            ? [_primaryTeal, _deepTeal]
                            : [_accentTeal, _lightTeal],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isAnnual ? Icons.star : Icons.pets,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_veterinaryGreen, _primaryTeal],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'RECOMENDADO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAnnual 
                              ? 'Cuidado veterinário completo • Melhor valor'
                              : 'Acesso mensal • Cancele quando quiser',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Seta com ícone veterinário
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _primaryTeal,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                
                if (isAnnual) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _veterinaryGreen.withValues(alpha: 0.1),
                          _primaryTeal.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _veterinaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital, color: _veterinaryGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Economia de R\$ 119,80 por ano',
                                style: TextStyle(
                                  color: _veterinaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '+ Consultas de emergência incluídas',
                                style: TextStyle(
                                  color: _veterinaryGreen,
                                  fontSize: 14,
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

  Widget _buildHealthStatsCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: _veterinaryGreen, size: 28),
                const SizedBox(width: 16),
                const Text(
                  'Saúde do seu Pet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildHealthStatItem(
                    'Consultas\nRealizadas',
                    '12+',
                    Icons.medical_services,
                    _primaryTeal,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthStatItem(
                    'Vacinas\nEm dia',
                    '100%',
                    Icons.vaccines,
                    _veterinaryGreen,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthStatItem(
                    'Tempo\nResposta',
                    '<1h',
                    Icons.access_time,
                    Colors.orange,
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

  Widget _buildHealthStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.1),
              Colors.orange.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergência 24h',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Suporte veterinário disponível 24/7 para situações críticas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.phone,
                color: Colors.red,
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _restorePurchases,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restore, color: _primaryTeal, size: 22),
              const SizedBox(width: 12),
              Text(
                'Restaurar Compras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryTeal,
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
      color: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasValidKeys ? Icons.check_circle : Icons.warning,
                  color: hasValidKeys ? _veterinaryGreen : Colors.orange,
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

  IconData _getVeterinaryIconFromName(String imageName) {
    switch (imageName) {
      case 'veterinary.png':
        return Icons.medical_services;
      case 'health_records.png':
        return Icons.folder_shared;
      case 'vaccination.png':
        return Icons.vaccines;
      case 'emergency.png':
        return Icons.emergency;
      case 'nutrition.png':
        return Icons.restaurant;
      case 'sem_anuncio.png':
        return Icons.block;
      default:
        return Icons.pets;
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
        _showSuccess('Assinatura ativada com sucesso!\nBem-vindo ao PetiVeti Premium!');
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
        backgroundColor: _veterinaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
