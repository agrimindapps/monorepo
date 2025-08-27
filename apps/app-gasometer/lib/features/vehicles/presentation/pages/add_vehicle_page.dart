import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/fuel_type_mapper.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_form_provider.dart';
import '../providers/vehicles_provider.dart';

class AddVehiclePage extends StatefulWidget {
  final VehicleEntity? vehicle;

  const AddVehiclePage({super.key, this.vehicle});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  late VehicleFormProvider formProvider;
  final Map<String, ValidationResult> _validationResults = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // Inicializar o form provider
    final authProvider = context.read<AuthProvider>();
    formProvider = VehicleFormProvider(authProvider);
    
    if (widget.vehicle != null) {
      formProvider.initializeForEdit(widget.vehicle!);
    }
    
    // Add listeners para atualizar contadores
    formProvider.placaController.addListener(_updateUI);
    formProvider.chassiController.addListener(_updateUI);
    formProvider.renavamController.addListener(_updateUI);
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  void dispose() {
    formProvider.placaController.removeListener(_updateUI);
    formProvider.chassiController.removeListener(_updateUI);
    formProvider.renavamController.removeListener(_updateUI);
    
    formProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: formProvider),
      ],
      child: Consumer<VehicleFormProvider>(builder: (context, formProvider, _) {
        return FormDialog(
          title: 'Veículos',
          subtitle: 'Gerencie seus veículos cadastrados',
          headerIcon: Icons.directions_car,
          isLoading: formProvider.isLoading,
          confirmButtonText: isEditing ? 'Salvar' : 'Salvar',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submitForm,
          content: Form(
            key: formProvider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(isEditing),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildIdentificationSection(),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildTechnicalSection(),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildDocumentationSection(),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildAdditionalInfoSection(),
          ],
        ),
      ),
        );
      }),
    );
  }

  Widget _buildFormTitle(bool isEditing) {
    return Center(
      child: Text(
        isEditing ? 'Editar Veículo' : 'Cadastrar Veículo',
        style: TextStyle(
          fontSize: GasometerDesignTokens.fontSizeXxl,
          fontWeight: GasometerDesignTokens.fontWeightBold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }


  Widget _buildIdentificationSection() {
    return FormSectionWidget(
      title: 'Identificação do Veículo',
      icon: Icons.directions_car,
      children: [
        ValidatedFormField(
          controller: formProvider.marcaController,
          label: 'Marca',
          hint: 'Ex: Ford, Volkswagen, etc.',
          required: true,
          validationType: ValidationType.length,
          minLength: 2,
          maxLengthValidation: 50,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]'))],
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['marca'] = result,
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        ValidatedFormField(
          controller: formProvider.modeloController,
          label: 'Modelo',
          hint: 'Ex: Gol, Fiesta, etc.',
          required: true,
          validationType: ValidationType.length,
          minLength: 2,
          maxLengthValidation: 50,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-]'))],
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['modelo'] = result,
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildYearDropdown(),
            ),
            SizedBox(width: GasometerDesignTokens.spacingMd),
            Expanded(
              child: ValidatedFormField(
                controller: formProvider.corController,
                label: 'Cor',
                hint: 'Ex: Branco, Preto, etc.',
                required: true,
                validationType: ValidationType.length,
                minLength: 3,
                maxLengthValidation: 30,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-]'))],
                validateOnChange: false,
                onValidationChanged: (result) => _validationResults['cor'] = result,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return FormSectionWidget(
      title: 'Informações Técnicas',
      icon: Icons.speed,
      children: [
        _buildCombustivelSelector(),
      ],
    );
  }

  Widget _buildDocumentationSection() {
    return FormSectionWidget(
      title: 'Documentação',
      icon: Icons.description,
      children: [
        ValidatedFormField(
          controller: formProvider.odometroController,
          label: 'Odômetro Atual',
          hint: '0,00',
          required: true,
          validationType: ValidationType.decimal,
          minValue: 0.0,
          maxValue: 999999.0,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          decoration: const InputDecoration(
            suffixText: 'km',
          ),
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['odometro'] = result,
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        ValidatedFormField(
          controller: formProvider.placaController,
          label: 'Placa',
          hint: 'Ex: ABC1234 ou ABC1D23',
          required: true,
          validationType: ValidationType.licensePlate,
          maxLength: 7,
          showCharacterCount: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            LengthLimitingTextInputFormatter(7),
          ],
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['placa'] = result,
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        ValidatedFormField(
          controller: formProvider.chassiController,
          label: 'Chassi (opcional)',
          hint: 'Ex: 9BWZZZ377VT004251',
          required: false,
          validationType: ValidationType.chassis,
          maxLength: 17,
          showCharacterCount: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-HJ-NPR-Z0-9]')),
            LengthLimitingTextInputFormatter(17),
            UpperCaseTextFormatter(),
          ],
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['chassi'] = result,
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        ValidatedFormField(
          controller: formProvider.renavamController,
          label: 'Renavam (opcional)',
          hint: 'Ex: 12345678901',
          required: false,
          validationType: ValidationType.renavam,
          keyboardType: TextInputType.number,
          maxLength: 11,
          showCharacterCount: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validateOnChange: false,
          onValidationChanged: (result) => _validationResults['renavam'] = result,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      children: [
        _buildPhotoUploadSection(),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    final hasPhoto = formProvider.vehicleImage != null && formProvider.vehicleImage!.existsSync();

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
        SizedBox(height: GasometerDesignTokens.spacingMd),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusLg),
          ),
          child: Column(
            children: [
              if (hasPhoto) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(GasometerDesignTokens.radiusLg),
                      ),
                      child: _buildOptimizedImage(
                        formProvider.vehicleImage!,
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
                          onPressed: () => formProvider.removeVehicleImage(),
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
                  padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
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
                  padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXxxl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: GasometerDesignTokens.iconSizeXxxl + 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: GasometerDesignTokens.opacityHint,
                        ),
                      ),
                      SizedBox(height: GasometerDesignTokens.spacingLg),
                      Text(
                        'Nenhuma foto selecionada',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: GasometerDesignTokens.opacitySecondary,
                          ),
                          fontSize: GasometerDesignTokens.fontSizeLg,
                        ),
                      ),
                      SizedBox(height: GasometerDesignTokens.spacingLg),
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Adicionar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar imagem',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  /// Método otimizado para carregamento de imagens com cache e shimmer loading
  Widget _buildOptimizedImage(
    File imageFile, {
    required double height,
    required double width,
    required BoxFit fit,
  }) {
    // Para imagens locais (File), usar Image.file otimizado com memory cache
    return Image.file(
      imageFile,
      height: height,
      width: width,
      fit: fit,
      // Otimizações de memória
      cacheHeight: height.toInt(),
      cacheWidth: width.toInt(),
      // Frame builder para adicionar shimmer loading effect
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        
        // Shimmer loading enquanto a imagem carrega
        return _buildShimmerPlaceholder(height, width);
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  /// Widget de shimmer placeholder para loading states
  Widget _buildShimmerPlaceholder(double height, double width) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GasometerDesignTokens.radiusLg),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                alpha: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Carregando...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                fontSize: 14,
              ),
            ),
          ],
        ),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text('Galeria'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 8),
                  Text('Câmera'),
                ],
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
        formProvider.updateVehicleImage(File(image.path));
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


  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1900 + 1, (index) => currentYear - index);
    
    return DropdownButtonFormField<int>(
      value: formProvider.anoController.text.isNotEmpty ? int.tryParse(formProvider.anoController.text) : null,
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) => value == null ? 'Campo obrigatório' : null,
      items: years.map((year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (value) {
        formProvider.anoController.text = value?.toString() ?? '';
        formProvider.markAsChanged();
      },
    );
  }

  Widget _buildCombustivelSelector() {
    // Usar FuelTypeMapper para gerar lista de combustíveis dinamicamente
    final combustiveis = FuelTypeMapper.availableFuelStrings.map((fuelName) {
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
        SizedBox(height: GasometerDesignTokens.spacingMd),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: combustiveis.map((combustivel) {
            final isSelected = formProvider.selectedCombustivel == combustivel['name'];
            return GestureDetector(
              onTap: () => formProvider.updateSelectedCombustivel(combustivel['name'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      combustivel['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      combustivel['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



  Future<void> _submitForm() async {
    // Validar usando o FormProvider
    if (!formProvider.validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formProvider.lastError ?? 'Por favor, corrija os erros no formulário'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    formProvider.setLoading(true);

    try {
      final vehiclesProvider = context.read<VehiclesProvider>();
      
      // Criar entidade do veículo usando o FormProvider
      final vehicleEntity = formProvider.createVehicleEntity();
      
      // Salvar via provider
      bool success;
      if (widget.vehicle != null) {
        success = await vehiclesProvider.updateVehicle(vehicleEntity);
      } else {
        success = await vehiclesProvider.addVehicle(vehicleEntity);
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.vehicle != null 
                  ? 'Veículo atualizado com sucesso!' 
                  : 'Veículo cadastrado com sucesso!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop(true); // Retorna true para indicar sucesso
        } else {
          // Se falhou, mostrar o erro do provider se disponível
          final errorMessage = vehiclesProvider.errorMessage ?? 'Erro desconhecido ao salvar veículo';
          formProvider.setError('Erro ao salvar veículo: $errorMessage');
        }
      }
    } catch (e) {
      if (mounted) {
        formProvider.setError('Erro ao salvar veículo: $e');
      }
    } finally {
      if (mounted) {
        formProvider.setLoading(false);
      }
    }
  }
}