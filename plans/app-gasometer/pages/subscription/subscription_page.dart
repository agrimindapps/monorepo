// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../../core/services/in_app_purchase_service.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../../core/themes/manager.dart';
import '../../constants/subscription_constants.dart';
import '../../services/gasometer_subscription_service.dart';
import '../../services/gasometer_test_service.dart';

class GasometerSubscriptionPage extends StatefulWidget {
  const GasometerSubscriptionPage({super.key});

  @override
  State<GasometerSubscriptionPage> createState() =>
      _GasometerSubscriptionPageState();
}

class _GasometerSubscriptionPageState extends State<GasometerSubscriptionPage> {
  Timer? timer, timerPontos;
  Offering? offering;
  String pointsEspera = '...';
  bool interagindoLoja = false;
  
  // Novo service integrado
  late GasometerSubscriptionService _gasometerService;

  // Cores específicas do tema Gasometer
  final Color _primaryColor = const Color(0xFF020817);
  final Color _surfaceColor = const Color(0xFFF8FAFC);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _accentColor = const Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _gasometerService = GasometerSubscriptionService.instance;
    _updatePointsEspera();
    _carregarProdutos();
    _carregaInfoAssinatura();
  }

  void _realizarCompraComNovoService(String productId) async {
    try {
      _dialogCarregando();
      
      final result = await _gasometerService.purchaseSubscription(productId);
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      if (result.success) {
        _assinaturaConfirmada();
      } else if (result.error?.contains('cancelad') == true) {
        // Compra cancelada pelo usuário - não mostra erro
      } else {
        _mostrarErroCompra(result.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _mostrarErroCompra(e.toString());
    }
  }

  void _mostrarErroCompra(String erro) {
    Get.snackbar(
      'Erro na Compra',
      erro,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
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
        const SnackBar(
          padding: EdgeInsets.all(8.0),
          backgroundColor: Colors.green,
          content: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 16),
                Text('Assinatura ativada com sucesso!'),
              ],
            ),
          ),
          duration: Duration(seconds: 3),
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
                  backgroundColor: _primaryColor,
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
                  CircularProgressIndicator(color: _primaryColor),
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
      backgroundColor:
          isDark ? const Color(0xFF09090B) : const Color(0xFFF3F5F7),
      body: CustomScrollView(
        slivers: [
          // Header com gradiente
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF18181B), const Color(0xFF27272A)]
                        : [_primaryColor, _accentColor],
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
                          Icons.local_gas_station,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Text(
                            InAppPurchaseService().isPremium.value
                                ? 'Obrigado por apoiar o GasOMeter!'
                                : 'GasOMeter Premium',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      const Text(
                        'Controle avançado do seu veículo',
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
                const SizedBox(height: 16),

                // Debug section (apenas desenvolvimento)
                if (kDebugMode) _buildDebugSection(),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDark ? const Color(0xFF18181B) : Colors.white,
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
              Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
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
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ((info['percentComplete'] as double?) ?? 0) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
            const SizedBox(height: 16),
          ],

          // Datas
          if (info['startDate'] != null && info['endDate'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
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
                foregroundColor: _primaryColor,
                side: BorderSide(color: _borderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
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

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isPopular ? _primaryColor : _borderColor,
                    width: isPopular ? 2 : 1,
                  ),
                  color: isPopular ? _surfaceColor : null,
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(4),
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
                          color: _primaryColor,
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
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: [
                CircularProgressIndicator(color: _primaryColor),
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
              foregroundColor: _primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVantagensCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDark ? const Color(0xFF18181B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_border, color: _primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Recursos Premium',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVantagemItem(
              Icons.cloud_sync,
              'Sincronização na Nuvem',
              'Dados seguros e acessíveis em qualquer dispositivo',
            ),
            _buildVantagemItem(
              Icons.analytics,
              'Relatórios Avançados',
              'Análises detalhadas de consumo e custos',
            ),
            _buildVantagemItem(
              Icons.backup,
              'Backup Automático',
              'Nunca perca seus dados de abastecimento',
            ),
            _buildVantagemItem(
              Icons.timeline,
              'Gráficos Detalhados',
              'Visualize trends de consumo e economia',
            ),
            _buildVantagemItem(
              Icons.notifications_active,
              'Lembretes Inteligentes',
              'Avisos de manutenção e abastecimento',
            ),
            _buildVantagemItem(
              Icons.block,
              'Sem Anúncios',
              'Experiência premium sem interrupções',
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
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderColor),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDark ? const Color(0xFF18181B) : Colors.white,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _borderColor),
              ),
              child: const Text(
                '• A assinatura será renovada automaticamente\n'
                '• Cancele a qualquer momento nas configurações da loja\n'
                '• O pagamento será processado pela sua conta da loja\n'
                '• Recursos premium ativados imediatamente após a compra',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    InAppPurchaseService().launchPoliticaPrivacidade();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                  ),
                  child: const Text('Política de Privacidade'),
                ),
                TextButton(
                  onPressed: () {
                    InAppPurchaseService().launchTermoUso();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                  ),
                  child: const Text('Termos de Uso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDark ? Colors.red[900] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text(
                  'Debug & Test Environment',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status do novo service
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GasometerSubscriptionService Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final service = _gasometerService;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inicializado: ${service.isInitialized}'),
                        Text('Premium: ${service.isPremium}'),
                        Text('Loading: ${service.isLoading}'),
                        Text('API Keys válidas: ${GasometerSubscriptionConstants.hasValidApiKeys}'),
                        Text('Status: ${service.subscriptionStatus.statusDescription}'),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Test subscription controls
            FutureBuilder<Map<String, dynamic>>(
              future: GasometerTestService.getTestSubscriptionInfo(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final testInfo = snapshot.data!;
                final isDevelopment = testInfo['isDevelopment'] as bool? ?? false;
                
                if (!isDevelopment) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: const Text(
                      'Test subscriptions apenas disponíveis em desenvolvimento',
                      style: TextStyle(color: Colors.orange),
                    ),
                  );
                }

                final isActive = testInfo['isActive'] as bool? ?? false;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive ? Colors.green[300]! : Colors.grey[300]!
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Subscription: ${isActive ? "ATIVA" : "INATIVA"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green[800] : Colors.grey[800],
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          testInfo['message'] as String? ?? '',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await GasometerTestService.activateTestSubscription();
                              setState(() {}); // Refresh UI
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Ativar Test (24h)'),
                          ),
                          const SizedBox(width: 8),
                          if (isActive)
                            ElevatedButton(
                              onPressed: () async {
                                await GasometerTestService.removeTestSubscription();
                                setState(() {}); // Refresh UI
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Remover'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Debug actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _gasometerService.refreshStatus();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status atualizado')),
                      );
                    }
                  },
                  child: const Text('Refresh Status'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final debugInfo = _gasometerService.getDebugInfo();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Info'),
                        content: SingleChildScrollView(
                          child: Text(debugInfo.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Debug Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
