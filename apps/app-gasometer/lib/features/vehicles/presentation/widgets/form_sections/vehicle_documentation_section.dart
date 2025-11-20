import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/form_section_header.dart';
import '../../../../../core/widgets/validated_form_field.dart';

/// Vehicle documentation section (Odometer, Plate, Chassi, Renavam)
class VehicleDocumentationSection extends StatelessWidget {
  const VehicleDocumentationSection({
    required this.odometerController,
    required this.plateController,
    required this.chassisController,
    required this.renavamController,
    required this.odometerFieldKey,
    required this.plateFieldKey,
    required this.chassisFieldKey,
    required this.renavamFieldKey,
    required this.odometerFocusNode,
    required this.plateFocusNode,
    required this.chassisFocusNode,
    required this.renavamFocusNode,
    this.onOdometerChanged,
    this.onPlateChanged,
    this.onChassisChanged,
    this.onRenavamChanged,
    super.key,
  });

  final TextEditingController odometerController;
  final TextEditingController plateController;
  final TextEditingController chassisController;
  final TextEditingController renavamController;
  final GlobalKey odometerFieldKey;
  final GlobalKey plateFieldKey;
  final GlobalKey chassisFieldKey;
  final GlobalKey renavamFieldKey;
  final FocusNode odometerFocusNode;
  final FocusNode plateFocusNode;
  final FocusNode chassisFocusNode;
  final FocusNode renavamFocusNode;
  final ValueChanged<String>? onOdometerChanged;
  final ValueChanged<String>? onPlateChanged;
  final ValueChanged<String>? onChassisChanged;
  final ValueChanged<String>? onRenavamChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormSectionHeader(
      title: 'Documentação',
      icon: Icons.description,
      child: Column(
        children: [
          Container(
            key: odometerFieldKey,
            child: ValidatedFormField(
              controller: odometerController,
              focusNode: odometerFocusNode,
              label: 'Odômetro Atual',
              hint: '0,00',
              required: true,
              validationType: ValidationType.decimal,
              minValue: 0.0,
              maxValue: 999999.0,
              validateOnChange: false,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              suffix: Text(
                'km',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onChanged: onOdometerChanged,
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: plateFieldKey,
            child: ValidatedFormField(
              controller: plateController,
              focusNode: plateFocusNode,
              label: 'Placa',
              hint: 'Ex: ABC1234 ou ABC1D23',
              required: true,
              validationType: ValidationType.licensePlate,
              maxLength: 7,
              validateOnChange: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: onPlateChanged,
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: chassisFieldKey,
            child: ValidatedFormField(
              controller: chassisController,
              focusNode: chassisFocusNode,
              label: 'Chassi (opcional)',
              hint: 'Ex: 9BWZZZ377VT004251',
              required: false,
              validationType: ValidationType.chassis,
              maxLength: 17,
              validateOnChange: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-HJ-NPR-Z0-9]')),
                LengthLimitingTextInputFormatter(17),
                UpperCaseTextFormatter(),
              ],
              onChanged: onChassisChanged,
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: renavamFieldKey,
            child: ValidatedFormField(
              controller: renavamController,
              focusNode: renavamFocusNode,
              label: 'Renavam (opcional)',
              hint: 'Ex: 12345678901',
              required: false,
              validationType: ValidationType.renavam,
              keyboardType: TextInputType.number,
              maxLength: 11,
              validateOnChange: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              onChanged: onRenavamChanged,
            ),
          ),
        ],
      ),
    );
  }
}
