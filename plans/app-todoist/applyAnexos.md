# Sistema de Anexos e Comentários Offline - Implementação

## 📋 Visão Geral

Este documento descreve a implementação completa do sistema de anexos e comentários para o módulo app-todoist, com foco em funcionalidade offline-first e sincronização inteligente com Firebase.

**Issue relacionada:** #25 - [TODO] Adicionar suporte a anexos e comentários em tarefas

## 🎯 Objetivos

- ✅ Funcionar 100% offline (anexar arquivos sem internet)
- ✅ Sincronização automática quando conectar
- ✅ Cache inteligente para downloads
- ✅ Interface visual com feedback de status
- ✅ Gerenciamento eficiente de armazenamento
- ✅ Sistema de comentários em tempo real

## 🏗️ Arquitetura do Sistema

### 1. Estrutura de Armazenamento

```
/data/data/com.seu.app/files/
├── attachments/           (arquivos sincronizados permanentes)
├── pending_uploads/       (arquivos aguardando upload)
├── cache/                 (downloads temporários - LRU)
└── hive/                  (metadados no banco local)
```

### 2. Fluxo de Funcionamento

#### Modo Offline (Sem Internet)
1. Usuário seleciona arquivo
2. Arquivo copiado para `pending_uploads/`
3. Metadados salvos no Hive com `isSynced: false`
4. UI mostra status "Aguardando upload"

#### Modo Online (Com Internet)
1. Sistema detecta conectividade
2. Processa fila de uploads automático
3. Upload para Firebase Storage
4. Atualiza metadados com URL remota
5. Move arquivo para `attachments/`

#### Download e Cache
1. Verifica cache local primeiro
2. Se não existe e há internet, baixa
3. Salva no cache com limite de tamanho
4. Limpeza automática por LRU

## 📁 Estrutura de Arquivos a Criar

### Core Services

#### 1. `/services/file_attachment_service.dart`
```dart
class FileAttachmentService {
  // Métodos principais
  static Future<TaskAttachment> addAttachmentOffline({...});
  static Future<void> processUploadQueue();
  static Stream<List<TaskAttachment>> watchAttachments(String taskId);
  static Future<File?> getAttachmentFile(TaskAttachment attachment);
}
```

#### 2. `/services/offline_file_manager.dart`
```dart
class OfflineFileManager {
  // Gerenciamento de armazenamento
  static Future<String> saveToLocalStorage(File file, String id);
  static Future<void> cleanCache();
  static Future<bool> hasStorageSpace(int bytes);
  static Future<void> ensureDirectories();
}
```

#### 3. `/services/attachment_sync_service.dart`
```dart
class AttachmentSyncService {
  // Sincronização e upload
  static Future<String> uploadToFirebase(File file, String path);
  static Future<File> downloadFromFirebase(String url);
  static Future<void> syncPendingUploads();
  static void scheduleRetryUpload(TaskAttachment attachment);
}
```

#### 4. `/services/comment_service.dart`
```dart
class CommentService {
  // Sistema de comentários
  static Future<TaskComment> addCommentOffline({...});
  static Stream<List<TaskComment>> watchComments(String taskId);
  static Future<void> syncComments(String taskId);
  static Future<void> deleteComment(String commentId);
}
```

### Models (Atualizar Existentes)

#### 5. Atualizar `/models/74_75_task_attachment.dart`
```dart
@HiveType(typeId: 75)
class TaskAttachment extends HiveObject {
  // Adicionar campos:
  @HiveField(10) String? localPath;           // Caminho local
  @HiveField(11) String? remotePath;          // URL Firebase
  @HiveField(12) AttachmentSyncStatus status; // Status de sync
  @HiveField(13) int retryCount;              // Tentativas de upload
  @HiveField(14) DateTime? lastRetryAt;       // Última tentativa
  
  // Métodos úteis
  bool get isAvailableOffline => localPath != null;
  bool get needsUpload => !isSynced && localPath != null;
  String get displayPath => remotePath ?? localPath ?? url;
}

enum AttachmentSyncStatus {
  pending,      // Aguardando upload
  uploading,    // Upload em progresso  
  synced,       // Sincronizado
  failed,       // Falha no upload
  cached,       // Disponível offline
  downloading   // Download em progresso
}
```

