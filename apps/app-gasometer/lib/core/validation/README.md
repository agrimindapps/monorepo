# SOLID Form Architecture

Uma arquitetura robusta e escalável para formulários Flutter seguindo os princípios SOLID.

## 🏗️ Visão Geral da Arquitetura

A nova arquitetura de formulários foi projetada seguindo os princípios SOLID:

- **S**ingle Responsibility Principle: Cada classe tem uma responsabilidade específica
- **O**pen/Closed Principle: Aberto para extensão, fechado para modificação
- **L**iskov Substitution Principle: Componentes podem ser substituídos por suas implementações
- **I**nterface Segregation Principle: Interfaces pequenas e específicas
- **D**ependency Inversion Principle: Depende de abstrações, não de implementações

## 📁 Estrutura de Diretórios

```
lib/core/presentation/forms/
├── architecture/           # Interfaces e abstrações core
│   ├── i_form_builder.dart
│   ├── i_form_validator.dart
│   ├── i_form_state_manager.dart
│   └── i_field_factory.dart
├── config/                 # Configurações de formulários e campos
│   ├── form_config.dart
│   ├── field_config.dart
│   └── validation_config.dart
├── state/                  # Gerenciamento de estado
│   ├── form_state.dart
│   └── form_state_manager.dart
├── validation/            # Sistema de validação
│   ├── validation_result.dart
│   └── validators/
│       ├── base_validator.dart
│       ├── required_validator.dart
│       ├── length_validator.dart
│       └── email_validator.dart
├── fields/                # Sistema de campos
│   ├── base_form_field.dart
│   └── field_factory.dart
├── examples/              # Exemplos de uso
│   └── vehicle_form_example.dart
└── forms.dart            # Export barrel
```

## 🚀 Como Usar

### 1. Definir o Modelo de Dados

```dart
class VehicleData {
  final String name;
  final String plate;
  final String brand;
  
  const VehicleData({
    required this.name,
    required this.plate,
    required this.brand,
  });
  
  // copyWith, toJson, fromJson methods...
}
```

### 2. Criar Configuração do Formulário

```dart
class VehicleFormConfig extends FormConfig<VehicleData> {
  @override
  String get formId => 'vehicle_form';
  
  @override
  String get title => 'Veículo';
  
  @override
  List<FieldConfig> buildFields() {
    return [
      TextFieldConfigBuilder()
          .key('name')
          .label('Nome do Veículo')
          .required()
          .maxLength(50)
          .build(),
      
      TextFieldConfigBuilder()
          .key('plate')
          .label('Placa')
          .required()
          .validationPattern(r'^[A-Z]{3}-\d{4}$')
          .build(),
      
      DropdownFieldConfigBuilder()
          .key('brand')
          .label('Marca')
          .required()
          .option('toyota', 'Toyota')
          .option('honda', 'Honda')
          .build(),
    ];
  }
  
  @override
  Future<FormSubmissionResult<VehicleData>> submitForm(VehicleData data) async {
    // Implementar lógica de submissão
    return FormSubmissionResult.success(data);
  }
}
```

### 3. Configurar Validação

```dart
final validationConfig = ValidationConfig()
    .addRule('name', RequiredValidator())
    .addRule('name', LengthValidator.range(2, 50))
    .addRule('plate', RequiredValidator())
    .addRule('plate', _PlateValidator())
    .addCrossFieldRule(CrossFieldRules.conditionalRequired(
      targetField: 'year',
      conditionField: 'brand',
      conditionValue: 'luxury',
    ));
```

### 4. Criar o Widget do Formulário

```dart
class VehicleFormWidget extends StatefulWidget {
  @override
  State<VehicleFormWidget> createState() => _VehicleFormWidgetState();
}

class _VehicleFormWidgetState extends State<VehicleFormWidget> {
  late final FormStateManager<VehicleData> _stateManager;
  late final VehicleFormConfig _formConfig;
  late final IFieldFactory _fieldFactory;
  
  @override
  void initState() {
    super.initState();
    
    _formConfig = VehicleFormConfig();
    _fieldFactory = MaterialFieldFactory();
    
    _stateManager = FormStateManagerBuilder<VehicleData>()
        .withValidationDebounce(const Duration(milliseconds: 300))
        .withAutoSave(
          interval: const Duration(seconds: 30),
          onSave: _autoSave,
        )
        .buildProvider();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FormState<VehicleData>>(
      stream: _stateManager.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _stateManager.currentState;
        
        return Column(
          children: _buildFormFields(state),
        );
      },
    );
  }
  
  List<Widget> _buildFormFields(FormState<VehicleData> state) {
    return _formConfig.buildFields().map((fieldConfig) {
      switch (fieldConfig.fieldType) {
        case 'text':
          return _fieldFactory.createTextField(fieldConfig as TextFieldConfig);
        case 'dropdown':
          return _fieldFactory.createDropdownField(fieldConfig as DropdownFieldConfig);
        // ... outros tipos
        default:
          return const SizedBox.shrink();
      }
    }).toList();
  }
}
```

