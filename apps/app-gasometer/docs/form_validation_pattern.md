# Sistema de Validação Centralizada - Padrão de Implementação

## Visão Geral

Este documento descreve como implementar o sistema de validação centralizada para formulários no app-gasometer, que migra de validações em tempo real para validações apenas no momento do "Salvar", exibindo erros no header do formulário.

## Arquivos Core Criados

### 1. FormValidator (`/lib/core/validation/form_validator.dart`)

Classe principal para validação centralizada que:
- Gerencia múltiplos campos de formulário
- Retorna apenas o PRIMEIRO erro encontrado
- Suporte a scroll automático para campo com erro
- Integração com sistema de validação existente (ValidatedFormField)

### 2. ErrorHeader (`/lib/core/widgets/error_header.dart`)

Widget responsivo para exibir erros no header:
- Animação suave de entrada/saída
- Mesmo tamanho de fonte da linha atual do header
- Cor vermelha com negrito
- Botão de dismiss opcional

## Como Implementar em Outros Formulários

### Passo 1: Preparar a Página

```dart
// 1. Adicionar imports necessários
import '../../../../core/validation/form_validator.dart';
import '../../../../core/widgets/error_header.dart';

// 2. Adicionar FormErrorHandlerMixin ao State
class _MinhaFormPageState extends State<MinhaFormPage> with FormErrorHandlerMixin {
  // 3. Declarar FormValidator e keys para scroll
  late final FormValidator _formValidator;
  final Map<String, GlobalKey> _fieldKeys = {};

  // Controllers dos campos...
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
}
```

### Passo 2: Configurar FormValidator

```dart
void _initializeFormValidator() {
  _formValidator = FormValidator();

  // Gerar keys para scroll automático
  _fieldKeys['nome'] = GlobalKey();
  _fieldKeys['email'] = GlobalKey();
  _fieldKeys['telefone'] = GlobalKey();

  // Configurar validações centralizadas
  _formValidator.addFields([
    FormFieldConfig(
      fieldId: 'nome',
      controller: _nomeController,
      validationType: ValidationType.length,
      required: true,
      minLength: 2,
      maxLength: 50,
      label: 'Nome',
      scrollKey: _fieldKeys['nome'],
    ),
    FormFieldConfig(
      fieldId: 'email',
      controller: _emailController,
      validationType: ValidationType.email,
      required: true,
      label: 'E-mail',
      scrollKey: _fieldKeys['email'],
    ),
    FormFieldConfig(
      fieldId: 'telefone',
      controller: _telefoneController,
      validationType: ValidationType.phone,
      required: false,
      label: 'Telefone',
      scrollKey: _fieldKeys['telefone'],
    ),
  ]);
}

@override
void initState() {
  super.initState();
  _initializeFormValidator();
}

@override
void dispose() {
  _formValidator.clear();
  _nomeController.dispose();
  _emailController.dispose();
  super.dispose();
}
```

