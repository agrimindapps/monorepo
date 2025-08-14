import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';

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
    _marcaController.text = vehicle['marca'] ?? '';
    _modeloController.text = vehicle['modelo'] ?? '';
    _anoController.text = vehicle['ano']?.toString() ?? '';
    _corController.text = vehicle['cor'] ?? '';
    _placaController.text = vehicle['placa'] ?? '';
    _chassiController.text = vehicle['chassi'] ?? '';
    _renavamController.text = vehicle['renavam'] ?? '';
    _odometroController.text = vehicle['odometroInicial']?.toString() ?? '';
    _selectedCombustivel = vehicle['combustivel'] ?? 'Flex';
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
            const SizedBox(height: 24),
            _buildIdentificationSection(),
            const SizedBox(height: 24),
            _buildTechnicalSection(),
            const SizedBox(height: 24),
            _buildDocumentationSection(),
            const SizedBox(height: 24),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
        _buildTextField(
          controller: _marcaController,
          label: 'Marca',
          hint: 'Ex: Ford, Volkswagen, etc.',
          textCapitalization: TextCapitalization.words,
          validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _modeloController,
          label: 'Modelo',
          hint: 'Ex: Gol, Fiesta, etc.',
          textCapitalization: TextCapitalization.words,
          validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildYearDropdown(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _corController,
                label: 'Cor',
                hint: 'Ex: Branco, Preto, etc.',
                textCapitalization: TextCapitalization.words,
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
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
        _buildTextField(
          controller: _odometroController,
          label: 'Odômetro Atual',
          hint: '0,00',
          suffixText: 'km',
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _getOdometroFormatters(),
          validator: _validateOdometro,
          onChanged: (value) {
            // Atualiza o estado para mostrar o contador
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _placaController,
          label: 'Placa',
          hint: 'Ex: ABC1234 ou ABC1D23',
          textCapitalization: TextCapitalization.characters,
          maxLength: 7,
          showCounter: true,
          inputFormatters: _getPlacaFormatters(),
          validator: _validatePlaca,
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _chassiController,
          label: 'Chassi',
          hint: 'Ex: 9BWZZZ377VT004251',
          textCapitalization: TextCapitalization.characters,
          maxLength: 17,
          showCounter: true,
          inputFormatters: _getChassiFormatters(),
          validator: _validateChassi,
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _renavamController,
          label: 'Renavam',
          hint: 'Ex: 12345678901',
          keyboardType: TextInputType.number,
          maxLength: 11,
          showCounter: true,
          inputFormatters: _getRenavamFormatters(),
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' (opcional)',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (hasPhoto) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
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
                        radius: 16,
                        child: IconButton(
                          onPressed: _removePhoto,
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onError,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma foto selecionada',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Adicionar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
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
    showDialog(
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


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    int? maxLength,
    String? suffixText,
    String? Function(String?)? validator,
    bool showCounter = false,
    TextAlign? textAlign,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          maxLength: showCounter ? null : maxLength,
          textAlign: textAlign ?? TextAlign.start,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixText: suffixText,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
          ),
        ),
        if (showCounter && maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.text.length}/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 1980 + 1, (index) => currentYear - index);
    
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
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



  // Formatadores de entrada
  List<TextInputFormatter> _getPlacaFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
      LengthLimitingTextInputFormatter(7),
    ];
  }

  List<TextInputFormatter> _getChassiFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[A-HJ-NPR-Z0-9]')),
      LengthLimitingTextInputFormatter(17),
    ];
  }

  List<TextInputFormatter> _getRenavamFormatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(11),
    ];
  }

  List<TextInputFormatter> _getOdometroFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        var text = newValue.text.replaceAll('.', ',');
        if (text.contains(',')) {
          final parts = text.split(',');
          if (parts.length == 2 && parts[1].length > 2) {
            text = '${parts[0]},${parts[1].substring(0, 2)}';
          }
        }
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }),
    ];
  }

  // Validadores
  String? _validatePlaca(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    // Placa Mercosul: ABC1D23
    final mercosulRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
    // Placa antiga: ABC1234
    final antigaRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    
    if (!mercosulRegex.hasMatch(cleanValue) && !antigaRegex.hasMatch(cleanValue)) {
      return 'Formato inválido. Use ABC1234 ou ABC1D23';
    }
    
    return null;
  }

  String? _validateChassi(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }

    final cleanValue = value.replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');
    
    if (cleanValue.length != 17) {
      return 'Chassi deve ter 17 caracteres';
    }
    
    // Chassi não pode conter I, O, Q
    if (RegExp(r'[IOQ]').hasMatch(cleanValue)) {
      return 'Chassi inválido';
    }
    
    return null;
  }

  String? _validateOdometro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);
    
    if (number == null || number < 0) {
      return 'Valor inválido';
    }
    
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulação de salvamento
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pop({
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'ano': int.tryParse(_anoController.text),
          'cor': _corController.text,
          'placa': _placaController.text,
          'chassi': _chassiController.text,
          'renavam': _renavamController.text,
          'odometroInicial': double.tryParse(_odometroController.text.replaceAll(',', '.')) ?? 0.0,
          'combustivel': _selectedCombustivel,
          'foto': _vehicleImage?.path,
        });
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