import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/planta_info.dart';

/// Form widget for PlantaInfo (Weeds)
class PlantaInfoForm extends ConsumerStatefulWidget {
  final PlantaInfo? initialInfo;
  final String pragaId;
  final void Function(PlantaInfo info)? onSave;
  final bool readOnly;

  const PlantaInfoForm({
    super.key,
    this.initialInfo,
    required this.pragaId,
    this.onSave,
    this.readOnly = false,
  });

  @override
  ConsumerState<PlantaInfoForm> createState() => _PlantaInfoFormState();
}

class _PlantaInfoFormState extends ConsumerState<PlantaInfoForm> {
  // General info controllers
  late final TextEditingController _cicloController;
  late final TextEditingController _reproducaoController;
  late final TextEditingController _habitatController;
  late final TextEditingController _adaptacoesController;
  late final TextEditingController _alturaController;

  // Morphological controllers
  late final TextEditingController _filotaxiaController;
  late final TextEditingController _formaLimboController;
  late final TextEditingController _superficieController;
  late final TextEditingController _consistenciaController;
  late final TextEditingController _nervacaoController;
  late final TextEditingController _nervacaoComprimentoController;

  // Reproductive controllers
  late final TextEditingController _inflorescenciaController;
  late final TextEditingController _periantoController;
  late final TextEditingController _tipologiaFrutoController;

