// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

/// Widget mock para substituir o RewardedAdWidget
/// Mostra uma mensagem informativa de que anúncios estão desabilitados
class MockRewardedAdWidget extends StatelessWidget {
  final String? adUnitId;
  final String? title;
  final String? subtitle;

  const MockRewardedAdWidget({
    super.key,
    this.adUnitId,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(
          FontAwesome.rectangle_ad_solid,
          size: 18,
          color: Colors.grey.shade500,
        ),
      ),
      title: Text(title ?? 'Anúncios desabilitados'),
      subtitle: Text(
        subtitle ?? 'Esta versão do aplicativo não exibe publicidade',
      ),
      trailing: Icon(
        Icons.block,
        size: 14,
        color: Colors.grey.shade400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabled: false, // Sempre desabilitado
    );
  }
}