## 🔧 Recursos Principais

### Gerenciamento de Estado Reativo

```dart
// Escutar mudanças de estado
_stateManager.stateStream.listen((state) {
  print('Form state changed: ${state.isValid}');
});

// Atualizar campos
await _stateManager.updateField('name', 'Novo Nome');
await _stateManager.updateFields({
  'name': 'Novo Nome',
  'plate': 'ABC-1234',
});

// Gerenciar estado de carregamento
await _stateManager.setLoading(true);
await _stateManager.setError('Erro de validação');
```

### Sistema de Validação Flexível

```dart
// Validadores básicos
RequiredValidator()
LengthValidator.range(5, 50)
EmailValidator.standard()

// Validadores customizados
class PlateValidator extends StringValidator {
  @override
  ValidationResult validateString(String value) {
    // Implementar validação customizada
  }
}

// Validação cross-field
class ConfirmPasswordRule extends CrossFieldValidationRule {
  @override
  ValidationResult validate(Map<String, dynamic> fieldValues) {
    // Validar entre campos
  }
}
```

### Factory de Campos Extensível

```dart
// Usar factory padrão
final factory = MaterialFieldFactory();

// Registrar campos customizados
factory.registerCustomFieldCreator('signature', (config) {
  return SignatureField(config: config);
});

// Criar campos
final textField = factory.createTextField(textConfig);
final dropdown = factory.createDropdownField(dropdownConfig);
final customField = factory.createCustomField(customConfig);
```

### Auto-save e Persistência

```dart
FormStateManagerBuilder<VehicleData>()
    .withAutoSave(
      interval: const Duration(seconds: 30),
      onSave: (data) async {
        await _saveToLocalStorage(data);
      },
    )
    .buildProvider();
```

## 🧪 Testing

### Unit Tests para Validadores

```dart
test('PlateValidator should validate correct format', () {
  final validator = PlateValidator();
  
  final result = validator.validate('ABC-1234');
  expect(result.isValid, true);
  
  final invalidResult = validator.validate('invalid');
  expect(invalidResult.isValid, false);
});
```

### Widget Tests para Campos

```dart
testWidgets('TextField should display error when invalid', (tester) async {
  final config = TextFieldConfigBuilder()
      .key('test')
      .label('Test Field')
      .required()
      .build();
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MaterialFieldFactory().createTextField(config),
      ),
    ),
  );
  
  // Test interactions...
});
```

## 🔄 Migração dos Formulários Existentes

### Passo 1: Identificar Formulários
- Listar todos os formulários existentes
- Analisar complexidade e dependências
- Priorizar migração por impacto

### Passo 2: Criar Configurações
- Extrair campos para FieldConfig
- Implementar FormConfig para cada formulário
- Migrar validação para ValidationConfig

### Passo 3: Substituir Widgets
- Substituir formulários antigos gradualmente
- Manter compatibilidade com código existente
- Testar cada migração

### Passo 4: Remover Código Legacy
- Após migração completa, remover código antigo
- Atualizar documentação
- Treinar equipe na nova arquitetura

## 📚 Exemplos Completos

Veja o arquivo `examples/vehicle_form_example.dart` para um exemplo completo de implementação.

## 🤝 Contribuindo

Para adicionar novos tipos de campo:

1. Implementar `FieldConfig` específico
2. Adicionar criação no `IFieldFactory`
3. Implementar widget usando `BaseFormField`
4. Adicionar testes unitários

Para novos validadores:

1. Estender `BaseFieldValidator`
2. Implementar lógica de validação
3. Adicionar ao sistema de configuração
4. Criar testes de validação

## 🔍 Debugging

### State Tracking
```dart
final tracker = _stateManager.tracker;
print('State changes: ${tracker.statistics}');
```

### Validation Debugging
```dart
final result = validator.validate(value);
print('Validation result: ${result.toString()}');
```

### Form Configuration Validation
```dart
final errors = _formConfig.validateConfiguration();
if (errors.isNotEmpty) {
  print('Form config errors: $errors');
}
```