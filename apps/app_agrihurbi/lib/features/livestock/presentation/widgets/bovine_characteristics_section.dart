import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/services/bovine_form_service.dart';

/// Seção de características do formulário de bovino
/// 
/// Responsabilidades:
/// - Campos: aptidão, sistema de criação, finalidade
/// - Dropdowns com opções predefinidas
/// - Informações contextuais sobre cada opção
/// - Integração com Design System
class BovineCharacteristicsSection extends StatelessWidget {
  const BovineCharacteristicsSection({
    super.key,
    required this.purposeController,
    required this.formService,
    required this.selectedAptitude,
    required this.selectedBreedingSystem,
    required this.onAptitudeChanged,
    required this.onBreedingSystemChanged,
    this.enabled = true,
  });

  final TextEditingController purposeController;
  final BovineFormService formService;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final ValueChanged<BovineAptitude?> onAptitudeChanged;
  final ValueChanged<BreedingSystem?> onBreedingSystemChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Características',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Aptidão
          _buildAptitudeDropdown(context),
          
          const SizedBox(height: 16),
          
          // Sistema de Criação
          _buildBreedingSystemDropdown(context),
          
          const SizedBox(height: 16),
          
          // Finalidade
          DSTextField(
            label: 'Finalidade',
            hint: 'Ex: Reprodução, Engorda, Ordenha',
            controller: purposeController,
            enabled: enabled,
            keyboardType: TextInputType.text,
            maxLines: 2,
            validator: formService.validatePurpose,
            prefixIcon: Icons.flag,
          ),
          
          const SizedBox(height: 8),
          
          // Dicas sobre finalidade
          _buildPurposeHints(context),
        ],
      ),
    );
  }

  Widget _buildAptitudeDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<BovineAptitude>(
          value: selectedAptitude,
          decoration: InputDecoration(
            labelText: 'Aptidão',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.speed),
            enabled: enabled,
          ),
          items: BovineAptitude.values.map((aptitude) {
            return DropdownMenuItem(
              value: aptitude,
              child: Row(
                children: [
                  _getAptitudeIcon(aptitude),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          aptitude.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _getAptitudeDescription(aptitude),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onAptitudeChanged : null,
          validator: (value) {
            // Aptidão é opcional, mas se selecionada deve ser válida
            return null;
          },
        ),
        
        // Informação adicional sobre aptidão selecionada
        if (selectedAptitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Row(
              children: [
                _getAptitudeIcon(selectedAptitude!, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getAptitudeDetailedDescription(selectedAptitude!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBreedingSystemDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<BreedingSystem>(
          value: selectedBreedingSystem,
          decoration: InputDecoration(
            labelText: 'Sistema de Criação',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.agriculture),
            enabled: enabled,
          ),
          items: BreedingSystem.values.map((system) {
            return DropdownMenuItem(
              value: system,
              child: Row(
                children: [
                  _getBreedingSystemIcon(system),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          system.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _getBreedingSystemDescription(system),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onBreedingSystemChanged : null,
          validator: (value) {
            // Sistema é opcional, mas se selecionado deve ser válido
            return null;
          },
        ),
        
        // Informação adicional sobre sistema selecionado
        if (selectedBreedingSystem != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Row(
              children: [
                _getBreedingSystemIcon(selectedBreedingSystem!, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getBreedingSystemDetailedDescription(selectedBreedingSystem!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPurposeHints(BuildContext context) {
    const commonPurposes = [
      'Reprodução',
      'Engorda',
      'Ordenha',
      'Trabalho',
      'Exposição',
      'Genética',
    ];

    return ExpansionTile(
      title: Text(
        'Finalidades Comuns',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(
        Icons.lightbulb_outline,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: commonPurposes.map((purpose) {
            return ActionChip(
              label: Text(
                purpose,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              onPressed: enabled ? () {
                purposeController.text = purpose;
              } : null,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  // =====================================================================
  // HELPER METHODS - APTITUDE
  // =====================================================================

  Widget _getAptitudeIcon(BovineAptitude aptitude, {double size = 20}) {
    IconData iconData;
    Color color;
    
    switch (aptitude) {
      case BovineAptitude.beef:
        iconData = Icons.restaurant;
        color = const Color(0xFFD32F2F);
        break;
      case BovineAptitude.dairy:
        iconData = Icons.local_drink;
        color = const Color(0xFF1976D2);
        break;
      case BovineAptitude.mixed:
        iconData = Icons.merge_type;
        color = const Color(0xFF388E3C);
        break;
    }
    
    return Icon(iconData, color: color, size: size);
  }

  String _getAptitudeDescription(BovineAptitude aptitude) {
    switch (aptitude) {
      case BovineAptitude.beef:
        return 'Produção de carne';
      case BovineAptitude.dairy:
        return 'Produção de leite';
      case BovineAptitude.mixed:
        return 'Carne e leite';
    }
  }

  String _getAptitudeDetailedDescription(BovineAptitude aptitude) {
    switch (aptitude) {
      case BovineAptitude.beef:
        return 'Animais especializados na produção de carne, com características de ganho de peso e qualidade da carne.';
      case BovineAptitude.dairy:
        return 'Animais especializados na produção de leite, com alta capacidade de lactação.';
      case BovineAptitude.mixed:
        return 'Animais que combinam produção de carne e leite, versáteis para sistemas mistos.';
    }
  }

  // =====================================================================
  // HELPER METHODS - BREEDING SYSTEM
  // =====================================================================

  Widget _getBreedingSystemIcon(BreedingSystem system, {double size = 20}) {
    IconData iconData;
    Color color;
    
    switch (system) {
      case BreedingSystem.extensive:
        iconData = Icons.landscape;
        color = const Color(0xFF388E3C);
        break;
      case BreedingSystem.intensive:
        iconData = Icons.business;
        color = const Color(0xFFF57C00);
        break;
      case BreedingSystem.semiIntensive:
        iconData = Icons.balance;
        color = const Color(0xFF1976D2);
        break;
    }
    
    return Icon(iconData, color: color, size: size);
  }

  String _getBreedingSystemDescription(BreedingSystem system) {
    switch (system) {
      case BreedingSystem.extensive:
        return 'Pastoreio livre';
      case BreedingSystem.intensive:
        return 'Confinamento total';
      case BreedingSystem.semiIntensive:
        return 'Sistema misto';
    }
  }

  String _getBreedingSystemDetailedDescription(BreedingSystem system) {
    switch (system) {
      case BreedingSystem.extensive:
        return 'Sistema com animais criados soltos em grandes áreas de pastagem, com baixa densidade.';
      case BreedingSystem.intensive:
        return 'Sistema com animais confinados, alimentação controlada e alta densidade por área.';
      case BreedingSystem.semiIntensive:
        return 'Combina pastoreio com suplementação e algum nível de confinamento rotacional.';
    }
  }
}