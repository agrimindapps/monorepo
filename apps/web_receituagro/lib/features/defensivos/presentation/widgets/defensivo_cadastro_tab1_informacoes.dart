import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/defensivo.dart';
import '../providers/defensivo_cadastro_provider.dart';

/// Tab 1: Informações Básicas do Defensivo
/// 17 campos incluindo nome, fabricante, ingrediente ativo, classe toxicológica, etc.
class DefensivoCadastroTab1Informacoes extends ConsumerStatefulWidget {
  const DefensivoCadastroTab1Informacoes({super.key});

  @override
  ConsumerState<DefensivoCadastroTab1Informacoes> createState() =>
      _DefensivoCadastroTab1InformacoesState();
}

class _DefensivoCadastroTab1InformacoesState
    extends ConsumerState<DefensivoCadastroTab1Informacoes> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all 17 fields
  late final TextEditingController _nomeComumController;
  late final TextEditingController _nomeTecnicoController;
  late final TextEditingController _fabricanteController;
  late final TextEditingController _ingredienteAtivoController;
  late final TextEditingController _quantProdutoController;
  late final TextEditingController _mapaController;
  late final TextEditingController _formulacaoController;
  late final TextEditingController _modoAcaoController;
  late final TextEditingController _classeAgronomicaController;
  late final TextEditingController _toxicoController;
  late final TextEditingController _classAmbientalController;
  late final TextEditingController _inflamavelController;
  late final TextEditingController _corrosivoController;
  late final TextEditingController _comercializadoController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nomeComumController = TextEditingController();
    _nomeTecnicoController = TextEditingController();
    _fabricanteController = TextEditingController();
    _ingredienteAtivoController = TextEditingController();
    _quantProdutoController = TextEditingController();
    _mapaController = TextEditingController();
    _formulacaoController = TextEditingController();
    _modoAcaoController = TextEditingController();
    _classeAgronomicaController = TextEditingController();
    _toxicoController = TextEditingController();
    _classAmbientalController = TextEditingController();
    _inflamavelController = TextEditingController();
    _corrosivoController = TextEditingController();
    _comercializadoController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final defensivo = ref.read(defensivoCadastroProvider).defensivo;
    if (defensivo != null) {
      _nomeComumController.text = defensivo.nomeComum;
      _nomeTecnicoController.text = defensivo.nomeTecnico ?? '';
      _fabricanteController.text = defensivo.fabricante;
      _ingredienteAtivoController.text = defensivo.ingredienteAtivo;
      _quantProdutoController.text = defensivo.quantProduto ?? '';
      _mapaController.text = defensivo.mapa ?? '';
      _formulacaoController.text = defensivo.formulacao ?? '';
      _modoAcaoController.text = defensivo.modoAcao ?? '';
      _classeAgronomicaController.text = defensivo.classeAgronomica ?? '';
      _toxicoController.text = defensivo.toxico ?? '';
      _classAmbientalController.text = defensivo.classAmbiental ?? '';
      _inflamavelController.text = defensivo.inflamavel ?? '';
      _corrosivoController.text = defensivo.corrosivo ?? '';
      _comercializadoController.text = defensivo.comercializado ?? '';
    }
  }

  @override
  void dispose() {
    _nomeComumController.dispose();
    _nomeTecnicoController.dispose();
    _fabricanteController.dispose();
    _ingredienteAtivoController.dispose();
    _quantProdutoController.dispose();
    _mapaController.dispose();
    _formulacaoController.dispose();
    _modoAcaoController.dispose();
    _classeAgronomicaController.dispose();
    _toxicoController.dispose();
    _classAmbientalController.dispose();
    _inflamavelController.dispose();
    _corrosivoController.dispose();
    _comercializadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Identificação
            const Text(
              'Identificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nomeComumController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Comum *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome comum é obrigatório';
                      }
                      if (value.trim().length < 3) {
                        return 'Mínimo 3 caracteres';
                      }
                      return null;
                    },
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nomeTecnicoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Técnico',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fabricanteController,
                    decoration: const InputDecoration(
                      labelText: 'Fabricante *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Fabricante é obrigatório';
                      }
                      return null;
                    },
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ingredienteAtivoController,
                    decoration: const InputDecoration(
                      labelText: 'Ingrediente Ativo *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrediente ativo é obrigatório';
                      }
                      return null;
                    },
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section: Características
            const Text(
              'Características',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantProdutoController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade Produto',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _mapaController,
                    decoration: const InputDecoration(
                      labelText: 'Registro MAPA',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _formulacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Formulação (EC, SC, WG...)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _modoAcaoController,
                    decoration: const InputDecoration(
                      labelText: 'Modo de Ação',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _classeAgronomicaController,
                    decoration: const InputDecoration(
                      labelText: 'Classe Agronômica',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section: Classificação
            const Text(
              'Classificação e Segurança',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _toxicoController,
                    decoration: const InputDecoration(
                      labelText: 'Classe Toxicológica (I, II, III, IV)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _classAmbientalController,
                    decoration: const InputDecoration(
                      labelText: 'Classe Ambiental (I, II, III, IV)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _inflamavelController,
                    decoration: const InputDecoration(
                      labelText: 'Inflamável',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _corrosivoController,
                    decoration: const InputDecoration(
                      labelText: 'Corrosivo',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _comercializadoController,
                    decoration: const InputDecoration(
                      labelText: 'Comercializado',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _updateDefensivo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              '* Campos obrigatórios',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update defensivo in provider when fields change
  void _updateDefensivo([String? _]) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentState = ref.read(defensivoCadastroProvider);
    final currentDefensivo = currentState.defensivo;

    final defensivo = Defensivo(
      id: currentDefensivo?.id ?? const Uuid().v4(),
      nomeComum: _nomeComumController.text,
      nomeTecnico: _nomeTecnicoController.text.isNotEmpty
          ? _nomeTecnicoController.text
          : null,
      fabricante: _fabricanteController.text,
      ingredienteAtivo: _ingredienteAtivoController.text,
      quantProduto: _quantProdutoController.text.isNotEmpty
          ? _quantProdutoController.text
          : null,
      mapa: _mapaController.text.isNotEmpty ? _mapaController.text : null,
      formulacao: _formulacaoController.text.isNotEmpty
          ? _formulacaoController.text
          : null,
      modoAcao:
          _modoAcaoController.text.isNotEmpty ? _modoAcaoController.text : null,
      classeAgronomica: _classeAgronomicaController.text.isNotEmpty
          ? _classeAgronomicaController.text
          : null,
      toxico:
          _toxicoController.text.isNotEmpty ? _toxicoController.text : null,
      classAmbiental: _classAmbientalController.text.isNotEmpty
          ? _classAmbientalController.text
          : null,
      inflamavel: _inflamavelController.text.isNotEmpty
          ? _inflamavelController.text
          : null,
      corrosivo: _corrosivoController.text.isNotEmpty
          ? _corrosivoController.text
          : null,
      comercializado: _comercializadoController.text.isNotEmpty
          ? _comercializadoController.text
          : null,
      createdAt: currentDefensivo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(defensivoCadastroProvider.notifier).updateDefensivo(defensivo);
  }
}
