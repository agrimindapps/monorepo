import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../providers/premium_providers.dart';

/// Premium/Subscription Page with Riverpod
class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(premiumStatusProvider);
    final packagesAsync = ref.watch(availablePackagesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildHeader(context, statusAsync),
                const SizedBox(height: 8),
                _buildActionsCard(context, ref, statusAsync, packagesAsync),
                const SizedBox(height: 8),
                _buildBenefitsCard(context),
                const SizedBox(height: 8),
                _buildTermsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<dynamic> statusAsync) {
    final isPremium = statusAsync.maybeWhen(
      data: (status) => status.isPremium,
      orElse: () => false,
    );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Card(
            elevation: 0,
            color: const Color.fromRGBO(246, 214, 7, 1),
            child: Column(
              children: [
                const SizedBox(width: double.infinity),
                Image.asset('lib/assets/billing/coffe_logo.png', height: 150),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    isPremium ? 'Agradecemos sua contribuição' : 'Contribua com nosso crescimento',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> statusAsync,
    AsyncValue<List<Package>> packagesAsync,
  ) {
    return Card(
      color: const Color.fromRGBO(62, 62, 62, 1),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: statusAsync.when(
          data: (status) {
            if (!status.isPremium) {
              return _buildPurchaseOptions(context, ref, packagesAsync);
            }
            return _buildActiveSubscriptionInfo(context, status);
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Erro: $error', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseOptions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Package>> packagesAsync,
  ) {
    return Column(
      children: [
        const SizedBox(height: 15),
        packagesAsync.when(
          data: (packages) {
            if (packages.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhum pacote disponível', style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return Container(
                  padding: const EdgeInsets.all(4.0),
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color.fromRGBO(246, 214, 7, 1),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    onPressed: () => _purchasePackage(context, ref, package),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(package.storeProduct.title, style: const TextStyle(fontSize: 16, color: Colors.black)),
                        Text(package.storeProduct.priceString, style: const TextStyle(fontSize: 20, color: Colors.black)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Erro ao carregar', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 10),
        _buildRestoreButton(context, ref),
      ],
    );
  }

  Widget _buildActiveSubscriptionInfo(BuildContext context, dynamic status) {
    final daysLeft = status.daysRemaining ?? 0;
    final percentElapsed = status.percentElapsed;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Plano Atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(status.subscriptionType ?? 'Contribuição Ativa', style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
          _buildProgressBar(percentElapsed),
          Text('$daysLeft dias restantes', style: const TextStyle(fontSize: 14, color: Colors.white)),
          const SizedBox(height: 16),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Stack(
        children: [
          Container(height: 20, width: 320, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200)),
          Container(
            height: 20,
            width: 320 * (percent / 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [Colors.red, Colors.yellow, Colors.green], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restore, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await ref.read(premiumStatusProvider.notifier).restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compras restauradas'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text(
              'Restaurar Benefícios',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    final benefits = [
      {'img': 'icon_ad.png', 'desc': 'Remoção de anúncios'},
      {'img': 'icon_coffee.png', 'desc': 'Apoie o desenvolvimento'},
      {'img': 'icon_feature.png', 'desc': 'Acesso antecipado a novos recursos'},
    ];

    return Card(
      elevation: 0,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(12), child: Text('Vantagens de contribuir', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          const Divider(height: 0, thickness: 1),
          ListView.separated(
            separatorBuilder: (_, __) => const Divider(height: 1),
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return ListTile(
                dense: true,
                leading: index.isOdd ? Image.asset('lib/assets/billing/${benefit['img']}', height: 35) : null,
                trailing: index.isEven ? Image.asset('lib/assets/billing/${benefit['img']}', height: 35) : null,
                title: Text(benefit['desc'] ?? ''),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text(
              'O pagamento será cobrado na sua conta. A assinatura será renovada automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(BuildContext context, WidgetRef ref, Package package) async {
    try {
      final dataSource = ref.read(premiumLocalDataSourceProvider);
      await dataSource.purchasePackage(package);
      await ref.read(premiumStatusProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// Helper widget for config page
Widget configOptionPremium(BuildContext context) {
  return ListTile(
    title: const Text('Pagar um café'),
    subtitle: const Text('Contribua com nossa iniciativa'),
    trailing: const Icon(Icons.coffee_outlined),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPage())),
  );
}