### Passo 3: Atualizar Layout do Formulário

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Meu Formulário')),
    body: Form(
      child: Column(
        children: [
          // ErrorHeader para exibir erros de validação
          buildFormErrorHeader(),
          if (formErrorMessage != null)
            SizedBox(height: 16),

          // Campos do formulário
          Container(
            key: _fieldKeys['nome'],
            child: ValidatedFormField(
              controller: _nomeController,
              label: 'Nome',
              required: true,
              validationType: ValidationType.length,
              validateOnChange: false, // IMPORTANTE: Desabilitar validação em tempo real
              minLength: 2,
              maxLengthValidation: 50,
            ),
          ),

          SizedBox(height: 16),

          Container(
            key: _fieldKeys['email'],
            child: ValidatedFormField(
              controller: _emailController,
              label: 'E-mail',
              required: true,
              validationType: ValidationType.email,
              validateOnChange: false, // IMPORTANTE: Desabilitar validação em tempo real
            ),
          ),

          // Mais campos...
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _submitForm,
      child: Icon(Icons.save),
    ),
  );
}
```

### Passo 4: Implementar Validação no Submit

```dart
Future<void> _submitForm() async {
  // Limpar erro anterior
  clearFormError();

  // Validação centralizada usando FormValidator
  final validationResult = await _formValidator.validateAll();

  // Validações customizadas adicionais (se necessário)
  if (algumCampoEspecial.isEmpty) {
    setFormError('Validação customizada falhou');
    return;
  }

  // Se há erro de validação, exibir no header e fazer scroll
  if (!validationResult.isValid) {
    setFormError(validationResult.message);
    // Scroll para o primeiro campo com erro
    await _formValidator.scrollToFirstError();
    return;
  }

  // Continuar com lógica de salvamento...
  try {
    // Salvar dados...
    Navigator.of(context).pop(true);
  } catch (e) {
    setFormError('Erro ao salvar: $e');
  }
}
```

## Exemplo Completo

Veja a implementação completa em:
`/lib/features/vehicles/presentation/pages/add_vehicle_page.dart`

## Configurações de Validação Disponíveis

### Tipos de Validação Predefinidos

```dart
ValidationType.none           // Sem validação
ValidationType.required       // Campo obrigatório
ValidationType.email          // E-mail válido
ValidationType.phone          // Telefone válido
ValidationType.money          // Valor monetário
ValidationType.decimal        // Número decimal
ValidationType.integer        // Número inteiro
ValidationType.licensePlate   // Placa de veículo
ValidationType.chassis        // Chassi de veículo
ValidationType.renavam        // Renavam
ValidationType.odometer       // Odômetro
ValidationType.fuelLiters     // Litros de combustível
ValidationType.fuelPrice      // Preço de combustível
ValidationType.length         // Validação de comprimento
ValidationType.custom         // Validador customizado
```

### Parâmetros de Validação

```dart
FormFieldConfig(
  fieldId: 'campo_id',           // ID único do campo
  controller: _controller,        // TextEditingController
  validationType: ValidationType.length,
  required: true,                 // Campo obrigatório

  // Para validação de comprimento
  minLength: 2,
  maxLength: 50,

  // Para validação de valores numéricos
  minValue: 0.0,
  maxValue: 999999.0,

  // Para campos específicos de veículos
  currentOdometer: 50000.0,
  initialOdometer: 0.0,
  tankCapacity: 60.0,

  // Validador customizado
  customValidator: (value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    // Lógica de validação customizada...
    return null; // Retorna null se válido
  },

  label: 'Nome do Campo',         // Label para mensagens de erro
  scrollKey: _fieldKeys['campo'], // Key para scroll automático
)
```

## Widgets de Erro Disponíveis

### 1. FormValidationErrorHeader
```dart
FormValidationErrorHeader(
  errorMessage: errorMessage,
  onClear: () => setState(() => errorMessage = null),
  showClearButton: true,
)
```

### 2. ErrorHeader (mais genérico)
```dart
ErrorHeader(
  errorMessage: errorMessage,
  onDismiss: () => clearError(),
  showDismissButton: true,
  errorIcon: Icons.warning_amber_rounded,
  backgroundColor: Colors.red.shade50,
)
```

### 3. InlineErrorMessage (para erros específicos de campo)
```dart
InlineErrorMessage(
  errorMessage: fieldErrorMessage,
  padding: EdgeInsets.only(top: 4, left: 12, right: 12),
)
```

## Funcionalidades Avançadas

### Scroll Automático para Campo com Erro

```dart
// Scroll para primeiro campo com erro
await _formValidator.scrollToFirstError();

// Scroll para campo específico
final fieldKey = _formValidator.getFieldKey('campo_id');
if (fieldKey?.currentContext != null) {
  await Scrollable.ensureVisible(fieldKey!.currentContext!);
}
```

### Validação de Campos Específicos

```dart
// Validar apenas um campo
final result = await _formValidator.validateField('email');

// Validar apenas campos obrigatórios
final result = await _formValidator.validateRequiredOnly();

