// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../services/bovino_taxonomy_service.dart';

class BovinoCategorySelector extends StatefulWidget {
  final String title;
  final String selectedValue;
  final List<String> options;
  final Function(String) onChanged;
  final bool isRequired;
  final String? hint;
  final Widget? icon;

  const BovinoCategorySelector({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.isRequired = false,
    this.hint,
    this.icon,
  });

  @override
  State<BovinoCategorySelector> createState() => _BovinoCategorySelectorState();
}

class _BovinoCategorySelectorState extends State<BovinoCategorySelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              widget.selectedValue.isEmpty
                  ? (widget.hint ?? 'Selecione uma opção')
                  : widget.selectedValue,
              style: TextStyle(
                color: widget.selectedValue.isEmpty
                    ? Colors.grey.shade600
                    : Colors.black87,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: widget.options.map((option) {
              final isSelected = widget.selectedValue == option;
              return ListTile(
                dense: true,
                title: Text(option),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                selected: isSelected,
                onTap: () {
                  widget.onChanged(option);
                  setState(() {
                    _isExpanded = false;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class BovinoTagSelector extends StatefulWidget {
  final String title;
  final List<String> selectedTags;
  final Map<String, List<String>> categorizedOptions;
  final Function(List<String>) onChanged;
  final int maxTags;
  final Widget? icon;

  const BovinoTagSelector({
    super.key,
    required this.title,
    required this.selectedTags,
    required this.categorizedOptions,
    required this.onChanged,
    this.maxTags = 10,
    this.icon,
  });

  @override
  State<BovinoTagSelector> createState() => _BovinoTagSelectorState();
}

class _BovinoTagSelectorState extends State<BovinoTagSelector> {
  String _selectedCategory = '';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.categorizedOptions.isNotEmpty) {
      _selectedCategory = widget.categorizedOptions.keys.first;
    }
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(widget.selectedTags);

    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      if (newTags.length < widget.maxTags) {
        newTags.add(tag);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Máximo de ${widget.maxTags} tags permitidas'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    widget.onChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Text(
              '${widget.selectedTags.length}/${widget.maxTags}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tags selecionadas
        if (widget.selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _toggleTag(tag),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // Seletor de categorias
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Text(
              widget.selectedTags.isEmpty
                  ? 'Adicionar características'
                  : 'Adicionar mais características',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: [
              // Seletor de categoria
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: widget.categorizedOptions.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Tags da categoria selecionada
              if (_selectedCategory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.categorizedOptions[_selectedCategory]!
                        .map((tag) {
                      final isSelected = widget.selectedTags.contains(tag);
                      final canAdd =
                          widget.selectedTags.length < widget.maxTags;

                      return FilterChip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (canAdd || isSelected)
                            ? (_) => _toggleTag(tag)
                            : null,
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.green.shade100,
                        checkmarkColor: Colors.green,
                        disabledColor: Colors.grey.shade200,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class BovinoRaceSelector extends StatefulWidget {
  final String selectedRace;
  final Function(String) onRaceChanged;
  final Function(String) onCategoryChanged;

  const BovinoRaceSelector({
    super.key,
    required this.selectedRace,
    required this.onRaceChanged,
    required this.onCategoryChanged,
  });

  @override
  State<BovinoRaceSelector> createState() => _BovinoRaceSelectorState();
}

class _BovinoRaceSelectorState extends State<BovinoRaceSelector> {
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedRace.isNotEmpty) {
      _selectedCategory =
          BovinoTaxonomyService.getCategoriaRaca(widget.selectedRace) ?? '';
    }
    if (_selectedCategory.isEmpty &&
        BovinoTaxonomyService.racasPorCategoria.isNotEmpty) {
      _selectedCategory = BovinoTaxonomyService.racasPorCategoria.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raça do Animal',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),

        // Seletor de categoria de raça
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Categoria da Raça',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: BovinoTaxonomyService.racasPorCategoria.keys.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
                // Limpar raça selecionada ao mudar categoria
                widget.onRaceChanged('');
              });
              widget.onCategoryChanged(value);
            }
          },
        ),

        const SizedBox(height: 12),

        // Seletor de raça específica
        if (_selectedCategory.isNotEmpty)
          DropdownButtonFormField<String>(
            value: widget.selectedRace.isEmpty ? null : widget.selectedRace,
            decoration: const InputDecoration(
              labelText: 'Raça Específica *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            items: BovinoTaxonomyService.getRacasPorCategoria(_selectedCategory)
                .map((race) {
              return DropdownMenuItem(
                value: race,
                child: Text(race),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onRaceChanged(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione uma raça';
              }
              return null;
            },
          ),
      ],
    );
  }
}
