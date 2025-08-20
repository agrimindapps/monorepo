// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../services/bovino_taxonomy_service.dart';
import '../../../../services/bovino_validation_service.dart';
import 'bovino_category_selector.dart';

class BovinoFormField extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;
  final int? maxLines;
  final bool isRequired;
  final String? Function(String?)? customValidator;
  final List<String>? suggestions;
  final bool showSuggestions;

  const BovinoFormField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines,
    this.isRequired = false,
    this.customValidator,
    this.suggestions,
    this.showSuggestions = false,
  });

  @override
  State<BovinoFormField> createState() => _BovinoFormFieldState();
}

class _BovinoFormFieldState extends State<BovinoFormField> {
  late TextEditingController _controller;
  String? _validationMessage;
  bool _isValid = true;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _filteredSuggestions = widget.suggestions ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateField(String value) {
    if (widget.customValidator != null) {
      final result = widget.customValidator!(value);
      setState(() {
        _validationMessage = result;
        _isValid = result == null;
      });
    }

    // Filtrar sugestões se habilitado
    if (widget.showSuggestions && widget.suggestions != null) {
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((suggestion) =>
                suggestion.toLowerCase().contains(value.toLowerCase()))
            .take(5)
            .toList();
        _showSuggestions = value.isNotEmpty && _filteredSuggestions.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final validMaxLines =
        widget.maxLines != null && widget.maxLines! > 0 ? widget.maxLines! : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isRequired)
                  const Icon(Icons.star, size: 12, color: Colors.red),
                if (!_isValid)
                  const Icon(Icons.error_outline, size: 20, color: Colors.red)
                else if (_controller.text.isNotEmpty)
                  const Icon(Icons.check_circle_outline,
                      size: 20, color: Colors.green),
              ],
            ),
            errorText: _validationMessage,
            helperText: _getHelperText(),
            helperMaxLines: 2,
          ),
          maxLines: validMaxLines,
          validator: widget.isRequired
              ? (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null
              : null,
          onChanged: (value) {
            widget.onChanged(value);
            _validateField(value);
          },
        ),
        if (_showSuggestions && widget.showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _filteredSuggestions.map((suggestion) {
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  onTap: () {
                    _controller.text = suggestion;
                    widget.onChanged(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String? _getHelperText() {
    switch (widget.label) {
      case 'Nome Comum':
        return 'Use apenas letras, números, espaços e hífens (2-50 caracteres)';
      case 'País de Origem':
        return 'Selecione um país da lista ou digite "Outro"';
      case 'Tipo Animal':
        return 'Ex: Bovino de Corte, Bovino de Leite, Zebu';
      case 'Origem':
        return 'Descreva a origem e história do animal (até 500 caracteres)';
      case 'Características':
        return 'Inclua peso, altura, cor, temperamento, etc. (até 1000 caracteres)';
      default:
        return null;
    }
  }
}

class BovinoFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String) onNomeComumChanged;
  final Function(String) onPaisOrigemChanged;
  final Function(bool) onStatusChanged;
  final Function(String) onTipoAnimalChanged;
  final Function(String) onOrigemChanged;
  final Function(String) onCaracteristicasChanged;
  final Function(String) onRacaChanged;
  final Function(String) onAptidaoChanged;
  final Function(List<String>) onTagsChanged;
  final Function(String) onSistemaCriacaoChanged;
  final Function(String) onFinalidadeChanged;
  final String nomeComum;
  final String paisOrigem;
  final bool status;
  final String tipoAnimal;
  final String origem;
  final String caracteristicas;
  final String raca;
  final String aptidao;
  final List<String> tags;
  final String sistemaCriacao;
  final String finalidade;

  const BovinoFormContent({
    super.key,
    required this.formKey,
    required this.onNomeComumChanged,
    required this.onPaisOrigemChanged,
    required this.onStatusChanged,
    required this.onTipoAnimalChanged,
    required this.onOrigemChanged,
    required this.onCaracteristicasChanged,
    required this.onRacaChanged,
    required this.onAptidaoChanged,
    required this.onTagsChanged,
    required this.onSistemaCriacaoChanged,
    required this.onFinalidadeChanged,
    required this.nomeComum,
    required this.paisOrigem,
    required this.status,
    required this.tipoAnimal,
    required this.origem,
    required this.caracteristicas,
    required this.raca,
    required this.aptidao,
    required this.tags,
    required this.sistemaCriacao,
    required this.finalidade,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Básicas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(height: 12),
                  BovinoFormField(
                    label: 'Nome Comum',
                    initialValue: nomeComum,
                    onChanged: onNomeComumChanged,
                    isRequired: true,
                    customValidator: (value) {
                      final result =
                          BovinoValidationService.validateNomeComum(value);
                      return result.isValid ? null : result.message;
                    },
                  ),
                  const SizedBox(height: 12),
                  BovinoFormField(
                    label: 'País de Origem',
                    initialValue: paisOrigem,
                    onChanged: onPaisOrigemChanged,
                    suggestions: BovinoValidationService.paisesValidos,
                    showSuggestions: true,
                    customValidator: (value) {
                      final result =
                          BovinoValidationService.validatePaisOrigem(value);
                      return result.isValid ? null : result.message;
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Disponível para Reprodução'),
                    subtitle: const Text(
                        'Indica se o animal está ativo para reprodução'),
                    value: status,
                    onChanged: onStatusChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classificação e Características',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 12),
                  BovinoFormField(
                    label: 'Tipo Animal',
                    initialValue: tipoAnimal,
                    onChanged: onTipoAnimalChanged,
                    isRequired: true,
                    suggestions: BovinoValidationService.tiposAnimaisValidos,
                    showSuggestions: true,
                    customValidator: (value) {
                      final result =
                          BovinoValidationService.validateTipoAnimal(value);
                      return result.isValid ? null : result.message;
                    },
                  ),
                  const SizedBox(height: 12),
                  BovinoFormField(
                    label: 'Origem',
                    initialValue: origem,
                    onChanged: onOrigemChanged,
                    maxLines: 3,
                    customValidator: (value) {
                      final result =
                          BovinoValidationService.validateOrigem(value);
                      return result.isValid ? null : result.message;
                    },
                  ),
                  const SizedBox(height: 12),
                  BovinoFormField(
                    label: 'Características',
                    initialValue: caracteristicas,
                    onChanged: onCaracteristicasChanged,
                    maxLines: 3,
                    customValidator: (value) {
                      final result =
                          BovinoValidationService.validateCaracteristicas(
                              value);
                      return result.isValid ? null : result.message;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorização e Raça',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                  ),
                  const SizedBox(height: 12),
                  BovinoRaceSelector(
                    selectedRace: raca,
                    onRaceChanged: onRacaChanged,
                    onCategoryChanged:
                        (_) {}, // Categoria é inferida automaticamente
                  ),
                  const SizedBox(height: 12),
                  BovinoCategorySelector(
                    title: 'Aptidão Principal',
                    selectedValue: aptidao,
                    options: BovinoTaxonomyService.aptidoes,
                    onChanged: onAptidaoChanged,
                    isRequired: true,
                    hint: 'Selecione a aptidão principal',
                    icon: const Icon(Icons.agriculture, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Características Especiais',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 12),
                  BovinoTagSelector(
                    title: 'Tags de Características',
                    selectedTags: tags,
                    categorizedOptions:
                        BovinoTaxonomyService.caracteristicasEspeciais,
                    onChanged: onTagsChanged,
                    maxTags: 8,
                    icon: const Icon(Icons.local_offer, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manejo e Finalidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                  ),
                  const SizedBox(height: 12),
                  BovinoCategorySelector(
                    title: 'Sistema de Criação',
                    selectedValue: sistemaCriacao,
                    options: BovinoTaxonomyService.sistemasCriacao,
                    onChanged: onSistemaCriacaoChanged,
                    hint: 'Selecione o sistema de criação',
                    icon: const Icon(Icons.landscape, size: 20),
                  ),
                  const SizedBox(height: 12),
                  BovinoCategorySelector(
                    title: 'Finalidade',
                    selectedValue: finalidade,
                    options: BovinoTaxonomyService.finalidades,
                    onChanged: onFinalidadeChanged,
                    hint: 'Selecione a finalidade',
                    icon: const Icon(Icons.flag, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dica: Use a categorização para organizar melhor seu rebanho. '
                    'Os campos marcados com ⭐ são obrigatórios.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
