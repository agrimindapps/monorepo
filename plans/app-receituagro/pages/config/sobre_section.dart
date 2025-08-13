// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/widgets/feedback_config_option_widget.dart';
import '../../widgets/section_title_widget.dart';
import 'config_utils.dart';

class SobreSection extends StatelessWidget {
  const SobreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Mais informações',
          icon: FontAwesome.info_solid,
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: FeedbackConfigOptionWidget(
                  title: 'Enviar feedback',
                  subtitle: 'Compartilhe sugestões para melhorar o aplicativo',
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: configOptionSobre(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
