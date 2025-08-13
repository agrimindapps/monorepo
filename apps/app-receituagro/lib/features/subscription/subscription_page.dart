import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../core/di/injection_container.dart' as di;

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final ISubscriptionRepository _subscriptionRepository = di.sl<ISubscriptionRepository>();
  
  bool _isLoading = false;
  bool _hasActiveSubscription = false;
  List<ProductInfo> _availableProducts = [];
  SubscriptionEntity? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() => _isLoading = true);

    try {
      // Verificar se tem assinatura ativa
      final hasActiveResult = await _subscriptionRepository.hasActiveSubscription();
      hasActiveResult.fold(
        (failure) => _showError('Erro ao verificar assinatura: ${failure.message}'),
        (hasActive) => _hasActiveSubscription = hasActive,
      );

      // Carregar produtos disponíveis
      final productsResult = await _subscriptionRepository.getAvailableProducts(
        productIds: [
          EnvironmentConfig.receitaAgroMonthlyProduct,
          EnvironmentConfig.receitaAgroYearlyProduct,
        ],
      );
      
      productsResult.fold(
        (failure) => _showError('Erro ao carregar produtos: ${failure.message}'),
        (products) => _availableProducts = products,
      );

      // Se tem assinatura ativa, carregar detalhes
      if (_hasActiveSubscription) {
        final subscriptionResult = await _subscriptionRepository.getCurrentSubscription();
        subscriptionResult.fold(
          (failure) => _showError('Erro ao carregar assinatura: ${failure.message}'),
          (subscription) => _currentSubscription = subscription,
        );
      }
    } catch (e) {
      _showError('Erro inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseProduct(String productId) async {
    setState(() => _isLoading = true);

    try {
      final result = await _subscriptionRepository.purchaseProduct(productId: productId);
      
      result.fold(
        (failure) => _showError('Erro na compra: ${failure.message}'),
        (subscription) {
          _showSuccess('Assinatura ativada com sucesso!');
          _loadSubscriptionData(); // Recarregar dados
        },
      );
    } catch (e) {
      _showError('Erro inesperado na compra: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final result = await _subscriptionRepository.restorePurchases();
      
      result.fold(
        (failure) => _showError('Erro ao restaurar compras: ${failure.message}'),
        (subscriptions) {
          if (subscriptions.isNotEmpty) {
            _showSuccess('Compras restauradas com sucesso!');
            _loadSubscriptionData();
          } else {
            _showInfo('Nenhuma compra anterior encontrada');
          }
        },
      );
    } catch (e) {
      _showError('Erro inesperado ao restaurar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        title: const Text('Planos Premium'),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _hasActiveSubscription
              ? _buildActiveSubscriptionView()
              : _buildSubscriptionPlansView(),
    );
  }

  Widget _buildActiveSubscriptionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🎉 Você é Premium!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aproveite todos os recursos do Pragas Soja',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                  if (_currentSubscription != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Plano: ${_currentSubscription!.productId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_currentSubscription!.expirationDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Renovação: ${_formatDate(_currentSubscription!.expirationDate!)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features List
          _buildFeaturesList(),
          
          const SizedBox(height: 24),
          
          // Management Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await _subscriptionRepository.getManagementUrl();
                result.fold(
                  (failure) => _showError('Erro ao abrir gerenciamento'),
                  (url) {
                    if (url != null) {
                      _showInfo('Redirecionando para gerenciamento...');
                    } else {
                      _showInfo('Gerenciar assinatura na loja de aplicativos');
                    }
                  },
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Gerenciar Assinatura'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '🚀 Desbloqueie o poder completo do Pragas Soja',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Acesse todos os recursos premium e maximize sua produtividade',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features List
          _buildFeaturesList(),
          
          const SizedBox(height: 24),
          
          // Plans
          if (_availableProducts.isNotEmpty) ...[
            const Text(
              'Escolha seu plano:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ..._availableProducts.map((product) => _buildProductCard(product)),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Carregando planos disponíveis...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Restore Purchases Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _restorePurchases,
              child: const Text('Restaurar Compras Anteriores'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    const features = [
      'Acesso completo ao banco de dados de pragas',
      'Receitas de defensivos detalhadas',
      'Diagnóstico avançado de pragas',
      'Suporte prioritário',
      'Atualizações exclusivas',
      'Modo offline completo',
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos Premium:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductInfo product) {
    final isYearly = product.productId.contains('yearly');
    final monthlyPrice = isYearly ? (product.price / 12) : product.price;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isYearly 
              ? Border.all(color: Colors.orange.shade400, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isYearly ? 'Anual' : 'Mensal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isYearly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'MAIS POPULAR',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.priceString,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    isYearly ? '/ano' : '/mês',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              if (isYearly) ...[
                const SizedBox(height: 4),
                Text(
                  'Equivale a ${monthlyPrice.toStringAsFixed(2)}/mês',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchaseProduct(product.productId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isYearly 
                        ? Colors.orange.shade600 
                        : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Assinar ${isYearly ? 'Anual' : 'Mensal'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}