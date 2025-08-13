// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../constants/plantas_colors.dart';
import '../../database/espaco_model.dart';
import '../../database/planta_config_model.dart';
import '../../database/planta_model.dart';
import '../../repository/espaco_repository.dart';
import '../../repository/planta_config_repository.dart';
import '../../repository/planta_repository.dart';
import '../../services/domain/plants/plant_care_service.dart';
import '../../services/domain/tasks/simple_task_service.dart';

class PlantaFormController extends GetxController {
  final PlantaModel? plantaOriginal;

  PlantaFormController({this.plantaOriginal});

  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final especieController = TextEditingController();
  final observacoesController = TextEditingController();

  var fotoPlanta = Rx<String?>(null);
  var espacoSelecionado = Rx<EspacoModel?>(null);
  var espacosDisponiveis = <EspacoModel>[].obs;

  // Configurações de cuidados
  var aguaAtiva = true.obs;
  var intervaloRegaDias = 1.obs; // Todo dia (primeira opção)
  var primeiraRega = Rx<DateTime?>(null);

  var aduboAtivo = true.obs;
  var intervaloAdubacaoDias = 1.obs; // Todo dia (primeira opção)
  var primeiraAdubacao = Rx<DateTime?>(null);

  var banhoSolAtivo = true.obs;
  var intervaloBanhoSolDias = 1.obs; // Todo dia (primeira opção)
  var primeiroBanhoSol = Rx<DateTime?>(null);

  var inspecaoPragasAtiva = true.obs;
  var intervaloInspecaoPragasDias = 1.obs; // Todo dia (primeira opção)
  var primeiraInspecaoPragas = Rx<DateTime?>(null);

  var podaAtiva = true.obs;
  var intervaloPodaDias = 15.obs; // Quinzenal (primeira opção)
  var primeiraPoda = Rx<DateTime?>(null);

  var replantarAtivo = true.obs;
  var intervaloReplantarDias = 90.obs; // 3 meses (primeira opção)
  var primeiroReplantar = Rx<DateTime?>(null);

  var imagePaths = <String>[].obs;
  var isLoading = false.obs;
  var configuracoes = Rx<PlantaConfigModel?>(null);

  // Getters para identificar o modo
  bool get isEditMode => plantaOriginal != null;
  String get pageTitle => isEditMode ? 'Editar Planta' : 'Nova Planta';
  String get actionButtonText =>
      isEditMode ? 'Salvar Alterações' : 'Cadastrar Planta';

  @override
  void onInit() {
    super.onInit();
    _inicializarDados();
    _carregarEspacos();
  }

  @override
  void onClose() {
    nomeController.dispose();
    especieController.dispose();
    observacoesController.dispose();
    super.onClose();
  }

  Future<void> _inicializarDados() async {
    if (isEditMode) {
      await _carregarDadosExistentes();
    } else {
      _configurarDadosIniciais();
    }
  }

