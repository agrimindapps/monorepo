# 📸 Guia de Integração - Imagens de Comprovantes

Este guia demonstra como integrar a funcionalidade de anexo de imagens de comprovantes nos formulários da aplicação.

## ✅ **Implementação Completa: FuelFormProvider**

O FuelFormProvider já está **100% implementado** e serve como referência para outros formulários.

### **Arquivos Envolvidos:**
- `lib/features/fuel/presentation/providers/fuel_form_provider.dart` - Provider atualizado
- `lib/features/fuel/presentation/widgets/fuel_form_view.dart` - UI integrada
- `lib/core/services/receipt_image_service.dart` - Serviço unificado
- `lib/core/services/image_compression_service.dart` - Compressão WebP
- `lib/core/services/firebase_storage_service.dart` - Upload Firebase

---

## 🔧 **Padrão de Integração (Para Outros Formulários)**

### **1. Atualizar Provider**

```dart
// No construtor
class MaintenanceFormProvider extends ChangeNotifier {
  final ReceiptImageService _receiptImageService;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Estado de imagem
  String? _receiptImagePath;
  String? _receiptImageUrl;
  bool _isUploadingImage = false;
  String? _imageUploadError;
  
  MaintenanceFormProvider({
    required ReceiptImageService receiptImageService,
  }) : _receiptImageService = receiptImageService;
}
```

### **2. Adicionar Getters**

```dart
// Getters de imagem
String? get receiptImagePath => _receiptImagePath;
String? get receiptImageUrl => _receiptImageUrl;
bool get hasReceiptImage => _receiptImagePath != null || _receiptImageUrl != null;
bool get isUploadingImage => _isUploadingImage;
String? get imageUploadError => _imageUploadError;

// Atualizar isLoading
@override
bool get isLoading => _baseIsLoading || _isUploadingImage;
```

### **3. Implementar Métodos de Captura**

```dart
/// Captura imagem usando a câmera
Future<void> captureReceiptImage() async {
  try {
    _imageUploadError = null;
    notifyListeners();

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      await _processReceiptImage(image.path);
    }
  } catch (e) {
    _imageUploadError = 'Erro ao capturar imagem: $e';
    notifyListeners();
  }
}

/// Seleciona imagem da galeria
Future<void> selectReceiptImageFromGallery() async {
  try {
    _imageUploadError = null;
    notifyListeners();

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (image != null) {
      await _processReceiptImage(image.path);
    }
  } catch (e) {
    _imageUploadError = 'Erro ao selecionar imagem: $e';
    notifyListeners();
  }
}

/// Processa e faz upload da imagem
Future<void> _processReceiptImage(String imagePath) async {
  try {
    _isUploadingImage = true;
    _imageUploadError = null;
    notifyListeners();

    // Processar imagem (comprimir + upload)
    final result = await _receiptImageService.processMaintenanceReceiptImage(
      userId: _formModel.userId,
      maintenanceId: _generateTemporaryId(),
      imagePath: imagePath,
      compressImage: true,
      uploadToFirebase: true,
    );

    _receiptImagePath = result.localPath;
    _receiptImageUrl = result.downloadUrl;
    
    _formModel = _formModel.copyWith(hasChanges: true);
    
  } catch (e) {
    _imageUploadError = 'Erro ao processar imagem: $e';
  } finally {
    _isUploadingImage = false;
    notifyListeners();
  }
}

/// Remove imagem
Future<void> removeReceiptImage() async {
  try {
    if (_receiptImagePath != null || _receiptImageUrl != null) {
      await _receiptImageService.deleteReceiptImage(
        localPath: _receiptImagePath,
        downloadUrl: _receiptImageUrl,
      );
    }

    _receiptImagePath = null;
    _receiptImageUrl = null;
    _imageUploadError = null;
    _formModel = _formModel.copyWith(hasChanges: true);
    
    notifyListeners();
  } catch (e) {
    _imageUploadError = 'Erro ao remover imagem: $e';
    notifyListeners();
  }
}

String _generateTemporaryId() {
  return 'temp_${DateTime.now().millisecondsSinceEpoch}';
}

void _clearImageState() {
  _receiptImagePath = null;
  _receiptImageUrl = null;
  _imageUploadError = null;
  _isUploadingImage = false;
}
```

