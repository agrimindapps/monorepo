import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/in_app_purchase_service.dart';
import '../services/revenuecat_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Timer? timer, timerPontos;
  Offering? offering;
  String pointsEspera = '...';
  bool interagindoLoja = false;

  TextStyle style14 =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  @override
  void initState() {
    _updatePointsEspera();
    _carregarProdutos();
    _carregaInfoAssinatura();

    super.initState();
  }

  void _carregarProdutos() async {
    offering = await RevenuecatService.getOfferings();
    setState(() {});
  }

  void _carregaInfoAssinatura() async {
    InAppPurchaseService().inAppLoadDataSignature();
    setState(() {});
  }

  void _updatePointsEspera() {
    timerPontos = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      setState(() {
        if (pointsEspera == '...') {
          pointsEspera = '..';
        } else if (pointsEspera == '..') {
          pointsEspera = '.';
        } else {
          pointsEspera = '...';
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fRestauraAssinatura() async {
    _dialogCarregando();

    if (await RevenuecatService.restorePurchases()) {
      InAppPurchaseService().isPremium.value =
          await InAppPurchaseService().checkSignature();
      InAppPurchaseService().inAppLoadDataSignature();
      assinaturaConfirmada();
    } else {
      Get.back();
      Future.delayed(const Duration(milliseconds: 500), () {
        assinaturaNaoConfirmada();
      });
    }

    Get.back();
    setState(() {});
  }

  void realizarCompra(Package package) async {
    _dialogCarregando();

    if (await RevenuecatService.purchasePackage(package)) {
      InAppPurchaseService().isPremium.value =
          await InAppPurchaseService().checkSignature();
      InAppPurchaseService().inAppLoadDataSignature();
      assinaturaConfirmada();
    }

    Get.back();
    setState(() {});
  }

  void assinaturaConfirmada() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        padding: EdgeInsets.all(8.0),
        backgroundColor: Colors.green,
        elevation: 3,
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.white, size: 20),
              SizedBox(width: 16),
              Text('Contribuição restaurada com sucesso'),
            ],
          ),
        ),
        duration: Duration(seconds: 2), // Duração da notificação
      ),
    );
  }

  void assinaturaNaoConfirmada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alerta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GetPlatform.isAndroid
                  ? const Text(
                      'Não encontramos contribuições validas para essa conta da Google Play.\n\nCaso possua mais de uma conta, altere a conta ativa no Google Play e tente novamente.',
                      textAlign: TextAlign.center)
                  : const Text(
                      'Não encontramos contribuições válidas. Verifique se a assinatura esta ativa na sua conta da App Store.',
                      textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  // dialog com carregamento dizendo que esta conectado ao servidor
  void _dialogCarregando() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          height: 80,
          width: 50,
          child: const Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 46, 55, 107),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Consultando servidor...',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _subTituloPage(),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _cardAcoesPlanoAtual(),
                    const SizedBox(height: 8),
                    _cardVantagens(),
                    const SizedBox(height: 8),
                    _cardTermosUso(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardAcoesPlanoAtual() {
    return Card(
      color: const Color.fromRGBO(62, 62, 62, 1),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () {
            if (!InAppPurchaseService().isPremium.value) {
              return Column(
                children: [
                  const SizedBox(height: 15),
                  if (offering == null)
                    const CircularProgressIndicator()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: offering?.availablePackages.length,
                      itemBuilder: (BuildContext context, int index) {
                        var myProductList = offering?.availablePackages;

                        if (myProductList == null) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(4.0),
                          height: 58,
                          width: 320,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(246, 214, 7, 1),
                              overlayColor:
                                  const Color.fromRGBO(246, 214, 7, 1),
                              disabledBackgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                            ),
                            onPressed: () {
                              realizarCompra(myProductList[index]);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  myProductList[index].storeProduct.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  myProductList[index].storeProduct.priceString,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  _btnRestaurarAssinatura()
                ],
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  width: 320,
                  child: _cardPlanoAtual(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _btnRestaurarAssinatura() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restore,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _fRestauraAssinatura,
            child: const Text(
              'Restaurar Benefícios',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subTituloPage() {
    return SizedBox(
      width: double.infinity,
      child: Stack(children: [
        Card(
          elevation: 0,
          color: const Color.fromRGBO(246, 214, 7, 1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(width: double.infinity),
              Image.asset(
                'lib/core/assets/billing/coffe_logo.png',
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  InAppPurchaseService().isPremium.value
                      ? 'Agradecemos sua contribuição'
                      : 'Contribua com nosso crescimento',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ]),
    );
  }

  Widget _cardVantagens() {
    return Card(
      elevation: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: Text(
                'Vantagens de contribuir',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              height: 0,
              thickness: 1,
              endIndent: 10,
              indent: 10,
            ),
            ListView.separated(
              separatorBuilder: (context, index) => const Divider(height: 1),
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: InAppPurchaseService().getVantagens().length,
              itemBuilder: (context, index) {
                Map<String, dynamic> e =
                    InAppPurchaseService().getVantagens()[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  leading: index.isOdd
                      ? Image.asset(
                          'lib/core/assets/billing/${e['img']}',
                          height: 35,
                        )
                      : null,
                  trailing: index.isEven
                      ? Image.asset(
                          'lib/core/assets/billing/${e['img']}',
                          height: 35,
                        )
                      : null,
                  title: Text(
                    e['desc'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _cardPlanoAtual() {
    Widget buildInfoText(String text) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget buildProgressBar(double percent) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Stack(
          children: [
            Container(
              height: 20,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade200,
                    Colors.grey.shade200
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Container(
              height: 20,
              width: 320 * (percent / 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Obx(
      () => Column(
        children: [
          const SizedBox(height: 20, width: double.infinity),
          const Text(
            'Plano Atual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          InAppPurchaseService().info['ativo']
              ? buildInfoText(InAppPurchaseService().info['descAssinatura'])
              : buildInfoText('Não há contribuições ativa'),
          buildProgressBar(InAppPurchaseService().info['percent']),
          Text(
            InAppPurchaseService().info['daysRemaning'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Periodo: ${InAppPurchaseService().info['inicioAssinatura']} - ${InAppPurchaseService().info['fimAssinatura']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.manage_accounts,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showSubscriptionManagementDialog(context);
                },
                child: const Text(
                  'Gerenciar Assinatura',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _cardTermosUso() {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          const SizedBox(height: 25, width: double.infinity),
          SizedBox(
            width: 320,
            child: Text(
              GetPlatform.isIOS
                  ? InAppPurchaseService().getTermosUso()['apple']
                  : InAppPurchaseService().getTermosUso()['google'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 320,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Para mais informações, visite nossos ',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Termos de Uso',
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        InAppPurchaseService().launchTermoUso();
                      },
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        InAppPurchaseService().launchPoliticaPrivacidade();
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<dynamic> showSubscriptionManagementDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para gerenciar sua contribuição, siga as instruções abaixo:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                if (GetPlatform.isAndroid) ...[
                  const SizedBox(height: 8.0),
                  const Text(
                    'Acesse o aplicativo Google Play Store, toque em "Menu" e selecione "Assinaturas". Escolha a assinatura que deseja gerenciar.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
                if (GetPlatform.isIOS) ...[
                  const SizedBox(height: 8.0),
                  const Text(
                    'Na App Store, toque em seu nome ou foto de avatar, em seguida, em "Assinaturas".  Escolha a assinatura que deseja gerenciar.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Entendi',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget configOptionInAppPurchase(BuildContext context, StateSetter setState) {
  return ListTile(
    title: const Text('Pagar um café'),
    subtitle: const Text(
        'Contribua com nossa iniciativa e desbloqueie funcionalidades extras.'),
    trailing: const Icon(Icons.coffee_outlined, size: 24),
    iconColor: Colors.amber.shade600,
    onTap: () {
      Navigator.of(context).pushNamed('/premium');
    },
  );
}
