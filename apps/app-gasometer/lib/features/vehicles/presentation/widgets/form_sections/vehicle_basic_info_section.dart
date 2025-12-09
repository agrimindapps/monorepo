import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/form_section_header.dart';
import '../../../../../core/widgets/validated_form_field.dart';

/// Basic vehicle information section (Brand, Model, Year, Color)
class VehicleBasicInfoSection extends StatelessWidget {
  const VehicleBasicInfoSection({
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.colorController,
    required this.brandFieldKey,
    required this.modelFieldKey,
    required this.yearFieldKey,
    required this.colorFieldKey,
    required this.brandFocusNode,
    required this.modelFocusNode,
    required this.yearFocusNode,
    required this.colorFocusNode,
    this.onYearChanged,
    super.key,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final GlobalKey brandFieldKey;
  final GlobalKey modelFieldKey;
  final GlobalKey yearFieldKey;
  final GlobalKey colorFieldKey;
  final FocusNode brandFocusNode;
  final FocusNode modelFocusNode;
  final FocusNode yearFocusNode;
  final FocusNode colorFocusNode;
  final ValueChanged<int?>? onYearChanged;

  @override
  Widget build(BuildContext context) {
    return FormSectionHeader(
      title: 'Identificação do Veículo',
      icon: Icons.directions_car,
      child: Column(
        children: [
          Container(
            key: brandFieldKey,
            child: ValidatedFormField(
              controller: brandController,
              focusNode: brandFocusNode,
              label: 'Marca',
              hint: 'Ex: Ford, Volkswagen, etc.',
              required: true,
              validationType: ValidationType.length,
              minLength: 2,
              maxLengthValidation: 50,
              validateOnChange: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]')),
              ],
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: modelFieldKey,
            child: ValidatedFormField(
              controller: modelController,
              focusNode: modelFocusNode,
              label: 'Modelo',
              hint: 'Ex: Gol, Fiesta, etc.',
              required: true,
              validationType: ValidationType.length,
              minLength: 2,
              maxLengthValidation: 50,
              validateOnChange: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-]'),
                ),
              ],
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: Container(
                  key: yearFieldKey,
                  child: _buildYearDropdown(context),
                ),
              ),
              const SizedBox(width: GasometerDesignTokens.spacingMd),
              Expanded(
                child: Container(
                  key: colorFieldKey,
                  child: ValidatedFormField(
                    controller: colorController,
                    focusNode: colorFocusNode,
                    label: 'Cor',
                    hint: 'Ex: Branco, Preto, etc.',
                    required: true,
                    validationType: ValidationType.length,
                    minLength: 3,
                    maxLengthValidation: 30,
                    validateOnChange: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZÀ-ÿ\s\-]'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1900 + 1,
      (index) => currentYear - index,
    );
    final yearText = yearController.text;
    final currentValue = yearText.trim().isNotEmpty
        ? int.tryParse(yearText)
        : null;

    return DropdownButtonFormField<int>(
      initialValue: currentValue,
      focusNode: yearFocusNode,
      decoration: InputDecoration(
        labelText: 'Ano',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) => value == null ? 'Campo obrigatório' : null,
      items: years.map((year) {
        return DropdownMenuItem<int>(value: year, child: Text(year.toString()));
      }).toList(),
      onChanged: onYearChanged,
    );
  }
}
