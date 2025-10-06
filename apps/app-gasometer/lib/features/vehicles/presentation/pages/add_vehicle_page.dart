import 'dart:io';

import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/validation/form_validator.dart';
import '../../../../core/widgets/error_header.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/validated_form_field.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../domain/entities/fuel_type_mapper.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_form_notifier.dart';
import '../providers/vehicles_notifier.dart';

class AddVehiclePage extends ConsumerStatefulWidget {
  const AddVehiclePage({super.key, this.vehicle});
  final VehicleEntity? vehicle;

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage>
    with FormErrorHandlerMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _observacoesController = TextEditingController();
  late final FormValidator _formValidator;
  final Map<String, GlobalKey> _fieldKeys = {};
  bool _isInitialized = false;

  void _initializeFormNotifier() {
    if (_isInitialized) return; // Já inicializado

    final notifier = ref.read(vehicleFormNotifierProvider.notifier);

    if (widget.vehicle != null) {
      notifier.initializeForEdit(widget.vehicle!);
      _observacoesController.text =
          widget.vehicle!.metadata['observacoes'] as String? ?? '';
    }
    _initializeFormValidator();
    _isInitialized = true;
  }

  void _initializeFormValidator() {
    _formValidator = FormValidator();
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    _fieldKeys['marca'] = GlobalKey();
    _fieldKeys['modelo'] = GlobalKey();
    _fieldKeys['ano'] = GlobalKey();
    _fieldKeys['cor'] = GlobalKey();
    _fieldKeys['odometro'] = GlobalKey();
    _fieldKeys['placa'] = GlobalKey();
    _fieldKeys['chassi'] = GlobalKey();
    _fieldKeys['renavam'] = GlobalKey();
    _fieldKeys['observacoes'] = GlobalKey();
    _formValidator.addFields([
      FormFieldConfig(
        fieldId: 'marca',
        controller: notifier.brandController,
        validationType: ValidationType.length,
        required: true,
        minLength: 2,
        maxLength: 50,
        label: 'Marca',
        scrollKey: _fieldKeys['marca'],
      ),
      FormFieldConfig(
        fieldId: 'modelo',
        controller: notifier.modelController,
        validationType: ValidationType.length,
        required: true,
        minLength: 2,
        maxLength: 50,
        label: 'Modelo',
        scrollKey: _fieldKeys['modelo'],
      ),
      FormFieldConfig(
        fieldId: 'ano',
        controller: notifier.yearController,
        validationType: ValidationType.required,
        required: true,
        label: 'Ano',
        scrollKey: _fieldKeys['ano'],
      ),
      FormFieldConfig(
        fieldId: 'cor',
        controller: notifier.colorController,
        validationType: ValidationType.length,
        required: true,
        minLength: 3,
        maxLength: 30,
        label: 'Cor',
        scrollKey: _fieldKeys['cor'],
      ),
      FormFieldConfig(
        fieldId: 'odometro',
        controller: notifier.odometerController,
        validationType: ValidationType.decimal,
        required: true,
        minValue: 0.0,
        maxValue: 999999.0,
        label: 'Odômetro Atual',
        scrollKey: _fieldKeys['odometro'],
      ),
      FormFieldConfig(
        fieldId: 'placa',
        controller: notifier.plateController,
        validationType: ValidationType.licensePlate,
        required: true,
        label: 'Placa',
        scrollKey: _fieldKeys['placa'],
      ),
      FormFieldConfig(
        fieldId: 'chassi',
        controller: notifier.chassisController,
        validationType: ValidationType.chassis,
        required: false,
        label: 'Chassi',
        scrollKey: _fieldKeys['chassi'],
      ),
      FormFieldConfig(
        fieldId: 'renavam',
        controller: notifier.renavamController,
        validationType: ValidationType.renavam,
        required: false,
        label: 'Renavam',
        scrollKey: _fieldKeys['renavam'],
      ),
      FormFieldConfig(
        fieldId: 'observacoes',
        controller: _observacoesController,
        validationType: ValidationType.length,
        required: false,
        minLength: 0,
        maxLength: 1000,
        label: 'Observações',
        scrollKey: _fieldKeys['observacoes'],
      ),
    ]);
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _formValidator.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    final authState = ref.watch(authProvider);
    final formState = ref.watch(vehicleFormNotifierProvider);
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    if (authState.status == AuthStatus.authenticating ||
        !authState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _initializeFormNotifier();

    return FormDialog(
      title: 'Veículos',
      subtitle: 'Gerencie seus veículos cadastrados',
      headerIcon: Icons.directions_car,
      isLoading: formState.isLoading,
      confirmButtonText: isEditing ? 'Salvar' : 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitForm,
      content: Form(
        key: notifier.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFormErrorHeader(),
            if (formErrorMessage != null)
              const SizedBox(height: GasometerDesignTokens.spacingMd),
            _buildIdentificationSection(),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildTechnicalSection(),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildDocumentationSection(),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildAdditionalInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentificationSection() {
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    return FormSectionHeader(
      title: 'Identificação do Veículo',
      icon: Icons.directions_car,
      child: Column(
        children: [
          _buildPhotoUploadSection(),
          const SizedBox(height: GasometerDesignTokens.spacingLg),
          Container(
            key: _fieldKeys['marca'],
            child: ValidatedFormField(
              controller: notifier.brandController,
              label: 'Marca',
              hint: 'Ex: Ford, Volkswagen, etc.',
              required: true,
              validationType: ValidationType.length,
              minLength: 2,
              maxLengthValidation: 50,
              validateOnChange: false, // Desabilitar validação em tempo real
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]')),
              ],
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: _fieldKeys['modelo'],
            child: ValidatedFormField(
              controller: notifier.modelController,
              label: 'Modelo',
              hint: 'Ex: Gol, Fiesta, etc.',
              required: true,
              validationType: ValidationType.length,
              minLength: 2,
              maxLengthValidation: 50,
              validateOnChange: false, // Desabilitar validação em tempo real
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-]'),
                ),
              ],
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: Container(
                  key: _fieldKeys['ano'],
                  child: _buildYearDropdown(notifier),
                ),
              ),
              const SizedBox(width: GasometerDesignTokens.spacingMd),
              Expanded(
                child: Container(
                  key: _fieldKeys['cor'],
                  child: ValidatedFormField(
                    controller: notifier.colorController,
                    label: 'Cor',
                    hint: 'Ex: Branco, Preto, etc.',
                    required: true,
                    validationType: ValidationType.length,
                    minLength: 3,
                    maxLengthValidation: 30,
                    validateOnChange:
                        false, // Desabilitar validação em tempo real
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZÀ-ÿ\s\-]'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSection() {
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    return FormSectionHeader(
      title: 'Informações Técnicas',
      icon: Icons.speed,
      child: Column(children: [_buildCombustivelSelector(notifier)]),
    );
  }

  Widget _buildDocumentationSection() {
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    return FormSectionHeader(
      title: 'Documentação',
      icon: Icons.description,
      child: Column(
        children: [
          Container(
            key: _fieldKeys['odometro'],
            child: ValidatedFormField(
              controller: notifier.odometerController,
              label: 'Odômetro Atual',
              hint: '0,00',
              required: true,
              validationType: ValidationType.decimal,
              minValue: 0.0,
              maxValue: 999999.0,
              validateOnChange: false, // Desabilitar validação em tempo real
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              suffix: const Text(
                'km',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(
                  () {},
                ); // Manter para cálculos em tempo real se necessário
              },
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: _fieldKeys['placa'],
            child: ValidatedFormField(
              controller: notifier.plateController,
              label: 'Placa',
              hint: 'Ex: ABC1234 ou ABC1D23',
              required: true,
              validationType: ValidationType.licensePlate,
              maxLength: 7,
              validateOnChange: false, // Desabilitar validação em tempo real
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: (value) {
                setState(() {}); // Manter para formatação em tempo real
              },
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: _fieldKeys['chassi'],
            child: ValidatedFormField(
              controller: notifier.chassisController,
              label: 'Chassi (opcional)',
              hint: 'Ex: 9BWZZZ377VT004251',
              required: false,
              validationType: ValidationType.chassis,
              maxLength: 17,
              validateOnChange: false, // Desabilitar validação em tempo real
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-HJ-NPR-Z0-9]')),
                LengthLimitingTextInputFormatter(17),
                UpperCaseTextFormatter(),
              ],
              onChanged: (value) {
                setState(() {}); // Manter para formatação em tempo real
              },
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Container(
            key: _fieldKeys['renavam'],
            child: ValidatedFormField(
              controller: notifier.renavamController,
              label: 'Renavam (opcional)',
              hint: 'Ex: 12345678901',
              required: false,
              validationType: ValidationType.renavam,
              keyboardType: TextInputType.number,
              maxLength: 11,
              validateOnChange: false, // Desabilitar validação em tempo real
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              onChanged: (value) {
                setState(() {}); // Manter para formatação em tempo real
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionHeader(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      child: Column(
        children: [
          Container(
            key: _fieldKeys['observacoes'],
            child: ObservationsField(
              controller: _observacoesController,
              label: 'Observações',
              hint: 'Adicione observações sobre o veículo...',
              required: false,
              onChanged: (value) {
                setState(
                  () {},
                ); // Manter para contador de caracteres se necessário
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    final formState = ref.watch(vehicleFormNotifierProvider);
    final hasPhoto =
        formState.vehicleImage != null && formState.vehicleImage!.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Foto do Veículo',
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeLg,
                fontWeight: GasometerDesignTokens.fontWeightMedium,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' (opcional)',
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeMd,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: GasometerDesignTokens.opacitySecondary,
                ),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: GasometerDesignTokens.spacingMd),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusLg,
            ),
          ),
          child: Column(
            children: [
              if (hasPhoto) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(GasometerDesignTokens.radiusLg),
                      ),
                      child: _buildOptimizedImage(
                        formState.vehicleImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        radius: GasometerDesignTokens.spacingLg,
                        child: IconButton(
                          onPressed: () => notifier.removeVehicleImage(),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onError,
                            size: GasometerDesignTokens.iconSizeXs,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Padding(
                  padding: GasometerDesignTokens.paddingAll(
                    GasometerDesignTokens.spacingMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Alterar Foto'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: GasometerDesignTokens.paddingAll(
                    GasometerDesignTokens.spacingXxxl,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: GasometerDesignTokens.iconSizeXxxl + 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(
                          alpha: GasometerDesignTokens.opacityHint,
                        ),
                      ),
                      const SizedBox(height: GasometerDesignTokens.spacingLg),
                      Text(
                        'Nenhuma foto selecionada',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(
                            alpha: GasometerDesignTokens.opacitySecondary,
                          ),
                          fontSize: GasometerDesignTokens.fontSizeLg,
                        ),
                      ),
                      const SizedBox(height: GasometerDesignTokens.spacingLg),
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Adicionar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: GasometerDesignTokens.paddingOnly(
                            left: GasometerDesignTokens.spacingXxl,
                            right: GasometerDesignTokens.spacingXxl,
                            top: GasometerDesignTokens.spacingMd,
                            bottom: GasometerDesignTokens.spacingMd,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingSm),
          Text(
            'Erro ao carregar imagem',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedImage(
    File imageFile, {
    required double height,
    required double width,
    required BoxFit fit,
  }) {
    return Image.file(
      imageFile,
      height: height,
      width: width,
      fit: fit,
      cacheHeight: height.toInt(),
      cacheWidth: width.toInt(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildShimmerPlaceholder(height, width);
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  /// Widget de shimmer placeholder para loading states
  Widget _buildShimmerPlaceholder(double height, double width) {
    return core.ShimmerService.imageShimmer(
      context: context,
      width: width,
      height: height,
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(GasometerDesignTokens.radiusLg),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Foto do Veículo'),
          content: const Text('Escolha uma opção:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('Galeria'),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Câmera'),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    await _pickImageFromSource(ImageSource.gallery);
  }

  Future<void> _takePhoto() async {
    await _pickImageFromSource(ImageSource.camera);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        final notifier = ref.read(vehicleFormNotifierProvider.notifier);
        notifier.updateVehicleImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildYearDropdown(dynamic notifier) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1900 + 1,
      (index) => currentYear - index,
    );
    final yearText = notifier.yearController.text as String;
    final currentValue =
        yearText.trim().isNotEmpty ? int.tryParse(yearText) : null;

    return DropdownButtonFormField<int>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: 'Ano',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) => value == null ? 'Campo obrigatório' : null,
      items:
          years.map((year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            );
          }).toList(),
      onChanged: (value) {
        notifier.yearController.text = value?.toString() ?? '';
        notifier.markAsChanged();
      },
    );
  }

  Widget _buildCombustivelSelector(dynamic notifier) {
    final formState = ref.watch(vehicleFormNotifierProvider);
    final combustiveis =
        FuelTypeMapper.availableFuelStrings.map((fuelName) {
          IconData icon;
          switch (fuelName) {
            case 'Gasolina':
              icon = Icons.local_gas_station;
              break;
            case 'Etanol':
              icon = Icons.eco;
              break;
            case 'Diesel':
              icon = Icons.local_shipping;
              break;
            case 'Diesel S-10':
              icon = Icons.local_gas_station;
              break;
            case 'GNV':
            case 'Gás':
              icon = Icons.circle;
              break;
            case 'Energia Elétrica':
            case 'Elétrico':
              icon = Icons.electric_car;
              break;
            case 'Híbrido':
              icon = Icons.ev_station;
              break;
            default:
              icon = Icons.local_gas_station;
          }
          return {'name': fuelName, 'icon': icon};
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Combustível',
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeMd,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: GasometerDesignTokens.spacingMd),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              combustiveis.map((combustivel) {
                final isSelected =
                    formState.selectedFuel == combustivel['name'];
                return GestureDetector(
                  onTap:
                      () => notifier.updateSelectedFuel(
                        combustivel['name'] as String,
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            combustivel['icon'] as IconData,
                            size: 14,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            combustivel['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final notifier = ref.read(vehicleFormNotifierProvider.notifier);
    final formState = ref.read(vehicleFormNotifierProvider);
    clearFormError();
    final validationResult = await _formValidator.validateAll();
    if (formState.selectedFuel.isEmpty) {
      setFormError('Selecione o tipo de combustível');
      return;
    }
    if (!validationResult.isValid) {
      setFormError(validationResult.message);
      await _formValidator.scrollToFirstError();
      return;
    }

    notifier.setLoading(true);

    try {
      if (!mounted) return;
      final vehiclesNotifier = ref.read(vehiclesNotifierProvider.notifier);
      final vehicleEntity = notifier.createVehicleEntity();
      final updatedMetadata = Map<String, dynamic>.from(vehicleEntity.metadata);
      updatedMetadata['observacoes'] = _observacoesController.text.trim();

      final updatedVehicleEntity = VehicleEntity(
        id: vehicleEntity.id,
        userId: vehicleEntity.userId,
        name: vehicleEntity.name,
        brand: vehicleEntity.brand,
        model: vehicleEntity.model,
        year: vehicleEntity.year,
        color: vehicleEntity.color,
        licensePlate: vehicleEntity.licensePlate,
        type: vehicleEntity.type,
        supportedFuels: vehicleEntity.supportedFuels,
        currentOdometer: vehicleEntity.currentOdometer,
        createdAt: vehicleEntity.createdAt,
        updatedAt: vehicleEntity.updatedAt,
        metadata: updatedMetadata,
      );
      if (widget.vehicle != null) {
        await vehiclesNotifier.updateVehicle(updatedVehicleEntity);
      } else {
        await vehiclesNotifier.addVehicle(updatedVehicleEntity);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setFormError('Erro ao salvar veículo: $e');
      }
    } finally {
      if (mounted) {
        notifier.setLoading(false);
      }
    }
  }
}
