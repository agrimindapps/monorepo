# Sistema Completo de Feedback Visual para Operações Async

Este sistema oferece feedback visual unificado para todas as operações async do app-plantis, trabalhando em conjunto com o ContextualLoadingManager existente.

## 🚀 Funcionalidades

- **Loading States Contextuais** - Estados visuais durante operações
- **Feedback de Sucesso/Erro** - Animações customizadas (checkmark, confetti, shake)
- **Toasts Não Intrusivos** - Mensagens contextuais elegantes
- **Progress Tracking** - Para uploads, downloads e processamento
- **Haptic Feedback** - Feedback tátil para diferentes ações
- **Dialogs de Confirmação** - Com feedback visual integrado
- **Integração com Acessibilidade** - Screen readers e navegação

## 🏗️ Arquitetura

```
feedback/
├── feedback.dart                    # Export unificado
├── unified_feedback_system.dart     # Sistema principal
├── feedback_system.dart            # Feedback core
├── animated_feedback.dart          # Animações específicas
├── haptic_service.dart             # Feedback tátil
├── toast_service.dart              # Toasts contextuais
├── progress_tracker.dart           # Tracking de progresso
├── confirmation_system.dart        # Dialogs de confirmação
└── README.md                       # Esta documentação
```

## 🎯 Uso Básico

### 1. Inicialização (main.dart)

```dart
import 'package:app_plantis/shared/widgets/feedback/feedback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar sistema de feedback
  await UnifiedFeedbackSystem.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UnifiedFeedbackProvider(
        child: HomePage(),
      ),
    );
  }
}
```

### 2. Em Pages/Widgets

```dart
import 'package:app_plantis/shared/widgets/feedback/feedback.dart';

class MyWidget extends StatefulWidget with UnifiedFeedbackMixin {
  
  Future<void> _saveData() async {
    // Operação com feedback completo
    await executeOperation(
      context: context,
      operation: () async {
        // Sua lógica aqui
        return await dataService.save();
      },
      loadingMessage: 'Salvando dados...',
      successMessage: 'Dados salvos com sucesso!',
      loadingType: LoadingType.save,
      successAnimation: SuccessAnimationType.checkmark,
    );
  }
  
  Future<void> _deleteItem() async {
    // Confirmação antes de deletar
    final confirmed = await showConfirmation(
      context: context,
      title: 'Deletar item',
      message: 'Tem certeza?',
      type: ConfirmationType.warning,
    );
    
    if (confirmed) {
      await executeOperation(
        context: context,
        operation: () => dataService.delete(),
        loadingMessage: 'Deletando...',
        successMessage: 'Item deletado!',
      );
    }
  }
  
  void _showQuickToast() {
    showSuccessToast(context, 'Operação realizada!');
  }
}
```

### 3. Com Contextos Específicos

```dart
// Salvar planta
await UnifiedFeedbackSystem.savePlant(
  context: context,
  saveOperation: () => plantService.save(plant),
  plantName: plant.name,
  isEdit: false,
);

// Completar tarefa  
await UnifiedFeedbackSystem.completeTask(
  context: context,
  completeOperation: () => taskService.complete(taskId),
  taskName: task.title,
);

// Upload com progresso
await UnifiedFeedbackSystem.uploadImage(
  context: context,
  uploadOperation: (onProgress) => imageService.upload(file, onProgress),
  imageName: file.name,
);

// Compra premium
await UnifiedFeedbackSystem.purchasePremium(
  context: context,
  purchaseOperation: () => purchaseService.buy(product),
);
```

### 4. Helpers Rápidos

```dart
// Toasts rápidos
QuickFeedback.success(context, 'Sucesso!');
QuickFeedback.error(context, 'Erro!');
QuickFeedback.warning(context, 'Atenção!');

// Confirmações rápidas
final confirmed = await QuickFeedback.confirm(
  context,
  'Título',
  'Mensagem',
);

// Haptic feedback
await QuickFeedback.haptic();        // Leve
await QuickFeedback.hapticMedium();  // Médio  
await QuickFeedback.hapticHeavy();   // Pesado
```

