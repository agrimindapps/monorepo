# Widgets Consolidados para Cadastros

Esta pasta contém todos os widgets consolidados e reutilizáveis para os formulários de cadastro do app PetiVeti.

## 📁 Estrutura

```
lib/app-petiveti/widgets/cadastros/
├── shared/                 # Widgets compartilhados
├── form_sections/         # Seções de formulário
├── specialized/           # Widgets especializados
└── constants/            # Constantes e estilos
```

## 🧩 Widgets Compartilhados

### SharedLoadingOverlay
Overlay de carregamento unificado com factories específicos para cada tipo de cadastro.

```dart
// Uso específico
SharedLoadingOverlay.consulta(message: 'Salvando consulta...')
SharedLoadingOverlay.despesa(message: 'Salvando despesa...')

// Uso genérico
SharedLoadingOverlay.generic(message: 'Carregando...')

// Como wrapper
SharedLoadingOverlay.wrapWithOverlay(
  child: MyWidget(),
  isLoading: isLoading,
)
```

### SharedErrorDisplay
Exibição de erros com diferentes tipos e comportamentos.

```dart
// Tipos disponíveis
SharedErrorDisplay.error(message: 'Erro ao salvar')
SharedErrorDisplay.warning(message: 'Atenção necessária')
SharedErrorDisplay.info(message: 'Informação importante')
SharedErrorDisplay.success(message: 'Operação bem-sucedida')

// Com auto-hide
SharedErrorDisplay.error(
  message: 'Erro temporário',
  autoHideDuration: Duration(seconds: 3),
)

// Como SnackBar
SharedErrorDisplay.showAsSnackBar(
  context,
  message: 'Erro de rede',
  type: ErrorDisplayType.error,
)
```

### SharedActionButtons
Botões de ação padronizados para formulários.

```dart
// Específicos por cadastro
SharedActionButtons.consulta(
  isLoading: false,
  hasErrors: false,
  canSave: true,
  isEditMode: true,
  onSave: () => _saveConsulta(),
  onDelete: () => _deleteConsulta(),
)

// Modo compacto para modais
SharedActionButtons.compact(
  isLoading: false,
  canSave: true,
  onSave: () => _save(),
  onCancel: () => Navigator.pop(context),
)
```

### SharedDatePicker
Seletor de data com informações contextuais e validações.

```dart
// Específicos por cadastro
SharedDatePicker.consulta(
  selectedDate: DateTime.now(),
  onDateChanged: (date) => _updateDate(date),
)

SharedDatePicker.peso(
  selectedDate: pesagemDate,
  onDateChanged: (date) => controller.updateDate(date),
  errorText: 'Data inválida',
)
```

### SharedAnimalSelector
Seletor de animais com busca e estados vazios.

```dart
SharedAnimalSelector.consulta(
  animals: animalList,
  selectedAnimalId: selectedId,
  onAnimalChanged: (id) => _selectAnimal(id),
  onAddAnimal: () => _navigateToAddAnimal(),
)

// Como dialog
final selectedId = await SharedAnimalSelector.showSelectionDialog(
  context: context,
  animals: animals,
  title: 'Selecionar Animal',
);
```

### SharedCurrencyInput
Entrada de valores monetários com formatação automática.

```dart
// Específicos por tipo
SharedCurrencyInput.consulta(
  value: consultaValue,
  onValueChanged: (value) => _updateValue(value),
)

SharedCurrencyInput.peso(
  value: pesoKg,
  onValueChanged: (value) => _updatePeso(value),
)

// Validação estática
final error = SharedCurrencyInput.validateCurrency(
  value,
  required: true,
  minValue: 0.0,
  maxValue: 999.99,
);
```

### SharedTextInput
Entradas de texto com validações e formatações específicas.

```dart
// Tipos específicos
SharedTextInput.veterinarian(
  value: vetName,
  onChanged: (value) => _updateVet(value),
)

SharedTextInput.observacoes(
  value: observations,
  onChanged: (value) => _updateObs(value),
  isRequired: false,
)

SharedTextInput.email(
  value: email,
  onChanged: (value) => _updateEmail(value),
)
```

## 🎨 Constantes e Estilos

### FormStyles
Cores, espaçamentos e estilos unificados.

```dart
// Cores
FormStyles.primaryColor
FormStyles.errorColor
FormStyles.successColor

// Espaçamentos
FormStyles.smallSpacing
FormStyles.mediumSpacing
FormStyles.largeSpacing

// Estilos de input
FormStyles.getInputDecoration(labelText: 'Label')
FormStyles.getPrimaryButtonStyle()
```

### FormConstants
Constantes para textos, limites e configurações.

```dart
// Mensagens
FormConstants.requiredFieldMessage
FormConstants.saveSuccessMessage

// Limites
FormConstants.maxCurrencyValue
FormConstants.longTextLimit

// Labels
FormConstants.saveLabel
FormConstants.cancelLabel
```

## 🚀 Como Usar

### 1. Import Simplificado
```dart
import 'package:fnutrituti/app-petiveti/widgets/cadastros/shared/index.dart';
import 'package:fnutrituti/app-petiveti/widgets/cadastros/constants/index.dart';
```

### 2. Exemplo de Formulário Completo
```dart
class MyFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SharedAnimalSelector.consulta(
            animals: animals,
            selectedAnimalId: selectedId,
            onAnimalChanged: _selectAnimal,
          ),
          
          SharedDatePicker.consulta(
            selectedDate: date,
            onDateChanged: _updateDate,
          ),
          
          SharedTextInput.veterinarian(
            value: vetName,
            onChanged: _updateVet,
          ),
          
          SharedCurrencyInput.consulta(
            value: value,
            onValueChanged: _updateValue,
          ),
        ],
      ),
      bottomNavigationBar: SharedActionButtons.consulta(
        isLoading: isLoading,
        hasErrors: hasErrors,
        canSave: canSave,
        isEditMode: isEditMode,
        onSave: _save,
        onDelete: _delete,
      ),
    );
  }
}
```

## ✨ Benefícios

- **🔄 Reutilização**: Um widget para múltiplos cadastros
- **🎨 Consistência**: Visual padronizado em toda a app
- **🛠️ Manutenção**: Alterações centralizadas
- **📱 Responsividade**: Adaptação automática a diferentes telas
- **✅ Validação**: Regras de negócio integradas
- **🎭 Flexibilidade**: Factories para casos específicos

## 🔧 Extensibilidade

Para adicionar novos tipos ou comportamentos:

1. **Novos Factories**: Adicione factories específicos nos widgets existentes
2. **Novos Widgets**: Siga o padrão de nomenclatura `Shared[Nome]Widget`
3. **Novas Constantes**: Adicione em `FormConstants` ou `FormStyles`
4. **Export**: Atualize o `index.dart` para incluir novos widgets

## 📋 Checklist de Migração

Para migrar um formulário existente:

- [ ] Substituir loading overlays por `SharedLoadingOverlay`
- [ ] Substituir displays de erro por `SharedErrorDisplay`
- [ ] Substituir botões de ação por `SharedActionButtons`
- [ ] Substituir date pickers por `SharedDatePicker`
- [ ] Substituir seletores de animal por `SharedAnimalSelector`
- [ ] Substituir inputs de valor por `SharedCurrencyInput`
- [ ] Substituir campos de texto por `SharedTextInput`
- [ ] Atualizar imports para usar versões consolidadas
- [ ] Testar funcionalidades específicas do formulário
- [ ] Remover widgets antigos não utilizados