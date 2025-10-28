# Firestore Usage Examples - app-taskolist

Exemplos de como usar Firestore e Firebase Auth no app-taskolist.

## 🔐 Autenticação com Firebase

### 1. Registrar Novo Usuário

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> signUp({
  required String email,
  required String password,
  required String displayName,
}) async {
  try {
    // Registrar no Firebase Auth
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

    // Atualizar displayName
    await userCredential.user!.updateDisplayName(displayName);
    await userCredential.user!.reload();

    // Criar documento de usuário no Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'email': email,
          'displayName': displayName,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

    print('✅ Usuário registrado com sucesso');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('❌ Senha muito fraca');
    } else if (e.code == 'email-already-in-use') {
      print('❌ Email já está registrado');
    } else {
      print('❌ Erro ao registrar: ${e.message}');
    }
  }
}
```

### 2. Fazer Login

```dart
Future<void> signIn({
  required String email,
  required String password,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

    print('✅ Login bem-sucedido: ${userCredential.user?.email}');
    // Navegar para home page
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('❌ Usuário não encontrado');
    } else if (e.code == 'wrong-password') {
      print('❌ Senha incorreta');
    } else {
      print('❌ Erro ao fazer login: ${e.message}');
    }
  }
}
```

### 3. Fazer Logout

```dart
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  print('✅ Logout bem-sucedido');
}
```

### 4. Monitorar Estado de Autenticação

```dart
void setupAuthListener() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('👤 Usuário desconectado');
      // Navegar para login
    } else {
      print('👤 Usuário autenticado: ${user.email}');
      // Navegar para home
    }
  });
}
```

## 📋 Operações com Task Lists

### 1. Criar Nova Task List

```dart
Future<void> createTaskList({
  required String title,
  required String color,
  String? description,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ Usuário não autenticado');
    return;
  }

  try {
    final taskListRef = FirebaseFirestore.instance.collection('task_lists').doc();

    await taskListRef.set({
      'id': taskListRef.id,
      'title': title,
      'description': description,
      'color': color,
      'ownerId': user.uid,
      'memberIds': [],
      'isShared': false,
      'isArchived': false,
      'position': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Task list criada: ${taskListRef.id}');
  } catch (e) {
    print('❌ Erro ao criar task list: $e');
  }
}
```

### 2. Ler Todas as Task Lists do Usuário

```dart
Future<List<TaskListEntity>> getUserTaskLists() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ Usuário não autenticado');
    return [];
  }

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('task_lists')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('position')
        .get();

    final taskLists = snapshot.docs
        .map((doc) => TaskListEntity(
              id: doc.id,
              title: doc['title'] as String,
              description: doc['description'] as String?,
              color: doc['color'] as String,
              ownerId: doc['ownerId'] as String,
              memberIds: List<String>.from(doc['memberIds'] as List),
              createdAt: (doc['createdAt'] as Timestamp).toDate(),
              updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
              isShared: doc['isShared'] as bool? ?? false,
              isArchived: doc['isArchived'] as bool? ?? false,
              position: doc['position'] as int? ?? 0,
            ))
        .toList();

    return taskLists;
  } catch (e) {
    print('❌ Erro ao ler task lists: $e');
    return [];
  }
}
```

### 3. Atualizar Task List

```dart
Future<void> updateTaskList({
  required String taskListId,
  String? title,
  String? color,
  String? description,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .update({
          if (title != null) 'title': title,
          if (color != null) 'color': color,
          if (description != null) 'description': description,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    print('✅ Task list atualizada');
  } catch (e) {
    print('❌ Erro ao atualizar task list: $e');
  }
}
```

### 4. Compartilhar Task List com Outros Usuários

```dart
Future<void> shareTaskList({
  required String taskListId,
  required List<String> userEmails,
}) async {
  try {
    // Primeiro, obter UIDs pelos emails
    final userIds = <String>[];
    for (final email in userEmails) {
      try {
        final methods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(email);

        if (methods.isNotEmpty) {
          // Nota: Você precisará ter um mapa email->uid no Firestore
          // ou usar um Cloud Function para resolver emails
          print('📧 Email encontrado: $email');
        }
      } catch (e) {
        print('❌ Email não encontrado: $email');
      }
    }

    // Atualizar a task list com os novos membros
    await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .update({
          'memberIds': FieldValue.arrayUnion(userIds),
          'isShared': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    print('✅ Task list compartilhada');
  } catch (e) {
    print('❌ Erro ao compartilhar task list: $e');
  }
}
```

### 5. Deletar Task List

```dart
Future<void> deleteTaskList({required String taskListId}) async {
  try {
    // Primeiro, deletar todas as tasks
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final taskDoc in tasksSnapshot.docs) {
      batch.delete(taskDoc.reference);
    }
    await batch.commit();

    // Depois, deletar a task list
    await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .delete();

    print('✅ Task list deletada');
  } catch (e) {
    print('❌ Erro ao deletar task list: $e');
  }
}
```

## ✅ Operações com Tasks

### 1. Criar Nova Task

```dart
Future<void> createTask({
  required String taskListId,
  required String title,
  String? description,
  String? assignedToId,
  DateTime? dueDate,
  String? priority = 'medium',
  String? status = 'pending',
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ Usuário não autenticado');
    return;
  }

  try {
    final taskRef = FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .doc();

    await taskRef.set({
      'id': taskRef.id,
      'title': title,
      'description': description,
      'listId': taskListId,
      'createdById': user.uid,
      'assignedToId': assignedToId,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'reminderDate': null,
      'status': status,
      'priority': priority,
      'isStarred': false,
      'position': 0,
      'tags': [],
      'parentTaskId': null,
      'notes': null,
      'version': 1,
      'isDirty': false,
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Task criada: ${taskRef.id}');
  } catch (e) {
    print('❌ Erro ao criar task: $e');
  }
}
```

### 2. Ler Todas as Tasks de uma List

```dart
Future<List<TaskEntity>> getTasksForList({
  required String taskListId,
}) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('position')
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskEntity.fromFirebaseMap(doc.data()))
        .toList();

    return tasks;
  } catch (e) {
    print('❌ Erro ao ler tasks: $e');
    return [];
  }
}
```

### 3. Atualizar Task

```dart
Future<void> updateTask({
  required String taskListId,
  required String taskId,
  required Map<String, dynamic> updates,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .doc(taskId)
        .update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
          'version': FieldValue.increment(1),
        });

    print('✅ Task atualizada');
  } catch (e) {
    print('❌ Erro ao atualizar task: $e');
  }
}
```

### 4. Marcar Task como Concluída

```dart
Future<void> completeTask({
  required String taskListId,
  required String taskId,
}) async {
  await updateTask(
    taskListId: taskListId,
    taskId: taskId,
    updates: {'status': 'completed'},
  );
}
```

### 5. Deletar Task

```dart
Future<void> deleteTask({
  required String taskListId,
  required String taskId,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .doc(taskId)
        .delete();

    print('✅ Task deletada');
  } catch (e) {
    print('❌ Erro ao deletar task: $e');
  }
}
```

### 6. Real-time Listener para Tasks

```dart
void listenToTasksRealtime({
  required String taskListId,
  required Function(List<TaskEntity>) onTasksChanged,
}) {
  FirebaseFirestore.instance
      .collection('task_lists')
      .doc(taskListId)
      .collection('tasks')
      .where('isDeleted', isEqualTo: false)
      .orderBy('position')
      .snapshots()
      .listen(
        (snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskEntity.fromFirebaseMap(doc.data()))
              .toList();
          onTasksChanged(tasks);
        },
        onError: (e) {
          print('❌ Erro ao escutar tasks: $e');
        },
      );
}
```

## 🔄 Padrões Avançados

### 1. Transação (Múltiplas Operações Atômicas)

```dart
Future<void> moveTaskToAnotherList({
  required String sourceListId,
  required String targetListId,
  required String taskId,
}) async {
  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Ler task original
      final sourceRef = FirebaseFirestore.instance
          .collection('task_lists')
          .doc(sourceListId)
          .collection('tasks')
          .doc(taskId);

      final sourceDoc = await transaction.get(sourceRef);
      if (!sourceDoc.exists) return;

      final taskData = sourceDoc.data()!;

      // Atualizar listId
      taskData['listId'] = targetListId;
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      // Criar nova task
      final targetRef = FirebaseFirestore.instance
          .collection('task_lists')
          .doc(targetListId)
          .collection('tasks')
          .doc(taskId);

      transaction.set(targetRef, taskData);
      transaction.delete(sourceRef);
    });

    print('✅ Task movida com sucesso');
  } catch (e) {
    print('❌ Erro ao mover task: $e');
  }
}
```

### 2. Batch Operations (Múltiplas Escritas)

```dart
Future<void> bulkDeleteTasks({
  required String taskListId,
  required List<String> taskIds,
}) async {
  try {
    final batch = FirebaseFirestore.instance.batch();

    for (final taskId in taskIds) {
      final ref = FirebaseFirestore.instance
          .collection('task_lists')
          .doc(taskListId)
          .collection('tasks')
          .doc(taskId);

      batch.delete(ref);
    }

    await batch.commit();
    print('✅ ${taskIds.length} tasks deletadas');
  } catch (e) {
    print('❌ Erro ao deletar tasks em lote: $e');
  }
}
```

### 3. Pagination

```dart
Future<List<TaskEntity>> getTasksWithPagination({
  required String taskListId,
  int pageSize = 10,
  DocumentSnapshot? lastDoc,
}) async {
  try {
    var query = FirebaseFirestore.instance
        .collection('task_lists')
        .doc(taskListId)
        .collection('tasks')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    final tasks = snapshot.docs
        .map((doc) => TaskEntity.fromFirebaseMap(doc.data()))
        .toList();

    return tasks;
  } catch (e) {
    print('❌ Erro ao paginar tasks: $e');
    return [];
  }
}
```

## ⚠️ Tratamento de Erros

```dart
void handleFirestoreError(Object e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        print('❌ Permissão negada');
        break;
      case 'not-found':
        print('❌ Documento não encontrado');
        break;
      case 'already-exists':
        print('❌ Documento já existe');
        break;
      case 'deadline-exceeded':
        print('❌ Operação expirou');
        break;
      default:
        print('❌ Erro Firestore: ${e.message}');
    }
  } else {
    print('❌ Erro desconhecido: $e');
  }
}
```

---

**Dica**: Sempre teste suas operações com dados reais e múltiplos usuários para garantir que as regras de segurança estão funcionando corretamente!