### **4. Atualizar Métodos de Limpeza**

```dart
void clearForm() {
  // ... outros campos ...
  _clearImageState();
  notifyListeners();
}

void resetForm() {
  clearForm();
  _clearImageState();
  // ... resto da implementação ...
}
```

---

## 🎨 **Integração na UI**

### **1. Importar Widget**

```dart
import '../../../expenses/presentation/widgets/receipt_image_picker.dart';
```

### **2. Adicionar à View**

```dart
Column(
  children: [
    // ... outros widgets ...
    _buildReceiptImageSection(context, provider),
  ],
)
```

### **3. Implementar Seção de Imagem**

```dart
Widget _buildReceiptImageSection(BuildContext context, MaintenanceFormProvider provider) {
  return _buildSectionWithoutPadding(
    title: 'Comprovante',
    icon: Icons.receipt,
    content: Column(
      children: [
        ReceiptImagePicker(
          imagePath: provider.receiptImagePath,
          hasImage: provider.hasReceiptImage,
          onImageSelected: () => _showImagePickerOptions(context, provider),
          onImageRemoved: () => provider.removeReceiptImage(),
        ),
        if (provider.isUploadingImage)
          _buildUploadingIndicator(),
        if (provider.imageUploadError != null)
          _buildErrorIndicator(provider.imageUploadError!),
      ],
    ),
  );
}

void _showImagePickerOptions(BuildContext context, MaintenanceFormProvider provider) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              subtitle: const Text('Tirar uma nova foto'),
              onTap: () {
                Navigator.pop(context);
                provider.captureReceiptImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              subtitle: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                provider.selectReceiptImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
```

---

## 🔄 **Sincronização e Persistência**

### **Salvamento com ID Real**
Após salvar o registro principal, use:

```dart
// Após salvar manutenção com ID real
if (provider.hasReceiptImage && provider.receiptImageUrl == null) {
  await provider.syncImageToFirebase(actualMaintenanceId);
}

// Atualizar o modelo de dados com URLs das imagens
final updatedModel = maintenanceModel.copyWith(
  receiptImageUrl: provider.receiptImageUrl,
  receiptImagePath: provider.receiptImagePath,
);
```

---

## 📋 **Checklist de Integração**

Para cada novo formulário:

- [ ] ✅ **Modelos de Dados** - Campos `receiptImageUrl` e `receiptImagePath` adicionados
- [ ] ✅ **Serviços** - `ReceiptImageService` configurado no DI
- [ ] 🔧 **Provider** - Integrar métodos de captura e gerenciamento
- [ ] 🎨 **UI** - Adicionar `ReceiptImagePicker` e modal de seleção
- [ ] 🔄 **Persistência** - Sincronizar URLs após salvamento
- [ ] ✅ **Limpeza** - Atualizar métodos `clearForm` e `resetForm`

---

## 🚀 **Próximos Passos**

1. **MaintenanceFormProvider** - Aplicar padrão estabelecido
2. **ExpenseFormProvider** - Aplicar padrão estabelecido  
3. **Teste E2E** - Fluxo completo de captura → compressão → upload
4. **Offline Sync** - Garantir sincronização quando voltar online
5. **Performance** - Otimizar compressão e cache de imagens

---

## 🔧 **Troubleshooting**

### **Erro de Dependência**
```dart
// Registrar no injection_container.dart
sl.registerLazySingleton<ReceiptImageService>(() => ReceiptImageService(
  sl<ImageCompressionService>(),
  sl<FirebaseStorageService>(),
));
```

### **Erro de Permissões**
Verificar `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### **Erro de Firebase Storage**
Verificar `storage.rules` e configuração no `firebase.json`.

---

**Implementação de Referência:** `FuelFormProvider` + `FuelFormView`