// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../core/services/in_app_purchase_service.dart';
import '../../core/services/revenuecat_service.dart';
import '../../core/services/subscription_config_service.dart';
import '../../core/themes/manager.dart';

class AgriHurbiSubscriptionPage extends StatefulWidget {
  const AgriHurbiSubscriptionPage({super.key});

  @override
  State<AgriHurbiSubscriptionPage> createState() =>
      _AgriHurbiSubscriptionPageState();
}

class _AgriHurbiSubscriptionPageState extends State<AgriHurbiSubscriptionPage> {
  Timer? timer, timerPontos;
  Offering? offering;
  String pointsEspera = '...';
  bool interagindoLoja = false;

  final Color _primaryGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
    _updatePointsEspera();
    _carregarProdutos();
    _carregaInfoAssinatura();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o agrihurbi
      SubscriptionConfigService.initializeForApp('agrihurbi');
    } catch (e) {
      debugPrint('Erro ao inicializar configuração: $e');
    }
  }

  void _carregarProdutos() async {
    try {
      final revenuecatService = RevenuecatService.instance;
      final offeringResult = await revenuecatService.getOfferings();
      if (mounted) {
        setState(() {
          offering = offeringResult;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    }
  }

  void _carregaInfoAssinatura() async {
    await InAppPurchaseService().inAppLoadDataSignature();
  }

  void _updatePointsEspera() {
    timerPontos = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      if (mounted) {
        setState(() {
          if (pointsEspera == '...') {
            pointsEspera = '..';
          } else if (pointsEspera == '..') {
            pointsEspera = '.';
          } else {
            pointsEspera = '...';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    timerPontos?.cancel();
    super.dispose();
  }

  void _fRestauraAssinatura() async {
    _dialogCarregando();

    bool restored = false;
    try {
      final revenuecatService = RevenuecatService.instance;
      restored = await revenuecatService.restorePurchases();
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }

    if (!mounted) return;

    if (restored) {
      InAppPurchaseService().isPremium.value =
          await InAppPurchaseService().checkSignature();
      await InAppPurchaseService().inAppLoadDataSignature();
      _assinaturaConfirmada();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _assinaturaNaoConfirmada();
      }
    }
  }

  void _realizarCompra(Package package) async {
    _dialogCarregando();

    bool purchased = false;
    try {
      final revenuecatService = RevenuecatService.instance;
      purchased = await revenuecatService.purchasePackage(package);
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }

    if (!mounted) return;

    if (purchased) {
      InAppPurchaseService().isPremium.value =
          await InAppPurchaseService().checkSignature();
      await InAppPurchaseService().inAppLoadDataSignature();
      _assinaturaConfirmada();
    }
  }

  void _assinaturaConfirmada() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: const EdgeInsets.all(8.0),
          backgroundColor: _primaryGreen,
          content: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.white, size: 20),
                SizedBox(width: 16),
                Text('Assinatura ativada com sucesso!'),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _assinaturaNaoConfirmada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assinatura não encontrada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                GetPlatform.isAndroid
                    ? 'Não encontramos assinaturas válidas para esta conta Google Play.\n\nVerifique se a assinatura está ativa ou tente uma conta diferente.'
                    : 'Não encontramos assinaturas válidas.\n\nVerifique se a assinatura está ativa na App Store.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _dialogCarregando() {
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        barrierDismissible: false,
        PopScope(
          canPop: false,
          child: AlertDialog(
            content: Container(
              alignment: Alignment.center,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _primaryGreen),
                  const SizedBox(height: 16),
                  const Text('Conectando com a loja...'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header com gradiente
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Text(
                            InAppPurchaseService().isPremium.value
                                ? 'Obrigado por apoiar o AgriHurbi!'
                                : 'AgriHurbi Premium',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
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
                // Card de planos ou status atual
                _buildPlanosCard(),
                const SizedBox(height: 16),

                // Card de vantagens
                _buildVantagensCard(),
                const SizedBox(height: 16),

                // Card de informações e termos
                _buildInfoCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanosCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final isPremium = InAppPurchaseService().isPremium.value;

          if (isPremium) {
            return _buildPlanoAtual();
          } else {
            return _buildPlanosDisponiveis();
          }
        }),
      ),
    );
  }

  Widget _buildPlanoAtual() {
    return Obx(() {
      final info = InAppPurchaseService().info;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'Plano Premium Ativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (info['subscriptionDesc'] != null &&
              info['subscriptionDesc'].isNotEmpty)
            Text(
              info['subscriptionDesc'],
              style: const TextStyle(fontSize: 16),
            ),

          const SizedBox(height: 16),

          // Barra de progresso
          if (info['percentComplete'] != null) ...[
            Text(
              info['daysRemaining'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: _primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ((info['percentComplete'] as double?) ?? 0) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
            ),
            const SizedBox(height: 16),
          ],

          // Datas
          if (info['startDate'] != null && info['endDate'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Início',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(info['startDate'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Renovação',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(info['endDate'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Botão gerenciar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                InAppPurchaseService().launchTermoUso();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Gerenciar Assinatura'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryGreen,
                side: BorderSide(color: _primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlanosDisponiveis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha seu plano Premium',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (offering?.availablePackages.isNotEmpty == true) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offering!.availablePackages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final package = offering!.availablePackages[index];
              final isPopular = index == 0; // Primeiro plano como popular

              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPopular ? _primaryGreen : Colors.grey[300]!,
                    width: isPopular ? 2 : 1,
                  ),
                  color:
                      isPopular ? _primaryGreen.withValues(alpha: 0.05) : null,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Text(
                        package.storeProduct.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                  subtitle: Text(package.storeProduct.description),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryGreen,
                        ),
                      ),
                      const Text(
                        'por mês',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () => _realizarCompra(package),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(color: _primaryGreen),
                const SizedBox(height: 16),
                Text('Carregando planos$pointsEspera'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Botão restaurar
        Center(
          child: TextButton.icon(
            onPressed: _fRestauraAssinatura,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar Compras'),
            style: TextButton.styleFrom(
              foregroundColor: _primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVantagensCard() {
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
            _buildVantagemItem(
              Icons.cloud_sync,
              'Sincronização Ilimitada',
              'Sincronize dados entre todos os seus dispositivos',
            ),
            _buildVantagemItem(
              Icons.analytics,
              'Relatórios Avançados',
              'Análises detalhadas de produtividade e custos',
            ),
            _buildVantagemItem(
              Icons.notifications_active,
              'Alertas Inteligentes',
              'Notificações personalizadas sobre clima e cultivos',
            ),
            _buildVantagemItem(
              Icons.storage,
              'Backup Automático',
              'Seus dados sempre protegidos na nuvem',
            ),
            _buildVantagemItem(
              Icons.support_agent,
              'Suporte Prioritário',
              'Atendimento preferencial e suporte técnico',
            ),
            _buildVantagemItem(
              Icons.block,
              'Sem Anúncios',
              'Experiência completa sem interrupções',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVantagemItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
            const Text(
              'Informações Importantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '• A assinatura será renovada automaticamente\n'
              '• Cancele a qualquer momento nas configurações da loja\n'
              '• O pagamento será processado pela sua conta da loja\n'
              '• Funcionalidades premium ativas imediatamente',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    InAppPurchaseService().launchPoliticaPrivacidade();
                  },
                  child: const Text('Política de Privacidade'),
                ),
                TextButton(
                  onPressed: () {
                    InAppPurchaseService().launchTermoUso();
                  },
                  child: const Text('Termos de Uso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