  void _configurarDadosIniciais() {
    // Configurar todas as datas para hoje
    final hoje = DateTime.now();
    primeiraRega.value = hoje;
    primeiraAdubacao.value = hoje;
    primeiroBanhoSol.value = hoje;
    primeiraInspecaoPragas.value = hoje;
    primeiraPoda.value = hoje;
    primeiroReplantar.value = hoje;
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final planta = plantaOriginal!;

      // Carregar dados básicos
      nomeController.text = planta.nome ?? '';
      especieController.text = planta.especie ?? '';
      observacoesController.text = planta.observacoes ?? '';
      imagePaths.value = planta.imagePaths ?? [];
      fotoPlanta.value = planta.fotoBase64;

      // Carregar espaço selecionado
      if (planta.espacoId != null) {
        final espacoRepo = EspacoRepository.instance;
        await espacoRepo.initialize();
        final espaco = await espacoRepo.findById(planta.espacoId!);
        espacoSelecionado.value = espaco;
      }

      // Carregar configurações
      await _carregarConfiguracoes();
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados da planta: $e');
    }
  }

  Future<void> _carregarConfiguracoes() async {
    try {
      final configRepo = PlantaConfigRepository.instance;
      await configRepo.initialize();
      final config = await configRepo.findByPlantaId(plantaOriginal!.id);

      if (config != null) {
        configuracoes.value = config;

        // Aplicar configurações aos observables
        aguaAtiva.value = config.aguaAtiva;
        intervaloRegaDias.value = config.intervaloRegaDias;

        aduboAtivo.value = config.aduboAtivo;
        intervaloAdubacaoDias.value = config.intervaloAdubacaoDias;

        banhoSolAtivo.value = config.banhoSolAtivo;
        intervaloBanhoSolDias.value = config.intervaloBanhoSolDias;

        inspecaoPragasAtiva.value = config.inspecaoPragasAtiva;
        intervaloInspecaoPragasDias.value = config.intervaloInspecaoPragasDias;

        podaAtiva.value = config.podaAtiva;
        intervaloPodaDias.value = config.intervaloPodaDias;

        replantarAtivo.value = config.replantarAtivo;
        intervaloReplantarDias.value = config.intervaloReplantarDias;
      } else {
        _configurarDadosIniciais();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
      _configurarDadosIniciais();
    }
  }

  Future<void> _carregarEspacos() async {
    try {
      final espacoRepo = EspacoRepository.instance;
      await espacoRepo.initialize();
      final espacos = await espacoRepo.findAll();
      espacosDisponiveis.value = espacos;
    } catch (e) {
      debugPrint('❌ Erro ao carregar espaços: $e');
    }
  }

  void selecionarEspaco(EspacoModel? espaco) {
    espacoSelecionado.value = espaco;
  }

  void adicionarImagem(String imagePath) {
    imagePaths.add(imagePath);
  }

  void removerImagem(int index) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths.removeAt(index);
    }
  }

  // Métodos para configuração de cuidados
  void toggleAgua(bool value) {
    aguaAtiva.value = value;
  }

  void setIntervaloRega(int dias) {
    intervaloRegaDias.value = dias;
  }

  void setPrimeiraRega(DateTime data) {
    primeiraRega.value = data;
  }

  void toggleAdubo(bool value) {
    aduboAtivo.value = value;
  }

  void setIntervaloAdubacao(int dias) {
    intervaloAdubacaoDias.value = dias;
  }

  void setPrimeiraAdubacao(DateTime data) {
    primeiraAdubacao.value = data;
  }

  void toggleBanhoSol(bool value) {
    banhoSolAtivo.value = value;
  }

  void setIntervaloBanhoSol(int dias) {
    intervaloBanhoSolDias.value = dias;
  }

  void setPrimeiroBanhoSol(DateTime data) {
    primeiroBanhoSol.value = data;
  }

  void toggleInspecaoPragas(bool value) {
    inspecaoPragasAtiva.value = value;
  }

  void setIntervaloInspecaoPragas(int dias) {
    intervaloInspecaoPragasDias.value = dias;
  }

  void setPrimeiraInspecaoPragas(DateTime data) {
    primeiraInspecaoPragas.value = data;
  }

  void togglePoda(bool value) {
    podaAtiva.value = value;
  }

  void setIntervaloPoda(int dias) {
    intervaloPodaDias.value = dias;
  }

  void setPrimeiraPoda(DateTime data) {
    primeiraPoda.value = data;
  }

  void toggleReplantar(bool value) {
    replantarAtivo.value = value;
  }

  void setIntervaloReplantar(int dias) {
    intervaloReplantarDias.value = dias;
  }

  void setPrimeiroReplantar(DateTime data) {
    primeiroReplantar.value = data;
  }

  Future<void> selecionarFoto() async {
    try {
      // Mostrar dialog para escolher fonte da imagem
      final fonte = await _mostrarDialogFonteFoto();
      if (fonte == null) return;

      final picker = ImagePicker();
      final XFile? imagemSelecionada = await picker.pickImage(
        source: fonte,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imagemSelecionada != null) {
        // Processar e salvar a imagem
        await _processarImagem(imagemSelecionada);

        Get.snackbar(
          'Sucesso',
          'Foto selecionada com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao selecionar foto: $e');
      Get.snackbar(
        'Erro',
        'Erro ao selecionar foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<ImageSource?> _mostrarDialogFonteFoto() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        decoration: BoxDecoration(
          color: PlantasColors.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar para indicar que pode ser arrastado
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PlantasColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Selecionar foto da planta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PlantasColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha de onde você quer selecionar a foto:',
              style: TextStyle(
                fontSize: 14,
                color: PlantasColors.subtitleColor,
              ),
            ),
            const SizedBox(height: 24),

            // Opção Câmera
            _buildOptionTile(
              icon: Icons.camera_alt,
              title: 'Tirar foto',
              subtitle: 'Use a câmera do dispositivo',
              onTap: () => Get.back(result: ImageSource.camera),
            ),

            const SizedBox(height: 12),

            // Opção Galeria
            _buildOptionTile(
              icon: Icons.photo_library,
              title: 'Escolher da galeria',
              subtitle: 'Selecione uma foto existente',
              onTap: () => Get.back(result: ImageSource.gallery),
            ),

            // Mostrar opção "Remover foto" apenas se já houver uma foto
            if (fotoPlanta.value != null) ...[
              const SizedBox(height: 12),
              _buildRemoveOptionTile(),
            ],

            const SizedBox(height: 24),

            // Botão cancelar
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    color: PlantasColors.subtitleColor,
                  ),
                ),
              ),
            ),

            // SafeArea para telas com notch
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: PlantasColors.borderColor),
            borderRadius: BorderRadius.circular(12),
            color: PlantasColors.cardColor,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PlantasColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: PlantasColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: PlantasColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: PlantasColors.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: PlantasColors.subtitleColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveOptionTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.back();
          _removerFoto();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: PlantasColors.errorBorderColor),
            borderRadius: BorderRadius.circular(12),
            color: PlantasColors.errorBackgroundColor,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PlantasColors.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: PlantasColors.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remover foto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: PlantasColors.errorColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Excluir a foto atual',
                      style: TextStyle(
                        fontSize: 13,
                        color: PlantasColors.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: PlantasColors.errorColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removerFoto() {
    setFotoPlanta(null);
    Get.snackbar(
      'Foto removida',
      'A foto foi removida com sucesso!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> _processarImagem(XFile imagemSelecionada) async {
    try {
      // Ler os bytes da imagem
      final bytes = await imagemSelecionada.readAsBytes();

      // Redimensionar se necessário
      img.Image? imagem = img.decodeImage(bytes);
      if (imagem != null) {
        // Redimensionar para máximo 800x800 mantendo aspecto
        if (imagem.width > 800 || imagem.height > 800) {
          imagem = img.copyResize(
            imagem,
            width: imagem.width > imagem.height ? 800 : null,
            height: imagem.height > imagem.width ? 800 : null,
          );
        }

        // Converter para base64
        final bytesProcessados = img.encodeJpg(imagem, quality: 85);
        final base64String = base64Encode(bytesProcessados);

        // Salvar na planta
        setFotoPlanta(base64String);

        // Adicionar ao imagePaths se ainda não estiver lá
        if (!imagePaths.contains(base64String)) {
          adicionarImagem(base64String);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar imagem: $e');
      rethrow;
    }
  }

  void setFotoPlanta(String? foto) {
    fotoPlanta.value = foto;
  }

  void navegarParaEspacos() {
    // TODO: Implementar navegação para espaços
    Get.snackbar(
      'Em desenvolvimento',
      'Navegação para espaços será implementada em breve',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setEspaco(EspacoModel? espaco) {
    espacoSelecionado.value = espaco;
  }

  Future<void> criarEspacoPersonalizado(String nomeEspaco) async {
    try {
      final espacoRepo = EspacoRepository.instance;
      await espacoRepo.initialize();

      // Verificar se já existe um espaço com este nome
      final espacosExistentes = await espacoRepo.findByNome(nomeEspaco);
      if (espacosExistentes.isNotEmpty) {
        // Se já existe, selecionar o existente
        selecionarEspaco(espacosExistentes.first);
        return;
      }

      // Criar novo espaço
      final now = DateTime.now();
      final novoEspaco = EspacoModel(
        id: '',
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        nome: nomeEspaco,
        descricao: 'Espaço personalizado criado pelo usuário',
        ativo: true,
        dataCriacao: now,
      );

      final espacoId = await espacoRepo.createLegacy(novoEspaco);
      final espacoCriado = await espacoRepo.findById(espacoId);

      if (espacoCriado != null) {
        // Atualizar lista de espaços disponíveis
        await _carregarEspacos();
        // Selecionar o novo espaço
        selecionarEspaco(espacoCriado);

        Get.snackbar(
          'Sucesso',
          'Espaço "$nomeEspaco" criado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar espaço personalizado: $e');
      Get.snackbar(
        'Erro',
        'Erro ao criar espaço: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> salvar() async {
    if (!_validarFormulario()) {
      return;
    }

    try {
      isLoading.value = true;

      if (isEditMode) {
        await _atualizarPlanta();
      } else {
        await _criarPlanta();
      }

      Get.back(result: true);
      Get.snackbar(
        'Sucesso',
        isEditMode
            ? 'Planta "${nomeController.text}" foi atualizada com sucesso!'
            : 'Planta "${nomeController.text}" foi cadastrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF20B2AA),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        isEditMode
            ? 'Erro ao atualizar planta: $e'
            : 'Erro ao cadastrar planta: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _criarPlanta() async {
    // Inicializar services
    await PlantCareService.instance.initialize();
    await SimpleTaskService.instance.initialize();

    // Criar modelo básico da planta
    final now = DateTime.now().millisecondsSinceEpoch;
    final planta = PlantaModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      nome: nomeController.text.trim(),
      especie: especieController.text.trim().isEmpty
          ? null
          : especieController.text.trim(),
      espacoId: espacoSelecionado.value?.id,
      observacoes: observacoesController.text.trim().isEmpty
          ? null
          : observacoesController.text.trim(),
      imagePaths: imagePaths.toList(),
      fotoBase64: fotoPlanta.value,
    );

    // Salvar planta
    final plantaRepo = PlantaRepository.instance;
    await plantaRepo.initialize();
    final plantaId = await plantaRepo.create(planta);

    // Salvar configurações
    await _salvarConfiguracoes(plantaId);

    // Criar tarefas iniciais
    await _criarTarefasIniciais(plantaId);
  }

  Future<void> _atualizarPlanta() async {
    final plantaAtualizada = plantaOriginal!.copyWith(
      nome: nomeController.text.trim(),
      especie: especieController.text.trim().isEmpty
          ? null
          : especieController.text.trim(),
      espacoId: espacoSelecionado.value?.id,
      observacoes: observacoesController.text.trim().isEmpty
          ? null
          : observacoesController.text.trim(),
      imagePaths: imagePaths.toList(),
      fotoBase64: fotoPlanta.value,
    );
    plantaAtualizada.markAsModified();

    // Salvar planta
    final plantaRepo = PlantaRepository.instance;
    await plantaRepo.initialize();
    await plantaRepo.update(plantaOriginal!.id, plantaAtualizada);

    // Salvar/atualizar configurações
    await _salvarConfiguracoes(plantaOriginal!.id);
  }

  Future<void> _salvarConfiguracoes(String plantaId) async {
    try {
      final configRepo = PlantaConfigRepository.instance;
      await configRepo.initialize();

      final novaConfig = PlantaConfigModel(
        id: configuracoes.value?.id ?? '',
        createdAt: configuracoes.value?.createdAt ??
            DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        plantaId: plantaId,
        aguaAtiva: aguaAtiva.value,
        intervaloRegaDias: intervaloRegaDias.value,
        aduboAtivo: aduboAtivo.value,
        intervaloAdubacaoDias: intervaloAdubacaoDias.value,
        banhoSolAtivo: banhoSolAtivo.value,
        intervaloBanhoSolDias: intervaloBanhoSolDias.value,
        inspecaoPragasAtiva: inspecaoPragasAtiva.value,
        intervaloInspecaoPragasDias: intervaloInspecaoPragasDias.value,
        podaAtiva: podaAtiva.value,
        intervaloPodaDias: intervaloPodaDias.value,
        replantarAtivo: replantarAtivo.value,
        intervaloReplantarDias: intervaloReplantarDias.value,
      );

      if (configuracoes.value != null) {
        await configRepo.update(configuracoes.value!.id, novaConfig);
      } else {
        await configRepo.create(novaConfig);
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações: $e');
      rethrow;
    }
  }

  Future<void> _criarTarefasIniciais(String plantaId) async {
    await SimpleTaskService.instance.createInitialTasksForPlant(
      plantaId: plantaId,
      aguaAtiva: aguaAtiva.value,
      intervaloRegaDias: intervaloRegaDias.value,
      primeiraRega: primeiraRega.value,
      aduboAtivo: aduboAtivo.value,
      intervaloAdubacaoDias: intervaloAdubacaoDias.value,
      primeiraAdubacao: primeiraAdubacao.value,
      banhoSolAtivo: banhoSolAtivo.value,
      intervaloBanhoSolDias: intervaloBanhoSolDias.value,
      primeiroBanhoSol: primeiroBanhoSol.value,
      inspecaoPragasAtiva: inspecaoPragasAtiva.value,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias.value,
      primeiraInspecaoPragas: primeiraInspecaoPragas.value,
      podaAtiva: podaAtiva.value,
      intervaloPodaDias: intervaloPodaDias.value,
      primeiraPoda: primeiraPoda.value,
      replantarAtivo: replantarAtivo.value,
      intervaloReplantarDias: intervaloReplantarDias.value,
      primeiroReplantar: primeiroReplantar.value,
    );
  }

  bool _validarFormulario() {
    if (nomeController.text.trim().isEmpty) {
      Get.snackbar(
        'Erro',
        'Por favor, insira o nome da planta',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validarEspecie(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Espécie deve ter pelo menos 2 caracteres';
    }
    return null;
  }
}
