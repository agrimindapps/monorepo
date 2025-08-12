import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import '../providers/premium_provider.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  @override
  void initState() {
    super.initState();
    // Carrega produtos ao iniciar - o provider se inicializa automaticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status atual
                _buildCurrentStatusCard(provider),
                const SizedBox(height: 24),

                // Título e descrição
                _buildHeaderSection(),
                const SizedBox(height: 32),

                // Features premium
                _buildFeaturesSection(),
                const SizedBox(height: 32),

                // Planos disponíveis
                if (!provider.isPremium) ...[
                  _buildPlansSection(provider),
                  const SizedBox(height: 24),
                ],

                // Botões de ação
                _buildActionButtons(provider),
                const SizedBox(height: 32),

                // FAQ
                _buildFAQSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatusCard(PremiumProvider provider) {
    final isPremium = provider.isPremium;
    final status = provider.subscriptionStatus;
    final expirationDate = provider.expirationDate;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium 
              ? [Colors.teal.shade600, Colors.teal.shade400]
              : [Colors.grey.shade800, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.star : Icons.star_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $status',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expirationDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expira em: ${_formatDate(expirationDate)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desbloqueie Todo o Potencial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cuide melhor das suas plantas com recursos premium exclusivos',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Plantas Ilimitadas',
        'description': 'Adicione quantas plantas quiser ao seu jardim',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Avançados',
        'description': 'Configure lembretes personalizados para cada planta',
      },
      {
        'icon': Icons.analytics,
        'title': 'Análises Detalhadas',
        'description': 'Acompanhe o crescimento e saúde das suas plantas',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Backup na Nuvem',
        'description': 'Seus dados sempre seguros e sincronizados',
      },
      {
        'icon': Icons.photo_camera,
        'title': 'Identificação de Plantas',
        'description': 'Use a câmera para identificar espécies',
      },
      {
        'icon': Icons.medical_services,
        'title': 'Diagnóstico de Doenças',
        'description': 'Identifique e trate problemas rapidamente',
      },
      {
        'icon': Icons.palette,
        'title': 'Temas Personalizados',
        'description': 'Personalize a aparência do aplicativo',
      },
      {
        'icon': Icons.download,
        'title': 'Exportar Dados',
        'description': 'Exporte informações das suas plantas',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recursos Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.teal,
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(PremiumProvider provider) {
    final products = provider.availableProducts;
    
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha seu Plano',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...products.map((product) => _buildPlanCard(product, provider)),
      ],
    );
  }

  Widget _buildPlanCard(ProductInfo product, PremiumProvider provider) {
    final isMonthly = product.productId.contains('monthly');
    final isPopular = !isMonthly; // Anual é mais popular
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: isPopular 
            ? Border.all(color: Colors.teal, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'MAIS POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMonthly ? 'Mensal' : 'Anual',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isMonthly)
                          Text(
                            'Economize 20%',
                            style: TextStyle(
                              color: Colors.teal.shade400,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isMonthly ? '/mês' : '/ano',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading 
                        ? null 
                        : () => _purchaseProduct(product.productId, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? Colors.teal : Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Assinar ${isMonthly ? "Mensal" : "Anual"}',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons(PremiumProvider provider) {
    return Column(
      children: [
        if (!provider.isPremium)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: provider.isLoading ? null : () => _restorePurchases(provider),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        if (provider.isPremium)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _openManagementUrl(provider),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Gerenciar Assinatura',
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perguntas Frequentes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Posso cancelar a qualquer momento?',
          'Sim! Você pode cancelar sua assinatura a qualquer momento nas configurações da App Store ou Google Play.',
        ),
        _buildFAQItem(
          'O que acontece quando cancelo?',
          'Você continuará tendo acesso ao Premium até o fim do período pago. Após isso, voltará ao plano gratuito.',
        ),
        _buildFAQItem(
          'Posso trocar de plano?',
          'Sim, você pode mudar entre mensal e anual a qualquer momento. O valor será ajustado proporcionalmente.',
        ),
        _buildFAQItem(
          'Funciona em múltiplos dispositivos?',
          'Sim! Sua assinatura funciona em todos os dispositivos conectados à mesma conta.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseProduct(String productId, PremiumProvider provider) async {
    try {
      final success = await provider.purchaseProduct(productId);
      
      if (success && mounted) {
        _showSuccessDialog();
      } else if (provider.errorMessage != null && mounted) {
        _showErrorDialog(provider.errorMessage!);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message ?? 'Erro ao processar compra');
      }
    }
  }

  Future<void> _restorePurchases(PremiumProvider provider) async {
    final success = await provider.restorePurchases();
    
    if (mounted) {
      if (success) {
        if (provider.isPremium) {
          _showSuccessDialog(message: 'Compras restauradas com sucesso!');
        } else {
          _showInfoDialog('Nenhuma compra anterior encontrada.');
        }
      } else if (provider.errorMessage != null) {
        _showErrorDialog(provider.errorMessage!);
      }
    }
  }

  Future<void> _openManagementUrl(PremiumProvider provider) async {
    final url = await provider.getManagementUrl();
    if (url != null && mounted) {
      // TODO: Abrir URL usando url_launcher
      _showInfoDialog('URL de gerenciamento: $url');
    }
  }

  void _showSuccessDialog({String? message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.teal, size: 28),
            SizedBox(width: 12),
            Text('Sucesso!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message ?? 'Bem-vindo ao Premium! Aproveite todos os recursos exclusivos.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Erro', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Informação', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}