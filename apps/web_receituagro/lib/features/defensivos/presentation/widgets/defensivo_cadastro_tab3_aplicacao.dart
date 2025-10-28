import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/defensivo_info.dart';
import '../providers/defensivo_cadastro_provider.dart';

/// Tab 3: Aplicação (Complementary Information)
/// 7 long-text fields for packaging, technology, precautions, etc.
class DefensivoCadastroTab3Aplicacao extends ConsumerStatefulWidget {
  const DefensivoCadastroTab3Aplicacao({super.key});

  @override
  ConsumerState<DefensivoCadastroTab3Aplicacao> createState() =>
      _DefensivoCadastroTab3AplicacaoState();
}

class _DefensivoCadastroTab3AplicacaoState
    extends ConsumerState<DefensivoCadastroTab3Aplicacao> {
  late final TextEditingController _embalagensController;
  late final TextEditingController _tecnologiaController;
  late final TextEditingController _pHumanasController;
  late final TextEditingController _pAmbientalController;
  late final TextEditingController _manejoResistenciaController;
  late final TextEditingController _compatibilidadeController;
  late final TextEditingController _manejoIntegradoController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _embalagensController = TextEditingController();
    _tecnologiaController = TextEditingController();
    _pHumanasController = TextEditingController();
    _pAmbientalController = TextEditingController();
    _manejoResistenciaController = TextEditingController();
    _compatibilidadeController = TextEditingController();
    _manejoIntegradoController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final info = ref.read(defensivoCadastroProvider).defensivoInfo;
    if (info != null) {
      _embalagensController.text = info.embalagens ?? '';
      _tecnologiaController.text = info.tecnologia ?? '';
      _pHumanasController.text = info.pHumanas ?? '';
      _pAmbientalController.text = info.pAmbiental ?? '';
      _manejoResistenciaController.text = info.manejoResistencia ?? '';
      _compatibilidadeController.text = info.compatibilidade ?? '';
      _manejoIntegradoController.text = info.manejoIntegrado ?? '';
    }
  }

  @override
  void dispose() {
    _embalagensController.dispose();
    _tecnologiaController.dispose();
    _pHumanasController.dispose();
    _pAmbientalController.dispose();
    _manejoResistenciaController.dispose();
    _compatibilidadeController.dispose();
    _manejoIntegradoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(defensivoCadastroProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info message if defensivo not saved yet
          if (state.defensivo == null)
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Salve as informações básicas (Tab 1) antes de adicionar informações complementares.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          // Embalagens e Armazenamento
          _buildTextAreaField(
            controller: _embalagensController,
            label: 'Embalagens e Armazenamento',
            helpText: 'Informações sobre embalagens e condições de armazenamento',
          ),
          const SizedBox(height: 16),

          // Tecnologia de Aplicação
          _buildTextAreaField(
            controller: _tecnologiaController,
            label: 'Tecnologia de Aplicação',
            helpText: 'Equipamentos, bicos, pressão, volume de calda, etc.',
          ),
          const SizedBox(height: 16),

          // Precauções para Saúde Humana
          _buildTextAreaField(
            controller: _pHumanasController,
            label: 'Precauções para Saúde Humana',
            helpText: 'EPIs, primeiros socorros, sintomas de intoxicação',
          ),
          const SizedBox(height: 16),

          // Precauções Ambientais
          _buildTextAreaField(
            controller: _pAmbientalController,
            label: 'Precauções Ambientais',
            helpText: 'Proteção de cursos d\'água, fauna, áreas de preservação',
          ),
          const SizedBox(height: 16),

          // Manejo de Resistência
          _buildTextAreaField(
            controller: _manejoResistenciaController,
            label: 'Manejo de Resistência',
            helpText: 'Rotação de produtos, alternância de ingredientes ativos',
          ),
          const SizedBox(height: 16),

          // Compatibilidade
          _buildTextAreaField(
            controller: _compatibilidadeController,
            label: 'Compatibilidade',
            helpText: 'Compatibilidade com outros produtos, misturas em tanque',
          ),
          const SizedBox(height: 16),

          // Manejo Integrado
          _buildTextAreaField(
            controller: _manejoIntegradoController,
            label: 'Manejo Integrado de Pragas (MIP)',
            helpText: 'Integração com outras práticas de controle',
          ),

          const SizedBox(height: 24),
          const Text(
            'Todos os campos são opcionais',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Digite as informações...',
          ),
          onChanged: (_) => _updateDefensivoInfo(),
        ),
      ],
    );
  }

  /// Update defensivo info in provider when fields change
  void _updateDefensivoInfo() {
    final currentState = ref.read(defensivoCadastroProvider);
    final currentInfo = currentState.defensivoInfo;
    final defensivo = currentState.defensivo;

    if (defensivo == null) {
      return; // Can't save info without defensivo
    }

    final info = DefensivoInfo(
      id: currentInfo?.id ?? const Uuid().v4(),
      defensivoId: defensivo.id,
      embalagens: _embalagensController.text.isNotEmpty
          ? _embalagensController.text
          : null,
      tecnologia: _tecnologiaController.text.isNotEmpty
          ? _tecnologiaController.text
          : null,
      pHumanas:
          _pHumanasController.text.isNotEmpty ? _pHumanasController.text : null,
      pAmbiental: _pAmbientalController.text.isNotEmpty
          ? _pAmbientalController.text
          : null,
      manejoResistencia: _manejoResistenciaController.text.isNotEmpty
          ? _manejoResistenciaController.text
          : null,
      compatibilidade: _compatibilidadeController.text.isNotEmpty
          ? _compatibilidadeController.text
          : null,
      manejoIntegrado: _manejoIntegradoController.text.isNotEmpty
          ? _manejoIntegradoController.text
          : null,
      createdAt: currentInfo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(defensivoCadastroProvider.notifier).updateDefensivoInfo(info);
  }
}
