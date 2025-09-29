import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/services/bovine_form_service.dart';

/// Seção de informações básicas do formulário de bovino
/// 
/// Responsabilidades:
/// - Campos: nome comum, ID registro, raça, país origem
/// - Validação específica de cada campo
/// - Formatação e limitação de entrada
/// - Integração com Design System
class BovineBasicInfoSection extends StatelessWidget {
  const BovineBasicInfoSection({
    super.key,
    required commonNameController,
    required registrationIdController,
    required breedController,
    required originCountryController,
    required formService,
    enabled = true,
  });

  final TextEditingController commonNameController;
  final TextEditingController registrationIdController;
  final TextEditingController breedController;
  final TextEditingController originCountryController;
  final BovineFormService formService;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Básicas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nome Comum
          DSTextField(
            label: 'Nome Comum *',
            hint: 'Ex: Nelore, Angus, Brahman',
            controller: commonNameController,
            enabled: enabled,
            keyboardType: TextInputType.text,
            validator: formService.validateCommonName,
            prefixIcon: Icons.pets,
          ),
          
          const SizedBox(height: 16),
          
          // ID de Registro
          DSTextField(
            label: 'ID de Registro',
            hint: 'Ex: BR-001-2024',
            controller: registrationIdController,
            enabled: enabled,
            keyboardType: TextInputType.text,
            validator: formService.validateRegistrationId,
            prefixIcon: Icons.badge,
          ),
          
          const SizedBox(height: 8),
          
          // Helper text para ID
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Deixe vazio para gerar automaticamente',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Raça
          DSTextField(
            label: 'Raça *',
            hint: 'Ex: Nelore, Angus, Brahman',
            controller: breedController,
            enabled: enabled,
            keyboardType: TextInputType.text,
            validator: formService.validateBreed,
            prefixIcon: Icons.category,
          ),
          
          const SizedBox(height: 16),
          
          // País de Origem
          DSTextField(
            label: 'País de Origem *',
            hint: 'Ex: Brasil, Índia, Escócia',
            controller: originCountryController,
            enabled: enabled,
            keyboardType: TextInputType.text,
            validator: formService.validateOriginCountry,
            prefixIcon: Icons.public,
          ),
          
          const SizedBox(height: 8),
          
          // Lista de países suportados
          _buildSupportedCountriesHint(context),
        ],
      ),
    );
  }

  Widget _buildSupportedCountriesHint(BuildContext context) {
    const supportedCountries = [
      'Brasil', 'Argentina', 'Uruguai', 'Estados Unidos', 'Canadá',
      'França', 'Inglaterra', 'Holanda', 'Alemanha', 'Suíça',
      'Austrália', 'Nova Zelândia', 'México', 'Colômbia'
    ];

    return ExpansionTile(
      title: Text(
        'Países Suportados',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(
        Icons.flag,
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
          children: supportedCountries.map((country) {
            return Chip(
              label: Text(
                country,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onDeleted: null, // Não deletável
              avatar: null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Componente especializado para input de ID de Registro
/// com formatação automática e validação
class RegistrationIdField extends StatefulWidget {
  const RegistrationIdField({
    super.key,
    required controller,
    required formService,
    enabled = true,
    onChanged,
  });

  final TextEditingController controller;
  final BovineFormService formService;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<RegistrationIdField> createState() => _RegistrationIdFieldState();
}

class _RegistrationIdFieldState extends State<RegistrationIdField> {
  bool _showCharCount = false;
  static const int _maxLength = 20;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final shouldShow = text.length >= 15; // Mostra quando próximo do limite
    
    if (shouldShow != _showCharCount) {
      setState(() {
        _showCharCount = shouldShow;
      });
    }
    
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: 'ID de Registro',
            hintText: 'Ex: BR-001-2024',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.badge),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'Limpar',
                  )
                : null,
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-_]')),
            LengthLimitingTextInputFormatter(_maxLength),
            _RegistrationIdFormatter(), // Formatter customizado
          ],
          validator: widget.formService.validateRegistrationId,
          onChanged: widget.onChanged,
        ),
        
        // Contador de caracteres (quando próximo do limite)
        if (_showCharCount)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              '${widget.controller.text.length}/$_maxLength caracteres',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: widget.formService.isNearCharLimit(
                  widget.controller.text, 
                  _maxLength,
                ) 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Formatter customizado para ID de registro
/// Aplica formatação automática para padrões comuns
class _RegistrationIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permite apenas letras maiúsculas, números, hífen e underscore
    final filteredText = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9\-_]'), 
      '',
    );
    
    // Aplica formatação automática para padrões brasileiros
    String formattedText = filteredText;
    
    // Se começar com BR e não tiver hífen, adiciona automaticamente
    if (formattedText.startsWith('BR') && 
        formattedText.length > 2 && 
        !formattedText.contains('-') &&
        formattedText.length <= 5) {
      formattedText = 'BR-${formattedText.substring(2)}';
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}