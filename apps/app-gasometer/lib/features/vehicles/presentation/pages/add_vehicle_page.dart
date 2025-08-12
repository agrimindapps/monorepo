import 'package:flutter/material.dart';

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
  
  String _selectedCombustivel = 'Flex';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _populateFields();
    }
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
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(isEditing),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isEditing),
                      const SizedBox(height: 32),
                      _buildIdentificationSection(),
                      const SizedBox(height: 24),
                      _buildTechnicalSection(),
                      const SizedBox(height: 24),
                      _buildDocumentationSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(isEditing),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEditing) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isEditing ? 'Editar Veículo' : 'Novo Veículo',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF5722),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFFFF5722),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editando Veículo' : 'Cadastrando Novo Veículo',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados do seu veículo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationSection() {
    return _buildSection(
      title: 'Identificação do Veículo',
      icon: Icons.directions_car,
      children: [
        _buildTextField(
          controller: _marcaController,
          label: 'Marca',
          hint: 'Ex: Honda, Toyota, Ford',
          textCapitalization: TextCapitalization.words,
          validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _modeloController,
          label: 'Modelo',
          hint: 'Ex: Civic, Corolla, Ka',
          textCapitalization: TextCapitalization.words,
          validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildYearDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _corController,
                label: 'Cor',
                hint: 'Ex: Branco, Preto',
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
    return _buildSection(
      title: 'Informações Técnicas',
      icon: Icons.settings,
      children: [
        _buildCombustivelSelector(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _odometroController,
          label: 'Odômetro Inicial (km)',
          hint: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixText: 'km',
          validator: (value) {
            if (value?.isEmpty == true) return 'Campo obrigatório';
            final number = double.tryParse(value!.replaceAll(',', '.'));
            if (number == null || number < 0) return 'Valor inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _placaController,
          label: 'Placa',
          hint: 'ABC-1234',
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          validator: (value) {
            if (value?.isEmpty == true) return 'Campo obrigatório';
            if (!RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$').hasMatch(value!.replaceAll('-', ''))) {
              return 'Formato inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentationSection() {
    return _buildSection(
      title: 'Documentação',
      icon: Icons.description,
      children: [
        _buildTextField(
          controller: _chassiController,
          label: 'Chassi',
          hint: '9BWZZZ377VT004251',
          textCapitalization: TextCapitalization.characters,
          maxLength: 17,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _renavamController,
          label: 'Renavam',
          hint: '12345678901',
          keyboardType: TextInputType.number,
          maxLength: 11,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF5722),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    final combustiveis = ['Gasolina', 'Etanol', 'Flex', 'Diesel'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Combustível',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: combustiveis.map((combustivel) {
            final isSelected = _selectedCombustivel == combustivel;
            return GestureDetector(
              onTap: () => setState(() => _selectedCombustivel = combustivel),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5722) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF5722) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCombustivelIcon(combustivel),
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      combustivel,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  IconData _getCombustivelIcon(String combustivel) {
    switch (combustivel) {
      case 'Gasolina':
        return Icons.local_gas_station;
      case 'Etanol':
        return Icons.eco;
      case 'Flex':
        return Icons.sync;
      case 'Diesel':
        return Icons.local_shipping;
      default:
        return Icons.local_gas_station;
    }
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5722),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isEditing ? 'Salvar Alterações' : 'Cadastrar Veículo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vehicle != null 
                  ? 'Veículo editado com sucesso' 
                  : 'Veículo cadastrado com sucesso',
            ),
            backgroundColor: Colors.green,
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