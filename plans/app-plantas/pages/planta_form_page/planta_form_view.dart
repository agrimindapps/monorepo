// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../constants/plantas_colors.dart';
import 'planta_form_controller.dart';

class PlantaFormView extends GetView<PlantaFormController> {
  const PlantaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: PlantasColors.backgroundColor,
          appBar: _buildAppBar(),
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildConfiguracoesSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        controller.pageTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PlantasColors.textColor,
        ),
      ),
      backgroundColor: PlantasColors.surfaceColor,
      foregroundColor: PlantasColors.textColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back,
          color: PlantasColors.primaryColor,
        ),
        tooltip: 'Voltar',
      ),
      actions: [
        Obx(() => IconButton(
              onPressed: controller.isLoading.value ? null : controller.salvar,
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PlantasColors.primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.check,
                      color: PlantasColors.primaryColor,
                    ),
              tooltip: controller.isEditMode
                  ? 'Salvar alterações'
                  : 'Cadastrar planta',
            )),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Nome',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PlantasColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: PlantasColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantasColors.borderColor),
          ),
          child: TextFormField(
            controller: controller.nomeController,
            decoration: InputDecoration(
              hintText: 'Digite o nome da planta',
              hintStyle: TextStyle(
                color: PlantasColors.subtitleColor,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 16,
              color: PlantasColors.textColor,
            ),
            textCapitalization: TextCapitalization.words,
            validator: controller.validarNome,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Foto da planta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PlantasColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildPhotoSection(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Espaço',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PlantasColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSpaceSelector(),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.selecionarFoto(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PlantasColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantasColors.borderColor),
          ),
          child: Row(
            children: [
              _buildPhotoPreview(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.fotoPlanta.value != null
                          ? 'Alterar foto'
                          : 'Adicionar foto',
                      style: TextStyle(
                        fontSize: 16,
                        color: PlantasColors.subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.fotoPlanta.value != null
                          ? 'Toque para alterar ou remover'
                          : 'Selecione uma foto da sua planta',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            PlantasColors.subtitleColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: PlantasColors.subtitleColor,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPhotoPreview() {
    return Obx(() {
      if (controller.fotoPlanta.value != null) {
        try {
          return Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image:
                        MemoryImage(base64Decode(controller.fotoPlanta.value!)),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Overlay com ícone de editar
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: PlantasColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        } catch (e) {
          // Fallback se houver erro ao decodificar
          return _buildDefaultPhotoIcon();
        }
      } else {
        return _buildDefaultPhotoIcon();
      }
    });
  }

  Widget _buildDefaultPhotoIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: PlantasColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PlantasColors.primaryColor.withValues(alpha: 0.3),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: PlantasColors.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.add_circle_outline,
            color: PlantasColors.primaryColor,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceSelector() {
    return GestureDetector(
      onTap: () => _showSpaceSelector(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: PlantasColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PlantasColors.borderColor),
        ),
        child: Obx(() => Row(
              children: [
                Expanded(
                  child: Text(
                    controller.espacoSelecionado.value?.nome ??
                        'Escolher espaço',
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.espacoSelecionado.value != null
                          ? PlantasColors.textColor
                          : PlantasColors.subtitleColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: PlantasColors.subtitleColor,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildConfiguracoesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Tarefas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PlantasColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCuidadoCard(
          titulo: 'Água',
          icone: Icons.water_drop,
          cor: const Color(0xFF2196F3),
          ativo: controller.aguaAtiva,
          intervalo: controller.intervaloRegaDias,
          proximaData: controller.primeiraRega,
          onToggle: controller.toggleAgua,
          onIntervaloChanged: controller.setIntervaloRega,
          onDataChanged: controller.setPrimeiraRega,
        ),
        _buildCuidadoCard(
          titulo: 'Adubo',
          icone: Icons.eco,
          cor: const Color(0xFF4CAF50),
          ativo: controller.aduboAtivo,
          intervalo: controller.intervaloAdubacaoDias,
          proximaData: controller.primeiraAdubacao,
          onToggle: controller.toggleAdubo,
          onIntervaloChanged: controller.setIntervaloAdubacao,
          onDataChanged: controller.setPrimeiraAdubacao,
        ),
        _buildCuidadoCard(
          titulo: 'Banho de sol',
          icone: Icons.wb_sunny,
          cor: const Color(0xFFFF9800),
          ativo: controller.banhoSolAtivo,
          intervalo: controller.intervaloBanhoSolDias,
          proximaData: controller.primeiroBanhoSol,
          onToggle: controller.toggleBanhoSol,
          onIntervaloChanged: controller.setIntervaloBanhoSol,
          onDataChanged: controller.setPrimeiroBanhoSol,
        ),
        _buildCuidadoCard(
          titulo: 'Inspeção de pragas',
          icone: Icons.search,
          cor: const Color(0xFF9C27B0),
          ativo: controller.inspecaoPragasAtiva,
          intervalo: controller.intervaloInspecaoPragasDias,
          proximaData: controller.primeiraInspecaoPragas,
          onToggle: controller.toggleInspecaoPragas,
          onIntervaloChanged: controller.setIntervaloInspecaoPragas,
          onDataChanged: controller.setPrimeiraInspecaoPragas,
        ),
        _buildCuidadoCard(
          titulo: 'Poda',
          icone: Icons.content_cut,
          cor: const Color(0xFF795548),
          ativo: controller.podaAtiva,
          intervalo: controller.intervaloPodaDias,
          proximaData: controller.primeiraPoda,
          onToggle: controller.togglePoda,
          onIntervaloChanged: controller.setIntervaloPoda,
          onDataChanged: controller.setPrimeiraPoda,
        ),
        _buildCuidadoCard(
          titulo: 'Replantar',
          icone: Icons.change_circle,
          cor: const Color(0xFF607D8B),
          ativo: controller.replantarAtivo,
          intervalo: controller.intervaloReplantarDias,
          proximaData: controller.primeiroReplantar,
          onToggle: controller.toggleReplantar,
          onIntervaloChanged: controller.setIntervaloReplantar,
          onDataChanged: controller.setPrimeiroReplantar,
        ),
      ],
    );
  }

  Widget _buildCuidadoCard({
    required String titulo,
    required IconData icone,
    required Color cor,
    required RxBool ativo,
    required RxInt intervalo,
    required Rx<DateTime?> proximaData,
    required Function(bool) onToggle,
    required Function(int) onIntervaloChanged,
    required Function(DateTime) onDataChanged,
  }) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PlantasColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantasColors.borderColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icone, color: cor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: PlantasColors.textColor,
                      ),
                    ),
                  ),
                  Switch(
                    value: ativo.value,
                    onChanged: onToggle,
                    activeColor: PlantasColors.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              if (ativo.value) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showIntervalSelector(
                      titulo, intervalo, onIntervaloChanged),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: PlantasColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PlantasColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Intervalo de ${titulo.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: PlantasColors.textColor,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _getIntervaloText(intervalo.value, titulo),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: PlantasColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: PlantasColors.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      _showDateSelector(titulo, proximaData, onDataChanged),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: PlantasColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PlantasColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Última ${titulo.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: PlantasColors.textColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _getDataText(proximaData.value),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: PlantasColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: PlantasColors.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  String _getIntervaloText(int dias, String titulo) {
    if (titulo == 'Replantar') {
      if (dias >= 365) return 'Todo ano';
      if (dias >= 30) {
        return '${(dias / 30).round()} mes${(dias / 30).round() > 1 ? 'es' : ''}';
      }
    }

    if (dias == 1) return 'Todo dia';
    if (dias == 7) return 'Toda semana';
    if (dias == 15) return 'Quinzenal';
    if (dias == 30) return 'Todo mês';

    return '$dias dias';
  }

  String _getDataText(DateTime? data) {
    if (data == null) return 'Hoje';

    final hoje = DateTime.now();
    final diferenca = data.difference(hoje).inDays;

    if (diferenca == 0) return 'Hoje';
    if (diferenca == 1) return 'Amanhã';
    if (diferenca == -1) return 'Ontem';

    // Formatação da data em pt-BR
    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];

    final day = data.day.toString().padLeft(2, '0');
    final month = months[data.month - 1];
    final year = data.year;

    // Se for do mesmo ano, mostrar apenas dia/mês
    if (year == hoje.year) {
      return '$day/$month';
    } else {
      return '$day/$month/$year';
    }
  }

  void _showSpaceSelector() {
    Get.bottomSheet(
      DecoratedBox(
        decoration: BoxDecoration(
          color: PlantasColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PlantasColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Escolher espaço',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PlantasColors.textColor,
                ),
              ),
            ),

            // Lista de espaços predefinidos
            Flexible(
              child: Obx(() {
                if (controller.espacosDisponiveis.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          PlantasColors.primaryColor),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.espacosDisponiveis.length +
                      1, // +1 para opção personalizada
                  itemBuilder: (context, index) {
                    if (index == controller.espacosDisponiveis.length) {
                      // Opção de espaço personalizado
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: PlantasColors.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: PlantasColors.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: PlantasColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Espaço personalizado',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: PlantasColors.textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Digite o nome do local',
                            style: TextStyle(
                              color: PlantasColors.subtitleColor,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => _showCustomSpaceDialog(),
                        ),
                      );
                    }

                    final espaco = controller.espacosDisponiveis[index];
                    final isSelected =
                        controller.espacoSelecionado.value?.id == espaco.id;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PlantasColors.primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? PlantasColors.primaryColor
                              : PlantasColors.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PlantasColors.primaryColor
                                : PlantasColors.primaryColor
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getSpaceIcon(espaco.nome),
                            color: isSelected
                                ? Colors.white
                                : PlantasColors.primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          espaco.nome,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? PlantasColors.primaryColor
                                : PlantasColors.textColor,
                          ),
                        ),
                        subtitle: espaco.descricao != null
                            ? Text(
                                espaco.descricao!,
                                style: TextStyle(
                                  color: isSelected
                                      ? PlantasColors.primaryColor
                                          .withValues(alpha: 0.7)
                                      : PlantasColors.subtitleColor,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: PlantasColors.primaryColor,
                              )
                            : null,
                        onTap: () {
                          controller.selecionarEspaco(espaco);
                          Get.back();
                        },
                      ),
                    );
                  },
                );
              }),
            ),

            // Botão cancelar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: PlantasColors.subtitleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCustomSpaceDialog() {
    final TextEditingController customSpaceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.back(); // Fechar o bottom sheet anterior

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espaço personalizado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PlantasColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite o nome do local onde a planta ficará',
                  style: TextStyle(
                    fontSize: 14,
                    color: PlantasColors.subtitleColor,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: customSpaceController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Ex: Bancada da cozinha, Mesa do escritório...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PlantasColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: PlantasColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite o nome do espaço';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: PlantasColors.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.criarEspacoPersonalizado(
                                customSpaceController.text.trim());
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PlantasColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIntervalSelector(
      String titulo, RxInt intervalo, Function(int) onIntervaloChanged) {
    int selectedDays = intervalo.value;

    Get.bottomSheet(
      DecoratedBox(
        decoration: BoxDecoration(
          color: PlantasColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PlantasColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Intervalo para ${titulo.toLowerCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PlantasColors.textColor,
                ),
              ),
            ),

            // Seletor de dias tipo picker
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Texto "A cada"
                  Text(
                    'A cada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: PlantasColors.textColor,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Picker de dias centralizado
                  SizedBox(
                    width: 80,
                    child: ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: selectedDays - 1,
                      ),
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        selectedDays = index + 1;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index > 364) return null;
                          final days = index + 1;
                          return Center(
                            child: Text(
                              days.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: PlantasColors.textColor,
                              ),
                            ),
                          );
                        },
                        childCount: 365,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Label "dias"
                  Text(
                    'dias',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: PlantasColors.textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Texto explicativo (apenas para valores específicos)
            if (_shouldShowDescription(selectedDays))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _getIntervaloDescription(selectedDays),
                  style: TextStyle(
                    fontSize: 14,
                    color: PlantasColors.subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Botões
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: PlantasColors.subtitleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onIntervaloChanged(selectedDays);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlantasColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  bool _shouldShowDescription(int days) {
    // Mostrar descrição apenas para valores específicos conhecidos
    return days == 7 ||
        days == 14 ||
        days == 15 ||
        days == 21 ||
        days == 30 ||
        days == 60 ||
        days == 90 ||
        days == 120 ||
        days == 180 ||
        days == 365;
  }

  String _getIntervaloDescription(int days) {
    if (days == 7) {
      return 'Equivale a uma vez por semana';
    } else if (days == 14) {
      return 'Equivale a uma vez a cada 2 semanas';
    } else if (days == 15) {
      return 'Equivale a quinzenalmente';
    } else if (days == 21) {
      return 'Equivale a uma vez a cada 3 semanas';
    } else if (days == 30) {
      return 'Equivale a uma vez por mês';
    } else if (days == 60) {
      return 'Equivale a uma vez a cada 2 meses';
    } else if (days == 90) {
      return 'Equivale a uma vez a cada 3 meses';
    } else if (days == 120) {
      return 'Equivale a uma vez a cada 4 meses';
    } else if (days == 180) {
      return 'Equivale a uma vez a cada 6 meses';
    } else if (days == 365) {
      return 'Equivale a uma vez por ano';
    }
    return ''; // Não deveria chegar aqui devido ao _shouldShowDescription
  }

  void _showDateSelector(String titulo, Rx<DateTime?> proximaData,
      Function(DateTime) onDataChanged) {
    showDatePicker(
      context: Get.context!,
      initialDate: proximaData.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PlantasColors.primaryColor,
              onPrimary: Colors.white,
              surface: PlantasColors.surfaceColor,
              onSurface: PlantasColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        onDataChanged(selectedDate);
      }
    });
  }

  IconData _getSpaceIcon(String spaceName) {
    switch (spaceName.toLowerCase()) {
      case 'sala de estar':
        return Icons.weekend;
      case 'quarto':
        return Icons.bed;
      case 'cozinha':
        return Icons.kitchen;
      case 'varanda':
        return Icons.balcony;
      case 'jardim':
        return Icons.grass;
      case 'banheiro':
        return Icons.bathroom;
      case 'escritório':
        return Icons.work;
      case 'sala de jantar':
        return Icons.table_restaurant;
      default:
        return Icons.home;
    }
  }
}
