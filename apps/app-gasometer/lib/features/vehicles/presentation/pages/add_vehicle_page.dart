import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicles_provider.dart';

class AddVehiclePage extends StatefulWidget {
  final Map<String, dynamic>? vehicle;

  const AddVehiclePage({super.key, this.vehicle});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _corController = TextEditingController();
  final _placaController = TextEditingController();
  final _chassiController = TextEditingController();
  final _renavamController = TextEditingController();
  final _odometroController = TextEditingController();
  
  final Map<String, ValidationResult> _validationResults = {};
  
  String _selectedCombustivel = 'Gasolina';
  bool _isLoading = false;
  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    if (widget.vehicle != null) {
      _populateFields();
    }
    
    // Add listeners para atualizar contadores
    _placaController.addListener(_updateUI);
    _chassiController.addListener(_updateUI);
    _renavamController.addListener(_updateUI);
  }

  void _updateUI() {
    setState(() {});
  }

  void _populateFields() {
    final vehicle = widget.vehicle!;
    _marcaController.text = vehicle['marca'] as String? ?? '';
    _modeloController.text = vehicle['modelo'] as String? ?? '';
    _anoController.text = vehicle['ano']?.toString() ?? '';
    _corController.text = vehicle['cor'] as String? ?? '';
    _placaController.text = vehicle['placa'] as String? ?? '';
    _chassiController.text = vehicle['chassi'] as String? ?? '';
    _renavamController.text = vehicle['renavam'] as String? ?? '';
    _odometroController.text = vehicle['odometroInicial']?.toString() ?? '';
    _selectedCombustivel = vehicle['combustivel'] as String? ?? 'Flex';
  }

  @override
  void dispose() {
    _placaController.removeListener(_updateUI);
    _chassiController.removeListener(_updateUI);
    _renavamController.removeListener(_updateUI);
    
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _corController.dispose();
    _placaController.dispose();
    _chassiController.dispose();
    _renavamController.dispose();
    _odometroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    
    return FormDialog(
      title: 'Veículos',
      subtitle: 'Gerencie seus veículos cadastrados',
      headerIcon: Icons.directions_car,
      isLoading: _isLoading,
      confirmButtonText: isEditing ? 'Salvar' : 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitForm,
      content: Form(
        key: _formKey,
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
          controller: _marcaController,
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
          controller: _modeloController,
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
                controller: _corController,
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
          controller: _odometroController,
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
          controller: _placaController,
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
          controller: _chassiController,
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
          controller: _renavamController,
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
    final hasPhoto = _vehicleImage != null && _vehicleImage!.existsSync();

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
                      child: Image.file(
                        _vehicleImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          _buildErrorWidget(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        radius: GasometerDesignTokens.spacingLg,
                        child: IconButton(
                          onPressed: _removePhoto,
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

  void _removePhoto() {
    try {
      if (_vehicleImage != null && _vehicleImage!.existsSync()) {
        _vehicleImage!.deleteSync();
      }
    } catch (e) {
      // Ignora erros de limpeza
    }

    setState(() {
      _vehicleImage = null;
    });
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
        setState(() {
          _vehicleImage = File(image.path);
        });
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
      value: _anoController.text.isNotEmpty ? int.tryParse(_anoController.text) : null,
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
        setState(() {
          _anoController.text = value?.toString() ?? '';
        });
      },
    );
  }

  Widget _buildCombustivelSelector() {
    final combustiveis = [
      {'name': 'Gasolina', 'icon': Icons.local_gas_station},
      {'name': 'Etanol', 'icon': Icons.eco},
      {'name': 'Diesel', 'icon': Icons.local_shipping},
      {'name': 'Diesel S-10', 'icon': Icons.local_gas_station},
      {'name': 'GNV', 'icon': Icons.circle},
      {'name': 'Energia Elétrica', 'icon': Icons.electric_car},
    ];
    
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
            final isSelected = _selectedCombustivel == combustivel['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCombustivel = combustivel['name'] as String),
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


  // Sanitização de entrada para prevenir XSS
  String _sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\\&%$#@!*()[\]{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _submitForm() async {
    // Validar todos os campos manualmente antes de submeter
    setState(() {
      // Limpa resultados anteriores
      _validationResults.clear();
    });
    
    // Valida o form usando o GlobalKey
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, corrija os erros no formulário'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
      
      // Mapear combustível string para FuelType
      final fuelTypeMap = {
        'Gasolina': FuelType.gasoline,
        'Etanol': FuelType.ethanol,
        'Diesel': FuelType.diesel,
        'Diesel S-10': FuelType.diesel,
        'GNV': FuelType.gas,
        'Energia Elétrica': FuelType.electric,
      };
      
      final fuelType = fuelTypeMap[_selectedCombustivel] ?? FuelType.gasoline;
      final odometroValue = double.tryParse(_odometroController.text.replaceAll(',', '.')) ?? 0.0;
      
      // Criar entidade do veículo
      final vehicleEntity = VehicleEntity(
        id: widget.vehicle?['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: context.read<AuthProvider>().userId,
        name: '${_sanitizeInput(_marcaController.text)} ${_sanitizeInput(_modeloController.text)}',
        brand: _sanitizeInput(_marcaController.text),
        model: _sanitizeInput(_modeloController.text),
        year: int.tryParse(_anoController.text) ?? DateTime.now().year,
        color: _sanitizeInput(_corController.text),
        licensePlate: _sanitizeInput(_placaController.text),
        type: VehicleType.car, // Padrão para carro
        supportedFuels: [fuelType],
        currentOdometer: odometroValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'chassi': _sanitizeInput(_chassiController.text),
          'renavam': _sanitizeInput(_renavamController.text),
          'foto': _vehicleImage?.path,
          'odometroInicial': odometroValue,
        },
      );
      
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar veículo: $errorMessage'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar veículo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}