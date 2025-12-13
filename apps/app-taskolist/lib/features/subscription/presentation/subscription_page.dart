import 'package:core/core.dart' hide SubscriptionPage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../data/revenue_cat_service.dart';
import '../presentation/subscription_providers.dart' as local_providers;

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(local_providers.offeringsProvider);
    final isPremium = ref.watch(local_providers.isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskolist Premium'),
        actions: [
          if (!isPremium)
            TextButton(
              onPressed: _restorePurchases,
              child: const Text('Restaurar'),
            ),
        ],
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          if (offerings == null || offerings.current == null) {
            return const Center(
              child: Text('Nenhuma oferta disponível no momento'),
            );
          }

          final packages = offerings.current!.availablePackages;

          if (isPremium) {
            return _buildPremiumContent();
          }

          return _buildOfferingsList(packages);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar ofertas: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(local_providers.offeringsProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
          const SizedBox(height: 24),
          const Text(
            'Você já é Premium! 🎉',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aproveite todos os recursos ilimitados do Taskolist!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingsList(List<Package> packages) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.rocket_launch, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Desbloqueie todo o potencial',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Recursos Premium:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem('✓ Tarefas ilimitadas'),
        _buildFeatureItem('✓ Sincronização em tempo real'),
        _buildFeatureItem('✓ Backup automático na nuvem'),
        _buildFeatureItem('✓ Notificações avançadas'),
        _buildFeatureItem('✓ Suporte prioritário'),
        _buildFeatureItem('✓ Sem anúncios'),
        const SizedBox(height: 32),
        ...packages.map((package) => _buildPackageCard(package)),
        const SizedBox(height: 16),
        const Text(
          'Cancele quando quiser. Sua assinatura será renovada automaticamente.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isPopular = package.packageType == PackageType.monthly;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? Colors.blue : Colors.grey,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  'POPULAR',
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
                Text(
                  package.storeProduct.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  package.storeProduct.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package.storeProduct.priceString,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _purchasePackage(package),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Assinar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.purchasePackage(package);

      if (!mounted) return;

      if (customerInfo != null && service.isPremium(customerInfo)) {
        ref.invalidate(local_providers.customerInfoProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Assinatura realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.restorePurchases();

      if (!mounted) return;

      if (customerInfo != null && service.isPremium(customerInfo)) {
        ref.invalidate(local_providers.customerInfoProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Compras restauradas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma compra anterior encontrada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar compras: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