### 5. Padrões Pré-definidos

```dart
// Padrão para salvar dados
await FeedbackPatterns.saveData(
  context: context,
  operation: () => service.save(),
  itemName: 'Planta',
  isUpdate: false,
);

// Padrão para deletar dados
await FeedbackPatterns.deleteData(
  context: context,
  operation: () => service.delete(),
  itemName: 'Rosa',
  itemType: 'planta',
  requireConfirmation: true,
);

// Padrão para upload
await FeedbackPatterns.uploadFile(
  context: context,
  operation: (onProgress) => service.upload(file, onProgress),
  fileName: 'photo.jpg',
);
```

## 🎨 Tipos de Feedback

### Loading Types
- `LoadingType.standard` - Loading padrão
- `LoadingType.save` - Para operações de salvamento
- `LoadingType.purchase` - Para transações
- `LoadingType.sync` - Para sincronização
- `LoadingType.auth` - Para autenticação

### Success Animations
- `SuccessAnimationType.checkmark` - Checkmark animado
- `SuccessAnimationType.confetti` - Confetti colorido
- `SuccessAnimationType.bounce` - Efeito bounce
- `SuccessAnimationType.fade` - Fade in/out

### Error Animations  
- `ErrorAnimationType.shake` - Shake horizontal
- `ErrorAnimationType.pulse` - Pulsação
- `ErrorAnimationType.fade` - Fade in/out

### Confirmation Types
- `ConfirmationType.info` - Informação
- `ConfirmationType.success` - Sucesso
- `ConfirmationType.warning` - Aviso
- `ConfirmationType.error` - Erro

## 🔧 Configuração Avançada

### Personalizar Feedback Provider

```dart
UnifiedFeedbackProvider(
  enableFeedbackOverlay: true,      // Overlays de feedback
  enableToastOverlay: true,         // Toasts
  enableProgressOverlay: true,      // Progress tracking
  feedbackAlignment: Alignment.topCenter,
  child: MyApp(),
)
```

### Haptic Feedback Customizado

```dart
// Padrões específicos
await HapticContexts.completeTask();     // Tarefa concluída
await HapticContexts.addPlant();         // Planta adicionada  
await HapticContexts.purchaseSuccess();  // Compra realizada
await HapticContexts.uploadComplete();   // Upload completo

// Padrão customizado
await HapticService.custom(
  pattern: [
    HapticType.medium,
    HapticType.light,
    HapticType.light,
  ],
  delayBetween: 100,
);
```

### Progress Tracking Customizado

```dart
// Iniciar operação
final operation = ProgressTracker.startOperation(
  key: 'my_operation',
  title: 'Processando',
  description: 'Fazendo algo importante...',
  type: ProgressType.determinate,
);

// Atualizar progresso
ProgressTracker.updateProgress('my_operation', 
  progress: 0.5, 
  message: 'Meio do caminho...',
);

// Completar
ProgressTracker.completeOperation('my_operation',
  successMessage: 'Concluído!',
);
```

## 📱 Exemplos de Integração

### Tasks Page (Já Integrada)

```dart
class _TasksListPageState extends State<TasksListPage> 
    with UnifiedFeedbackMixin {
  
  Future<void> _showTaskCompletionDialog(task_entity.Task task) async {
    final result = await TaskCompletionDialog.show(
      context: context,
      task: task,
    );

    if (result != null && context.mounted) {
      await UnifiedFeedbackSystem.completeTask(
        context: context,
        completeOperation: () async {
          final success = await context.read<TasksProvider>().completeTask(
            task.id, 
            notes: result.notes,
          );
          
          if (!success) {
            throw Exception('Falha ao concluir tarefa');
          }
          
          return success;
        },
        taskName: task.title,
      );
    }
  }
}
```

### Plant Form Integration Example