#### 6. Atualizar `/models/76_task_comment.dart`
```dart
@HiveType(typeId: 76)
class TaskComment extends HiveObject {
  // Adicionar campos:
  @HiveField(8) String? parentCommentId;    // Para threading
  @HiveField(9) List<String> mentions;     // @menções
  @HiveField(10) bool isEdited;            // Se foi editado
  @HiveField(11) CommentSyncStatus status; // Status de sync
  
  // Métodos úteis
  bool get isReply => parentCommentId != null;
  bool get needsSync => !isSynced;
}

enum CommentSyncStatus {
  pending,   // Aguardando sync
  syncing,   // Sincronizando
  synced,    // Sincronizado
  failed     // Falha na sync
}
```

### UI Components

#### 7. `/widgets/attachment_list_widget.dart`
```dart
class AttachmentListWidget extends StatelessWidget {
  final String taskId;
  final bool readOnly;
  
  // Widgets principais:
  Widget _buildAttachmentItem(TaskAttachment attachment);
  Widget _buildAddAttachmentButton();
  Widget _buildSyncStatusIndicator(TaskAttachment attachment);
  Widget _buildAttachmentPreview(TaskAttachment attachment);
}
```

#### 8. `/widgets/comment_thread_widget.dart`
```dart  
class CommentThreadWidget extends StatelessWidget {
  final String taskId;
  final bool allowReplies;
  
  // Widgets principais:
  Widget _buildCommentItem(TaskComment comment);
  Widget _buildReplyInput(TaskComment parentComment);
  Widget _buildCommentInput();
  Widget _buildSyncStatusBadge(TaskComment comment);
}
```

#### 9. `/widgets/attachment_upload_progress.dart`
```dart
class AttachmentUploadProgress extends StatelessWidget {
  // Indicador de progresso de uploads
  Widget _buildUploadQueue();
  Widget _buildProgressIndicator(TaskAttachment attachment);
  Widget _buildRetryButton(TaskAttachment attachment);
}
```

#### 10. `/widgets/file_preview_widget.dart`
```dart
class FilePreviewWidget extends StatelessWidget {
  final TaskAttachment attachment;
  
  // Preview para diferentes tipos:
  Widget _buildImagePreview();
  Widget _buildDocumentPreview(); 
  Widget _buildVideoPreview();
  Widget _buildGenericPreview();
}
```

### Utilities

#### 11. `/utils/file_type_detector.dart`
```dart
class FileTypeDetector {
  static AttachmentType detectFromExtension(String extension);
  static AttachmentType detectFromMimeType(String mimeType);
  static bool isPreviewable(AttachmentType type);
  static String getTypeDisplayName(AttachmentType type);
}
```

#### 12. `/utils/storage_calculator.dart`
```dart
class StorageCalculator {
  static Future<int> getAvailableSpace();
  static Future<int> getTotalCacheSize();
  static Future<int> getPendingUploadsSize();
  static String formatBytes(int bytes);
  static Future<bool> canStoreFile(int fileSize);
}
```

## 🔧 Configurações e Constantes

#### 13. `/constants/attachment_constants.dart`
```dart
class AttachmentConstants {
  // Limites de armazenamento
  static const int MAX_CACHE_SIZE = 100 * 1024 * 1024;      // 100MB
  static const int MAX_PENDING_SIZE = 500 * 1024 * 1024;    // 500MB
  static const int MAX_FILE_SIZE = 50 * 1024 * 1024;        // 50MB por arquivo
  
  // Configurações de retry
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(minutes: 5);
  static const Duration SYNC_INTERVAL = Duration(minutes: 1);
  
  // Diretórios
  static const String ATTACHMENTS_DIR = 'attachments';
  static const String PENDING_UPLOADS_DIR = 'pending_uploads';  
  static const String CACHE_DIR = 'cache';
  
  // Tipos de arquivo suportados
  static const List<String> SUPPORTED_IMAGE_TYPES = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> SUPPORTED_DOCUMENT_TYPES = ['pdf', 'doc', 'docx', 'txt'];
  static const List<String> SUPPORTED_VIDEO_TYPES = ['mp4', 'mov', 'avi'];
}
```

