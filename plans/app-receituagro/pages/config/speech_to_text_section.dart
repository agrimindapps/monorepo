// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../widgets/section_title_widget.dart';
import 'config_utils.dart';

class SpeechToTextSection extends StatelessWidget {
  const SpeechToTextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Transcrição para Voz',
          icon: FontAwesome.microphone_solid,
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: configOptionTSSPage(context),
          ),
        ),
      ],
    );
  }
}