  // Observations
  late final TextEditingController _observacoesController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final info = widget.initialInfo;
    _cicloController = TextEditingController(text: info?.ciclo ?? '');
    _reproducaoController = TextEditingController(text: info?.reproducao ?? '');
    _habitatController = TextEditingController(text: info?.habitat ?? '');
    _adaptacoesController = TextEditingController(text: info?.adaptacoes ?? '');
    _alturaController = TextEditingController(text: info?.altura ?? '');
    _filotaxiaController = TextEditingController(text: info?.filotaxia ?? '');
    _formaLimboController = TextEditingController(text: info?.formaLimbo ?? '');
    _superficieController = TextEditingController(text: info?.superficie ?? '');
    _consistenciaController =
        TextEditingController(text: info?.consistencia ?? '');
    _nervacaoController = TextEditingController(text: info?.nervacao ?? '');
    _nervacaoComprimentoController =
        TextEditingController(text: info?.nervacaoComprimento ?? '');
    _inflorescenciaController =
        TextEditingController(text: info?.inflorescencia ?? '');
    _periantoController = TextEditingController(text: info?.perianto ?? '');
    _tipologiaFrutoController =
        TextEditingController(text: info?.tipologiaFruto ?? '');
    _observacoesController =
        TextEditingController(text: info?.observacoes ?? '');
  }

  @override
  void didUpdateWidget(PlantaInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialInfo != oldWidget.initialInfo) {
      final info = widget.initialInfo;
      _cicloController.text = info?.ciclo ?? '';
      _reproducaoController.text = info?.reproducao ?? '';
      _habitatController.text = info?.habitat ?? '';
      _adaptacoesController.text = info?.adaptacoes ?? '';
      _alturaController.text = info?.altura ?? '';
      _filotaxiaController.text = info?.filotaxia ?? '';
      _formaLimboController.text = info?.formaLimbo ?? '';
      _superficieController.text = info?.superficie ?? '';
      _consistenciaController.text = info?.consistencia ?? '';
      _nervacaoController.text = info?.nervacao ?? '';
      _nervacaoComprimentoController.text = info?.nervacaoComprimento ?? '';
      _inflorescenciaController.text = info?.inflorescencia ?? '';
      _periantoController.text = info?.perianto ?? '';
      _tipologiaFrutoController.text = info?.tipologiaFruto ?? '';
      _observacoesController.text = info?.observacoes ?? '';
    }
  }

  @override
  void dispose() {
    _cicloController.dispose();
    _reproducaoController.dispose();
    _habitatController.dispose();
    _adaptacoesController.dispose();
    _alturaController.dispose();
    _filotaxiaController.dispose();
    _formaLimboController.dispose();
    _superficieController.dispose();
    _consistenciaController.dispose();
    _nervacaoController.dispose();
    _nervacaoComprimentoController.dispose();
    _inflorescenciaController.dispose();
    _periantoController.dispose();
    _tipologiaFrutoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

  PlantaInfo _buildInfo() {
    final now = DateTime.now();
    return PlantaInfo(
      id: widget.initialInfo?.id ?? '',
      pragaId: widget.pragaId,
      ciclo: _nullIfEmpty(_cicloController.text),
      reproducao: _nullIfEmpty(_reproducaoController.text),
      habitat: _nullIfEmpty(_habitatController.text),
      adaptacoes: _nullIfEmpty(_adaptacoesController.text),
      altura: _nullIfEmpty(_alturaController.text),
      filotaxia: _nullIfEmpty(_filotaxiaController.text),
      formaLimbo: _nullIfEmpty(_formaLimboController.text),
      superficie: _nullIfEmpty(_superficieController.text),
      consistencia: _nullIfEmpty(_consistenciaController.text),
      nervacao: _nullIfEmpty(_nervacaoController.text),
      nervacaoComprimento: _nullIfEmpty(_nervacaoComprimentoController.text),
      inflorescencia: _nullIfEmpty(_inflorescenciaController.text),
      perianto: _nullIfEmpty(_periantoController.text),
      tipologiaFruto: _nullIfEmpty(_tipologiaFrutoController.text),
      observacoes: _nullIfEmpty(_observacoesController.text),
      createdAt: widget.initialInfo?.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações da Planta Daninha',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Campos específicos para plantas daninhas',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Section: Características Gerais
        _buildSectionTitle('Características Gerais'),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _cicloController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Ciclo',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: Anual, Perene, Bienal',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _reproducaoController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Reprodução',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: Sementes, Vegetativa',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _habitatController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Habitat',
                  border: OutlineInputBorder(),
                  helperText: 'Onde a planta ocorre',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _alturaController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Altura',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: 30-60 cm',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _adaptacoesController,
          readOnly: widget.readOnly,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Adaptações',
            border: OutlineInputBorder(),
            helperText: 'Adaptações especiais da planta',
          ),
        ),
        const SizedBox(height: 24),

        // Section: Características das Folhas
        _buildSectionTitle('Características das Folhas'),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _filotaxiaController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Filotaxia',
                  border: OutlineInputBorder(),
                  helperText: 'Disposição das folhas',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _formaLimboController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Forma do Limbo',
                  border: OutlineInputBorder(),
                  helperText: 'Formato da folha',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _superficieController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Superfície',
                  border: OutlineInputBorder(),
                  helperText: 'Textura da superfície',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _consistenciaController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Consistência',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: Membranácea, Coriácea',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _nervacaoController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Nervação',
                  border: OutlineInputBorder(),
                  helperText: 'Tipo de nervuras',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _nervacaoComprimentoController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Comprimento das Nervuras',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section: Características Reprodutivas
        _buildSectionTitle('Características Reprodutivas'),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _inflorescenciaController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Inflorescência',
                  border: OutlineInputBorder(),
                  helperText: 'Tipo de inflorescência',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _periantoController,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Perianto',
                  border: OutlineInputBorder(),
                  helperText: 'Estrutura floral',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _tipologiaFrutoController,
          readOnly: widget.readOnly,
          decoration: const InputDecoration(
            labelText: 'Tipologia do Fruto',
            border: OutlineInputBorder(),
            helperText: 'Tipo de fruto produzido',
          ),
        ),
        const SizedBox(height: 24),

        // Section: Observações
        _buildSectionTitle('Observações'),
        const SizedBox(height: 16),

        TextFormField(
          controller: _observacoesController,
          readOnly: widget.readOnly,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Observações Gerais',
            border: OutlineInputBorder(),
            helperText: 'Informações adicionais sobre a planta',
          ),
        ),

        // Save button
        if (!widget.readOnly && widget.onSave != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSave!(_buildInfo());
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar Informações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.eco, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