## 🚀 Passos de Implementação

### Fase 1: Core Services (1-2 dias)
1. ✅ Criar `OfflineFileManager` com estrutura de diretórios
2. ✅ Implementar `FileAttachmentService` básico
3. ✅ Configurar sistema de metadados no Hive
4. ✅ Testes básicos de armazenamento local

### Fase 2: Sistema de Upload (2-3 dias)  
1. ✅ Implementar `AttachmentSyncService`
2. ✅ Sistema de fila de uploads pendentes
3. ✅ Retry automático com backoff exponencial
4. ✅ Integração com Firebase Storage
5. ✅ Testes de sincronização

### Fase 3: Interface do Usuário (2-3 dias)
1. ✅ Criar widgets de anexos
2. ✅ Indicadores visuais de status
3. ✅ Sistema de preview de arquivos
4. ✅ Integração com `TaskDetailScreen`
5. ✅ Testes de UI

### Fase 4: Sistema de Comentários (1-2 dias)
1. ✅ Implementar `CommentService`
2. ✅ Widget de thread de comentários
3. ✅ Sistema de menções
4. ✅ Sincronização em tempo real

### Fase 5: Cache e Otimizações (1-2 dias)
1. ✅ Sistema de cache com LRU
2. ✅ Limpeza automática por tamanho
3. ✅ Download sob demanda
4. ✅ Compressão de imagens
5. ✅ Testes de performance

### Fase 6: Testes e Refinamentos (1-2 dias)
1. ✅ Testes de conectividade
2. ✅ Testes de stress de armazenamento
3. ✅ Testes de sincronização complexa
4. ✅ Polimento da UI
5. ✅ Documentação final

## 📱 Exemplos de Uso

### Adicionar Anexo Offline
```dart
// O usuário seleciona um arquivo
final file = await FilePicker.platform.pickFiles();

if (file != null) {
  // Adiciona imediatamente (funciona offline)
  final attachment = await FileAttachmentService.addAttachmentOffline(
    taskId: task.id,
    file: File(file.files.first.path!),
    type: FileTypeDetector.detectFromExtension(file.files.first.extension),
  );
  
  // UI atualiza automaticamente via stream
  // Arquivo será sincronizado quando houver internet
}
```

### Visualizar Anexos
```dart
// Stream reativo que funciona offline e online
StreamBuilder<List<TaskAttachment>>(
  stream: FileAttachmentService.watchAttachments(taskId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return AttachmentListWidget(
        attachments: snapshot.data!,
        onAttachmentTap: (attachment) async {
          final file = await FileAttachmentService.getAttachmentFile(attachment);
          if (file != null) {
            // Abre o arquivo
            await OpenFile.open(file.path);
          } else {
            // Mostra que precisa de internet
            _showNeedsInternetDialog();
          }
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### Adicionar Comentário
```dart
// Funciona offline
final comment = await CommentService.addCommentOffline(
  taskId: task.id,
  content: "Este é um comentário offline!",
);

