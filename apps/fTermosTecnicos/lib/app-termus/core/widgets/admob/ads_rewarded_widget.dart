import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/admob_service.dart';
import '../../services/in_app_purchase_service.dart';

class RewardedAdWidget extends StatefulWidget {
  const RewardedAdWidget({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends State<RewardedAdWidget> {
  @override
  void initState() {
    super.initState();
    AdmobRepository().getPremiumAd();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !InAppPurchaseService().isPremium.value,
      title: const Text('Remover Publicidade'),
      subtitle: Obx(() {
        if (InAppPurchaseService().isPremium.value) {
          return const Text('Você já é um usuário premium.');
        }

        return Text(AdmobRepository().premiumAdHours.value == 0
            ? 'Desfrute de uma pausa nos anúncios em troca de alguns segundos do seu tempo.'
            : 'Você possui ${AdmobRepository().premiumAdHours.value} horas sem anúncios.');
      }),
      trailing: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            Icons.local_play_outlined,
            color: Colors.amber.shade600,
          )),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(10),
        top: Radius.circular(0),
      )),
      onTap: () {
        if (AdmobRepository().rewardedAdIsLoaded.value == false) {
          // nada
          if (AdmobRepository().premiumAdHours.value > 0) {
            _dialogVolteMaisTarde();
          }
        } else {
          // verificar se foi inicializado
          if (AdmobRepository().rewardedAd == null) {
            _dialogVolteMaisTarde();
            return;
          }

          AdmobRepository().rewardedAd?.show(
            onUserEarnedReward: (ad, reward) {
              int amount = reward.amount.toInt();
              AdmobRepository().setPremiumAd(amount);
            },
          );
        }
      },
    );
  }

  Future<dynamic> _dialogVolteMaisTarde() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Volte mais tarde'),
          content: const Text(
              'Aproveite as funcionalidades do aplicativo e volte mais tarde'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Widget btnRewardedAd() {
  return Obx(
    () {
      if (InAppPurchaseService().isPremium.value) {
        return const SizedBox.shrink();
      }

      return !AdmobRepository().isPremiumAd.value
          ? IconButton(
              color: Colors.white,
              icon: const Icon(Icons.local_play_outlined),
              onPressed: () {
                if (AdmobRepository().rewardedAdIsLoaded.value == true) {
                  AdmobRepository().rewardedAd?.show(
                    onUserEarnedReward: (ad, reward) {
                      int amount = reward.amount.toInt();
                      AdmobRepository().setPremiumAd(amount);
                    },
                  );
                }
              },
            )
          : const SizedBox.shrink();
    },
  );
}
