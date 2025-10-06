import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/services/bovine_form_service.dart';

/// Seção de informações adicionais do formulário de bovino
/// 
/// Responsabilidades:
/// - Campos: tags, tipo animal, origem, características físicas
/// - Gestão de tags com chips interativos
/// - Campos de texto longo com contadores
/// - Integração com Design System
class BovineAdditionalInfoSection extends StatefulWidget {
  const BovineAdditionalInfoSection({
    super.key,
    required this.tagsController,
    required this.animalTypeController,
    required this.originController,
    required this.characteristicsController,
    required this.formService,
    required this.onTagsChanged,
    this.selectedTags = const [],
    this.enabled = true,
  });

  final TextEditingController tagsController;
  final TextEditingController animalTypeController;
  final TextEditingController originController;
  final TextEditingController characteristicsController;
  final BovineFormService formService;
  final ValueChanged<List<String>> onTagsChanged;
  final List<String> selectedTags;
  final bool enabled;

  @override
  State<BovineAdditionalInfoSection> createState() => _BovineAdditionalInfoSectionState();
}

class _BovineAdditionalInfoSectionState extends State<BovineAdditionalInfoSection> {
  final FocusNode _tagsFocusNode = FocusNode();
  List<String> _currentTags = [];

  @override
  void initState() {
    super.initState();
    _currentTags = List.from(widget.selectedTags);
    widget.tagsController.addListener(_onTagsTextChanged);
  }

  @override
  void dispose() {
    widget.tagsController.removeListener(_onTagsTextChanged);
    _tagsFocusNode.dispose();
    super.dispose();
  }

  void _onTagsTextChanged() {
    final newTags = widget.formService.processTags(widget.tagsController.text);
    if (_currentTags.length != newTags.length || 
        !_currentTags.every(newTags.contains)) {
      setState(() {
        _currentTags = newTags;
      });
      widget.onTagsChanged(newTags);
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty || _currentTags.contains(tag.trim().toLowerCase())) return;
    
    final updatedTags = [..._currentTags, tag.trim().toLowerCase()];
    setState(() {
      _currentTags = updatedTags;
    });
    
    widget.tagsController.text = updatedTags.join(', ');
    widget.onTagsChanged(updatedTags);
  }

  void _removeTag(String tag) {
    final updatedTags = _currentTags.where((t) => t != tag).toList();
    setState(() {
      _currentTags = updatedTags;
    });
    
    widget.tagsController.text = updatedTags.join(', ');
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações Adicionais',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTagsSection(context),
          
          const SizedBox(height: 16),
          DSTextField(
            label: 'Tipo de Animal *',
            hint: 'Ex: Bovino, Zebu',
            controller: widget.animalTypeController,
            enabled: widget.enabled,
            keyboardType: TextInputType.text,
            validator: widget.formService.validateAnimalType,
            prefixIcon: Icons.category,
          ),
          
          const SizedBox(height: 16),
          _buildOriginField(context),
          
          const SizedBox(height: 16),
          _buildCharacteristicsField(context),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.tagsController,
          focusNode: _tagsFocusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: 'Tags',
            hintText: 'Ex: reprodutor, premiado, importado',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.label),
            suffixIcon: widget.tagsController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.tagsController.clear();
                      setState(() {
                        _currentTags = [];
                      });
                      widget.onTagsChanged([]);
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'Limpar tags',
                  )
                : null,
          ),
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTag(value.trim());
              widget.tagsController.clear();
              _tagsFocusNode.requestFocus();
            }
          },
        ),
        
        const SizedBox(height: 8),
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
                'Separe as tags com vírgulas ou pressione Enter',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_currentTags.isNotEmpty)
              Text(
                '${_currentTags.length} tags',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        if (_currentTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _currentTags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                onDeleted: widget.enabled ? () => _removeTag(tag) : null,
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
        _buildSuggestedTags(context),
      ],
    );
  }

  Widget _buildSuggestedTags(BuildContext context) {
    const suggestedTags = [
      'reprodutor',
      'premiado',
      'importado',
      'elite',
      'pedigree',
      'vacinado',
      'castrado',
      'jovem',
      'adulto',
      'comercial',
    ];
    final availableTags = suggestedTags
        .where((tag) => !_currentTags.contains(tag.toLowerCase()))
        .toList();

    if (availableTags.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        'Tags Sugeridas',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(
        Icons.auto_awesome,
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
          children: availableTags.map((tag) {
            return ActionChip(
              label: Text(
                tag,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              onPressed: widget.enabled ? () => _addTag(tag) : null,
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

  Widget _buildOriginField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSTextField(
          label: 'Origem *',
          hint: 'Origem detalhada do bovino',
          controller: widget.originController,
          enabled: widget.enabled,
          keyboardType: TextInputType.text,
          maxLines: 2,
          validator: widget.formService.validateOrigin,
          prefixIcon: Icons.place,
        ),
        
        const SizedBox(height: 8),
        ExpansionTile(
          title: Text(
            'Exemplos de Origem',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOriginExample(
                  context,
                  'Fazenda Santa Maria, São Paulo',
                  'Origem específica com localização',
                ),
                _buildOriginExample(
                  context,
                  'Leilão Elite Genética 2024',
                  'Origem comercial específica',
                ),
                _buildOriginExample(
                  context,
                  'Criado na propriedade desde nascimento',
                  'Animal nascido no local',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginExample(BuildContext context, String example, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.enabled ? () {
          widget.originController.text = example;
        } : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacteristicsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSTextField(
          label: 'Características *',
          hint: 'Características físicas do bovino',
          controller: widget.characteristicsController,
          enabled: widget.enabled,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          validator: widget.formService.validateCharacteristics,
          prefixIcon: Icons.description,
        ),
        
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.characteristicsController,
          builder: (context, value, child) {
            const minChars = 10;
            final currentChars = value.text.trim().length;
            final isValid = currentChars >= minChars;
            
            return Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle_outline : Icons.info_outline,
                  size: 16,
                  color: isValid 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  isValid 
                      ? '$currentChars caracteres (válido)'
                      : '$currentChars/$minChars caracteres mínimos',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isValid 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 8),
        _buildCharacteristicsGuide(context),
      ],
    );
  }

  Widget _buildCharacteristicsGuide(BuildContext context) {
    const characteristics = [
      'Cor e padrão da pelagem',
      'Tamanho e conformação',
      'Marcas distintivas',
      'Condição corporal',
      'Temperamento',
      'Características reprodutivas',
    ];

    return ExpansionTile(
      title: Text(
        'Guia de Características',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(
        Icons.help_outline,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: characteristics.map((characteristic) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    characteristic,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}