```dart
class _PlantFormPageState extends State<PlantFormPage> 
    with UnifiedFeedbackMixin {
  
  Future<void> _savePlant() async {
    final provider = Provider.of<PlantFormProvider>(context, listen: false);
    final plantName = provider.nameController.text.trim();
    final isEditing = widget.plantId != null;
    
    await UnifiedFeedbackSystem.savePlant(
      context: context,
      saveOperation: () async {
        final success = await provider.savePlant();
        
        if (success) {
          // Atualizar lista de plantas
          final plantsProvider = Provider.of<PlantsProvider>(context, listen: false);
          await plantsProvider.refreshPlants();
        }
        
        return success;
      },
      plantName: plantName.isEmpty ? 'Nova planta' : plantName,
      isEdit: isEditing,
    );
    
    if (mounted) {
      context.pop();
    }
  }
}
```

### Premium Page Integration

```dart
class _PremiumPageState extends State<PremiumPage> 
    with UnifiedFeedbackMixin {
  
  Future<void> _purchasePremium(ProductDetails product) async {
    try {
      await UnifiedFeedbackSystem.purchasePremium(
        context: context,
        purchaseOperation: () async {
          final purchase = await InAppPurchase.instance.buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: product),
          );
          
          // Verificar se compra foi bem sucedida
          if (!purchase.status.isPurchased) {
            throw Exception('Compra não foi concluída');
          }
          
          return purchase;
        },
      );
    } catch (e) {
      // Erro já foi tratado pelo sistema de feedback
      print('Erro na compra premium: $e');
    }
  }
  
  Future<void> _restorePurchases() async {
    await executeOperation(
      context: context,
      operation: () => InAppPurchase.instance.restorePurchases(),
      loadingMessage: 'Restaurando compras...',
      successMessage: 'Compras restauradas!',
      loadingType: LoadingType.sync,
    );
  }
}
```

## 🔍 Debugging

Para debug, o sistema oferece logs detalhados:

```dart
// Habilitar logs de haptic feedback
HapticService.setEnabled(true);

// Ver operações ativas
print('Feedbacks ativos: ${FeedbackSystem.activeFeedbacks}');
print('Progress operations: ${ProgressTracker.activeOperations}');
print('Loading contexts: ${ContextualLoadingManager.activeLoadings}');
```

## 🧹 Cleanup

O sistema gerencia automaticamente a limpeza de recursos, mas você pode fazer cleanup manual:

```dart
// Parar todas as operações
UnifiedFeedbackSystem.stopAll();

// Limpar recursos na saída do app
UnifiedFeedbackSystem.dispose();
```

## 🎯 Melhores Práticas

1. **Use contextos específicos** - `savePlant()`, `completeTask()`, etc.
2. **Combine loading + success/error** - Para experiência completa
3. **Haptic feedback moderado** - Não abuse, use contextualmente
4. **Mensagens claras** - Seja específico sobre o que está acontecendo
5. **Animações apropriadas** - Confetti para conquistas, checkmark para saves
6. **Confirmações para ações destrutivas** - Sempre confirme deletar
7. **Progress tracking para operações longas** - Upload, backup, sync
8. **Toasts para feedback rápido** - Operações simples e informações

## 🆕 Extensibilidade

O sistema é extensível. Para adicionar novos contextos:

```dart
// Novo contexto de feedback
class CustomContexts {
  static Future<T> customOperation<T>({
    required BuildContext context,
    required Future<T> Function() operation,
  }) {
    return UnifiedFeedbackSystem.executeWithFeedback<T>(
      context: context,
      operationKey: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      loadingMessage: 'Fazendo algo personalizado...',
      successMessage: 'Operação personalizada concluída!',
      loadingType: LoadingType.standard,
      successAnimation: SuccessAnimationType.bounce,
    );
  }
}
```

Este sistema oferece uma experiência de feedback visual completa e consistente em todo o app, melhorando significativamente a UX das operações async.