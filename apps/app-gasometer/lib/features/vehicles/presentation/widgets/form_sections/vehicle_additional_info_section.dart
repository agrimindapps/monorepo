import 'package:flutter/material.dart';

import '../../../../../core/widgets/form_section_header.dart';
import '../../../../../core/widgets/notes_form_field.dart';

/// Additional vehicle information section (Observations)
class VehicleAdditionalInfoSection extends StatelessWidget {
  const VehicleAdditionalInfoSection({
    required this.observationsController,
    required this.observationsFieldKey,
    this.onObservationsChanged,
    super.key,
  });

  final TextEditingController observationsController;
  final GlobalKey observationsFieldKey;
  final ValueChanged<String>? onObservationsChanged;

  @override
  Widget build(BuildContext context) {
    return FormSectionHeader(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      child: Container(
        key: observationsFieldKey,
        child: ObservationsField(
          controller: observationsController,
          label: 'Observações',
          hint: 'Adicione observações sobre o veículo...',
          required: false,
          onChanged: onObservationsChanged != null
              ? (value) => onObservationsChanged!(value ?? '')
              : null,
        ),
      ),
    );
  }
}