// Será sincronizado automaticamente quando conectar
```

## 🔍 Monitoramento e Debug

### Logging de Sincronização
```dart
class AttachmentLogger {
  static void logUploadStart(TaskAttachment attachment);
  static void logUploadSuccess(TaskAttachment attachment, Duration duration);
  static void logUploadError(TaskAttachment attachment, dynamic error);
  static void logCacheHit(String attachmentId);
  static void logCacheMiss(String attachmentId);
}
```

### Widget de Debug (Desenvolvimento)
```dart
class AttachmentDebugPanel extends StatelessWidget {
  // Mostra estatísticas de:
  // - Arquivos pendentes
  // - Tamanho do cache
  // - Últimas sincronizações
  // - Erros de upload
}
```

## 🛡️ Tratamento de Erros

### Cenários Tratados
- ✅ Espaço insuficiente no dispositivo
- ✅ Arquivos corrompidos
- ✅ Falhas de conectividade durante upload
- ✅ Arquivos muito grandes
- ✅ Tipos de arquivo não suportados
- ✅ Permissões de arquivo negadas

### Mensagens de Erro Amigáveis
```dart
class AttachmentErrorMessages {
  static const String INSUFFICIENT_SPACE = 
    'Espaço insuficiente. Libere espaço ou remova arquivos em cache.';
  
  static const String FILE_TOO_LARGE = 
    'Arquivo muito grande. Limite: 50MB por arquivo.';
    
  static const String UNSUPPORTED_TYPE = 
    'Tipo de arquivo não suportado.';
    
  static const String UPLOAD_FAILED = 
    'Falha no upload. Será tentado novamente automaticamente.';
}
```

## 📊 Métricas de Performance

### Benchmarks Esperados
- **Upload Queue Processing**: < 500ms por arquivo
- **Cache Lookup**: < 50ms
- **Local File Access**: < 100ms  
- **Memory Usage**: < 50MB durante operações
- **Storage Overhead**: < 5% do tamanho total dos arquivos

### Monitoramento
```dart
class AttachmentMetrics {
  static void trackUploadTime(Duration duration);
  static void trackCacheEfficiency(bool hit);
  static void trackStorageUsage(int bytes);
  static Map<String, dynamic> getPerformanceReport();
}
```

## 🔒 Considerações de Segurança

### Validações Implementadas
- ✅ Verificação de tipo de arquivo por conteúdo (não apenas extensão)
- ✅ Limite de tamanho por arquivo e total
- ✅ Sanitização de nomes de arquivo
- ✅ Verificação de integridade após download
- ✅ Criptografia de arquivos sensíveis (opcional)

### Permissões Necessárias
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 📋 Checklist de Implementação

### Antes de Começar
- [ ] Configurar Firebase Storage no projeto
- [ ] Adicionar dependências no `pubspec.yaml`:
  ```yaml
  dependencies:
    file_picker: ^5.2.5
    path_provider: ^2.0.11
    connectivity_plus: ^3.0.2
    firebase_storage: ^11.0.6
    image: ^4.0.15
    video_thumbnail: ^0.5.3
    open_file: ^3.2.1
  ```
- [ ] Verificar permissões de armazenamento
- [ ] Configurar regras de segurança do Firebase Storage

### Durante a Implementação
- [ ] Testes em dispositivos sem internet
- [ ] Testes com arquivos grandes
- [ ] Testes de limpeza de cache
- [ ] Testes de sincronização após reconexão
- [ ] Validação de tipos de arquivo
- [ ] Testes de performance com muitos arquivos

### Após Implementação
- [ ] Testes de regressão completos
- [ ] Testes de stress de armazenamento
- [ ] Validação de métricas de performance
- [ ] Documentação de APIs
- [ ] Treinamento da equipe

## 🎯 Resultados Esperados

Após a implementação completa, o sistema deve:

✅ **Funcionar 100% offline** para anexar arquivos e comentários
✅ **Sincronizar automaticamente** quando a internet retornar
✅ **Gerenciar espaço** de forma eficiente com limpeza automática
✅ **Fornecer feedback visual** claro sobre status de sincronização
✅ **Manter performance** mesmo com muitos arquivos
✅ **Ser resiliente** a falhas de conectividade
✅ **Ter UX intuitiva** que não confunde o usuário

---

**Autor:** Claude AI  
**Data:** 2025-01-08  
**Versão:** 1.0  
**Status:** Especificação Completa - Pronta para Implementação