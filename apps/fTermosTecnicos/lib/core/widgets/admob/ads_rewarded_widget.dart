import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admob_service.dart';
import '../../../features/premium/presentation/providers/premium_providers.dart';

class RewardedAdWidget extends ConsumerStatefulWidget {
  const RewardedAdWidget({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  ConsumerState<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends ConsumerState<RewardedAdWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize premium ad check
    Future.microtask(() {
      ref.read(adMobServiceProvider.notifier).getPremiumAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumUser = ref.watch(isPremiumProvider);
    final premiumAdHours = ref.watch(premiumAdHoursProvider);
    final rewardedAdIsLoaded = ref.watch(rewardedAdIsLoadedProvider);
    final rewardedAd = ref.watch(rewardedAdProvider);

    return ListTile(
      enabled: !isPremiumUser,
      title: const Text('Remover Publicidade'),
      subtitle: isPremiumUser
          ? const Text('Você já é um usuário premium.')
          : Text(premiumAdHours == 0
              ? 'Desfrute de uma pausa nos anúncios em troca de alguns segundos do seu tempo.'
              : 'Você possui $premiumAdHours horas sem anúncios.'),
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
        if (!rewardedAdIsLoaded) {
          if (premiumAdHours > 0) {
            _dialogVolteMaisTarde();
          }
        } else {
          if (rewardedAd == null) {
            _dialogVolteMaisTarde();
            return;
          }

          rewardedAd.show(
            onUserEarnedReward: (ad, reward) {
              int amount = reward.amount.toInt();
              ref.read(adMobServiceProvider.notifier).setPremiumAd(amount);
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

class BtnRewardedAd extends ConsumerWidget {
  const BtnRewardedAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumUser = ref.watch(isPremiumProvider);
    final isPremiumAd = ref.watch(isPremiumAdProvider);
    final rewardedAdIsLoaded = ref.watch(rewardedAdIsLoadedProvider);
    final rewardedAd = ref.watch(rewardedAdProvider);

    if (isPremiumUser) {
      return const SizedBox.shrink();
    }

    return !isPremiumAd
        ? IconButton(
            color: Colors.white,
            icon: const Icon(Icons.local_play_outlined),
            onPressed: () {
              if (rewardedAdIsLoaded && rewardedAd != null) {
                rewardedAd.show(
                  onUserEarnedReward: (ad, reward) {
                    int amount = reward.amount.toInt();
                    ref.read(adMobServiceProvider.notifier).setPremiumAd(amount);
                  },
                );
              }
            },
          )
        : const SizedBox.shrink();
  }
}