// Obter lista de campos obrigatórios vazios
final emptyFields = _formValidator.getEmptyRequiredFields();
```

### Debugging e Análise

```dart
// Obter todos os erros para debugging
final allErrors = await _formValidator.getAllErrors();
for (final error in allErrors) {
  print('${error.fieldId}: ${error.result.message}');
}
```

## Mixin FormErrorHandlerMixin

O mixin fornece métodos convenientes para gerenciar erros:

```dart
// Definir erro
setFormError('Mensagem de erro');

// Limpar erro
clearFormError();

// Erro temporário (remove automaticamente)
showTemporaryError('Erro temporário', duration: Duration(seconds: 3));

// Widget ErrorHeader pronto
Widget buildFormErrorHeader()

// Propriedade para acessar erro atual
String? get formErrorMessage
```

## Padrões e Convenções

### 1. Nomenclatura de IDs
- Use snake_case para IDs de campos: `nome_completo`, `data_nascimento`
- Mantenha consistência entre ID e nome do controller

### 2. Keys de Scroll
- Armazene em Map<String, GlobalKey> para fácil acesso
- Use o mesmo ID do campo como chave no Map

### 3. Ordem de Validação
- Campos obrigatórios primeiro
- Ordem visual do formulário (top to bottom)
- Validações customizadas por último

### 4. Mensagens de Erro
- Seja específico: "E-mail é obrigatório" vs "Campo obrigatório"
- Use linguagem amigável ao usuário
- Mantenha consistência no tom e estilo

### 5. Performance
- Não valide campos desnecessários
- Use validação assíncrona apenas quando necessário
- Limpe FormValidator no dispose()

## Troubleshooting

### Erro: "Campo não encontrado"
- Verifique se o campo foi adicionado ao FormValidator
- Confirme que o fieldId está correto

### Scroll não funciona
- Verifique se a key foi definida no Container pai do campo
- Confirme que o campo está dentro de um Scrollable

### Validação não dispara
- Confirme que `validateOnChange: false` está definido
- Verifique se `await _formValidator.validateAll()` está sendo chamado

### Erro persiste após correção
- Verifique se `clearFormError()` está sendo chamado antes da nova validação
- Confirme que o estado está sendo atualizado corretamente

## Migração de Formulários Existentes

### 1. Identificar Validações Atuais
```dart
// ANTES: ValidatedFormField com validação em tempo real
ValidatedFormField(
  controller: _emailController,
  validationType: ValidationType.email,
  onValidationChanged: (result) => _validationResults['email'] = result,
)

// DEPOIS: ValidatedFormField sem validação em tempo real
Container(
  key: _fieldKeys['email'],
  child: ValidatedFormField(
    controller: _emailController,
    validationType: ValidationType.email,
    validateOnChange: false, // Desabilitar validação em tempo real
  ),
)
```

### 2. Migrar Lógica de Submit
```dart
// ANTES: Validação no FormProvider ou manual
if (!formProvider.validateForm()) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Corrija os erros')),
  );
  return;
}

// DEPOIS: Validação centralizada
final validationResult = await _formValidator.validateAll();
if (!validationResult.isValid) {
  setFormError(validationResult.message);
  await _formValidator.scrollToFirstError();
  return;
}
```

### 3. Atualizar UI
```dart
// ANTES: Erros nos próprios campos
// DEPOIS: Erro centralizado no header
buildFormErrorHeader(),
```

## Checklist de Implementação

- [ ] Adicionar imports necessários
- [ ] Implementar FormErrorHandlerMixin no State
- [ ] Declarar FormValidator e fieldKeys
- [ ] Configurar validações no initState()
- [ ] Atualizar campos para usar Container com keys
- [ ] Desabilitar validateOnChange nos campos
- [ ] Adicionar ErrorHeader no layout
- [ ] Implementar validação no método submit
- [ ] Adicionar scroll automático para erros
- [ ] Testar cenários de erro e sucesso
- [ ] Limpar recursos no dispose()

Este padrão garante uma experiência consistente de validação em todos os formulários do app, com feedback claro para o usuário e scroll automático para campos com problemas.