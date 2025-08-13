// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../widgets/section_title_widget.dart';
import 'config_utils.dart';

class PublicidadeSection extends StatefulWidget {
  const PublicidadeSection({super.key});

  @override
  State<PublicidadeSection> createState() => _PublicidadeSectionState();
}

class _PublicidadeSectionState extends State<PublicidadeSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Publicidade & Assinaturas',
          icon: FontAwesome.money_bill_wave_solid,
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: configOptionInAppPurchase(context, setState),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
